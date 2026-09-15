'use strict';

function preferredLanguage(languages = []) {
  for (const locale of languages) {
    const language = String(locale).toLowerCase().split(/[-_]/)[0];
    if (language === 'en' || language === 'es') return language;
  }
  return 'en';
}

function translate(source, language) {
  return language === 'es' ? (splashSpanish[source] ?? source) : source;
}

if (typeof module !== 'undefined') module.exports = { preferredLanguage };

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  const originals = new WeakMap();
  const attributes = new WeakMap();
  const getLanguage = () => preferredLanguage(navigator.languages || [navigator.language]);
  function apply(root = document) {
    const language = getLanguage();
    document.documentElement.lang = language;
    // Keep the original English text so a languagechange can restore it exactly.
    // Exclude code, structured data, and customer input from translation.
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    while (walker.nextNode()) {
      const node = walker.currentNode;
      if (node.parentElement?.closest('script, style, textarea, [contenteditable]')) continue;
      const original = originals.get(node) ?? node.nodeValue;
      const key = original.trim().replace(/\s+/g, ' ');
      if (!Object.hasOwn(splashSpanish, key)) continue;
      originals.set(node, original);
      node.nodeValue = language === 'en' ? original : original.replace(/\S[\s\S]*\S|\S/, translate(key, language));
    }
    root.querySelectorAll('[aria-label], [alt], [title]').forEach(element => {
      const saved = attributes.get(element) ?? {};
      for (const name of ['aria-label', 'alt', 'title']) {
        if (!element.hasAttribute(name)) continue;
        const original = saved[name] ?? element.getAttribute(name);
        saved[name] = original;
        element.setAttribute(name, translate(original, language));
      }
      attributes.set(element, saved);
    });
  }
  window.SplashI18n = { apply, translate: source => translate(source, getLanguage()) };
  apply();
  window.addEventListener('languagechange', () => apply());
}
