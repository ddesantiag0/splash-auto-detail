'use strict';
function viewStatus(row, now = Date.now(), connected = true) {
  const unknown = { status: 'unknown', min: null, max: null };
  if (!connected || !row || !['available', 'moderate', 'busy', 'closed'].includes(row.status)) return unknown;
  const expires = Date.parse(row.expires_at);
  const updated = Date.parse(row.updated_at);
  if (!Number.isFinite(expires) || !Number.isFinite(updated) || expires <= now || updated > now + 60000) return unknown;
  if (row.status !== 'closed' && (!Number.isInteger(row.wait_min) || !Number.isInteger(row.wait_max) || row.wait_min < 0 || row.wait_max < row.wait_min || row.wait_max > 240)) return unknown;
  return { status: row.status, min: row.wait_min, max: row.wait_max, updated };
}
module.exports = { viewStatus };
