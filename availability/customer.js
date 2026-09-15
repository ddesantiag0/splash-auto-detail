import { viewStatus } from './model.cjs';
const target = document.getElementById('shop-wait');
const config = window.splashAvailabilityConfig;
const labels = {
  en: { title: 'Current shop wait', available: 'Available', moderate: 'Getting busy', busy: 'Very busy', closed: 'Closed', unknown: 'Current wait unavailable', note: 'Estimated time until service starts. Wait may change.', call: 'Call for current wait', updated: 'Last updated', minutes: 'minutes' },
  es: { title: 'Espera actual', available: 'Disponible', moderate: 'Algo ocupado', busy: 'Muy ocupado', closed: 'Cerrado', unknown: 'Espera actual no disponible', note: 'Tiempo estimado hasta que comience el servicio. La espera puede cambiar.', call: 'Llame para consultar la espera', updated: 'Última actualización', minutes: 'minutos' }
};
let row = null, connected = false, offset = 0, request = 0;
function render() {
  if (!target) return;
  const lang = document.documentElement.lang === 'es' ? 'es' : 'en';
  const t = labels[lang];
  const state = viewStatus(row, Date.now() + offset, connected && navigator.onLine);
  target.dataset.status = state.status;
  target.querySelector('[data-wait-title]').textContent = t.title;
  target.querySelector('[data-wait-status]').textContent = t[state.status];
  target.querySelector('[data-wait-estimate]').textContent = state.min == null || state.status === 'closed' ? '' : `${state.min}–${state.max} ${t.minutes}`;
  target.querySelector('[data-wait-note]').textContent = t.note;
  target.querySelector('[data-wait-call]').textContent = t.call;
  target.querySelector('[data-wait-updated]').textContent = state.updated ? `${t.updated}: ${new Date(state.updated).toLocaleTimeString(lang, { hour: 'numeric', minute: '2-digit' })}` : '';
}
render();
if (target && config?.apiUrl) {
  const base = config.apiUrl.replace(/\/+$/, '');
  const api = new URL(base);
  if (api.protocol !== 'https:' && !(['localhost', '127.0.0.1'].includes(api.hostname) && api.protocol === 'http:')) throw new Error('HTTPS required');
  function accept(data) {
    const server = Date.parse(data.server_now);
    if (!Number.isFinite(server)) throw new Error('Invalid server time');
    offset = server - Date.now(); row = data.status; connected = true; render();
  }
  async function refresh() {
    const current = ++request;
    try {
      const response = await fetch(`${base}/v1/wait`, {cache: 'no-store', signal: AbortSignal.timeout(10000)});
      if (!response.ok) throw new Error('Unavailable');
      const data = await response.json();
      if (current !== request) return;
      accept(data);
    } catch { if (current === request) connected = false; }
    render();
  }
  let socket;
  function connect() {
    socket = new WebSocket(`${base.replace(/^http/, 'ws')}/v1/wait/stream`);
    socket.onmessage = event => {
      try { ++request; accept(JSON.parse(event.data)); }
      catch { connected = false; render(); }
    };
    socket.onerror = () => { connected = false; render(); };
    socket.onclose = () => { connected = false; render(); setTimeout(connect, 5000); };
  }
  connect();
  refresh();
  setInterval(refresh, 30000);
  setInterval(render, 10000);
  window.addEventListener('online', refresh);
  window.addEventListener('offline', () => { ++request; connected = false; render(); });
  document.addEventListener('visibilitychange', () => { if (!document.hidden) refresh(); });
}
window.addEventListener('languagechange', () => queueMicrotask(render));
