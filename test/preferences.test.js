const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const { preferredLanguage } = require('../preferences');
const spanish = require('../translations');

test('matches preferred supported language, including regional variants', () => {
  assert.equal(preferredLanguage(['es-MX', 'en-US']), 'es');
  assert.equal(preferredLanguage(['en-GB', 'es-ES']), 'en');
  assert.equal(preferredLanguage(['fr-FR', 'es-ES']), 'es');
  assert.equal(preferredLanguage(['ja-JP']), 'en');
  assert.equal(preferredLanguage([]), 'en');
});

test('Spanish catalog is synchronized with web and Flutter outputs', () => {
  const source = JSON.parse(fs.readFileSync(path.join(__dirname, '../localization/es.json')));
  assert.deepEqual(spanish, source);
  const dart = fs.readFileSync(path.join(__dirname, '../app/lib/core/localization/spanish.dart'), 'utf8');
  for (const value of Object.values(source)) assert.ok(dart.includes(JSON.stringify(value)), value);
});

test('initial Spanish and live language changes update text and accessible labels', () => {
  const nodes = ['  Get Directions  ', 'Open Now', 'Splash Auto Detail', 'Gallery'].map(nodeValue => ({
    nodeValue, parentElement: { closest: () => false },
  }));
  const attributes = { 'aria-label': 'Splash Auto Detail home' };
  const element = {
    hasAttribute: name => name in attributes,
    getAttribute: name => attributes[name],
    setAttribute: (name, value) => { attributes[name] = value; },
  };
  const listeners = {};
  const navigator = { languages: ['es-MX', 'en-US'] };
  const document = {
    documentElement: {},
    querySelectorAll: () => [element],
    createTreeWalker: () => {
      let index = -1;
      return { nextNode() { return ++index < nodes.length; }, get currentNode() { return nodes[index]; } };
    },
  };
  const context = { navigator, document, NodeFilter: { SHOW_TEXT: 4 },
    window: { addEventListener: (name, fn) => { listeners[name] = fn; } } };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../translations.js'), 'utf8') + '\n' +
    fs.readFileSync(path.join(__dirname, '../preferences.js'), 'utf8'), context);
  assert.equal(document.documentElement.lang, 'es');
  assert.equal(nodes[0].nodeValue, '  Cómo llegar  ');
  assert.equal(nodes[1].nodeValue, 'Abierto ahora');
  assert.equal(attributes['aria-label'], 'Inicio de Splash Auto Detail');
  navigator.languages = ['en-US'];
  listeners.languagechange();
  assert.equal(document.documentElement.lang, 'en');
  assert.equal(nodes[0].nodeValue, '  Get Directions  ');
  assert.equal(nodes[1].nodeValue, 'Open Now');
  assert.equal(attributes['aria-label'], 'Splash Auto Detail home');
  assert.equal(nodes[2].nodeValue, 'Splash Auto Detail');
});
