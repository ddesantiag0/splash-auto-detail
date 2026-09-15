const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const vm = require('node:vm');
const source = readFileSync(join(__dirname, '../script.js'), 'utf8');

function runHours(instant) {
  const hours = {};
  const status = {};
  const badge = { querySelector: () => status, classList: { add() {}, remove() {} } };
  class Clock extends Date { constructor() { super(instant); } }
  vm.runInNewContext(source, {
    Date: Clock, Intl, window: {},
    document: {
      readyState: 'loading', addEventListener() {}, querySelector: () => null,
      querySelectorAll: () => [],
      getElementById: id => ({ todayHours: hours, statusBadge: badge })[id] || null,
    },
  });
  return { hours: hours.textContent, status: status.textContent };
}

for (const [instant, expected] of [
  ['2026-09-14T15:14:00Z', 'Closed • Opens Today 8:15 AM'],
  ['2026-09-14T15:15:00Z', 'Open Now'],
  ['2026-09-15T00:00:00Z', 'Closed • Opens Tomorrow 8:15 AM'],
  ['2026-09-19T21:00:00Z', 'Closed • Opens Monday 8:15 AM'],
  ['2026-09-21T01:00:00Z', 'Closed • Opens Monday 8:15 AM'],
  ['2026-01-05T16:15:00Z', 'Open Now'],
]) {
  test(`shop hours at ${instant}`, () => assert.equal(runHours(instant).status, expected));
}

test('gallery selection exposes only the selected filter as pressed', () => {
  function element(filter) {
    return {
      dataset: { filter }, attrs: {}, handlers: {},
      classList: { add() {}, remove() {} },
      setAttribute(name, value) { this.attrs[name] = value; },
      addEventListener(name, handler) { this.handlers[name] = handler; },
    };
  }
  const buttons = ['all', 'exterior', 'interior'].map(element);
  const items = ['exterior', 'interior'].map(category => ({
    dataset: { category }, hidden: false,
    classList: { add() { items.find(i => i.dataset.category === category).hidden = true; },
      remove() { items.find(i => i.dataset.category === category).hidden = false; } },
  }));
  vm.runInNewContext(source, { window: {}, document: {
    readyState: 'complete', getElementById: () => null, querySelector: () => null,
    querySelectorAll: selector => ({ '.filter-btn': buttons, '.gallery-item': items })[selector] || [],
  } });
  buttons[2].handlers.click();
  assert.deepEqual(buttons.map(b => b.attrs['aria-pressed']), ['false', 'false', 'true']);
  assert.deepEqual(items.map(i => i.hidden), [true, false]);
  buttons[0].handlers.click();
  assert.deepEqual(buttons.map(b => b.attrs['aria-pressed']), ['true', 'false', 'false']);
  assert.deepEqual(items.map(i => i.hidden), [false, false]);
});
