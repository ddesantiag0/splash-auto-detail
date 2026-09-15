import { createClient } from '@supabase/supabase-js';
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
if (target && config?.url && config?.publishableKey) {
  const client = createClient(config.url, config.publishableKey, { auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false } });
  async function refresh() {
    const current = ++request;
    try {
      const { data, error } = await client.rpc('read_shop_wait').abortSignal(AbortSignal.timeout(10000));
      if (current !== request) return;
      if (error || !data) throw new Error('Unavailable');
      const server = Date.parse(data.server_now);
      if (!Number.isFinite(server)) throw new Error('Invalid server time');
      offset = server - Date.now();
      row = data.status;
      connected = true;
    } catch { if (current === request) connected = false; }
    render();
  }
  client.channel('public-shop-wait').on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'shop_wait' }, refresh).subscribe(status => {
    if (status === 'SUBSCRIBED') refresh();
    if (['CHANNEL_ERROR', 'TIMED_OUT', 'CLOSED'].includes(status)) { connected = false; render(); }
  });
  refresh();
  setInterval(refresh, 30000);
  setInterval(render, 10000);
  window.addEventListener('online', refresh);
  window.addEventListener('offline', () => { ++request; connected = false; render(); });
  document.addEventListener('visibilitychange', () => { if (!document.hidden) refresh(); });
}
window.addEventListener('languagechange', () => queueMicrotask(render));
