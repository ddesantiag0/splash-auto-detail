const { test } = require('node:test');
const assert = require('node:assert/strict');
const { viewStatus } = require('../availability/model.cjs');

test('wait indicator fails closed for stale, disconnected, missing and invalid estimates', () => {
  const now = Date.parse('2026-09-15T20:00:00Z');
  const row = { status: 'available', wait_min: 0, wait_max: 15, updated_at: '2026-09-15T19:55:00Z', expires_at: '2026-09-15T20:25:00Z' };
  assert.equal(viewStatus(row, now).status, 'available');
  assert.equal(viewStatus(row, now, false).status, 'unknown');
  assert.equal(viewStatus(row, now + 25 * 60000).status, 'unknown');
  assert.equal(viewStatus(null, now).status, 'unknown');
  assert.equal(viewStatus({ ...row, wait_max: -1 }, now).status, 'unknown');
  assert.equal(viewStatus({ ...row, expires_at: 'invalid' }, now).status, 'unknown');
});
