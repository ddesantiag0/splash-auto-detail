const { test } = require('node:test');
const assert = require('node:assert/strict');
const { readFileSync, readdirSync } = require('node:fs');
const { PGlite } = require('@electric-sql/pglite');
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

test('database enforces owner-only writes, server timestamps, range checks and conflicting edits', async () => {
  const db = new PGlite();
  try {
    await db.exec(`create role anon; create role authenticated; create schema auth;
      create table auth.users(id uuid primary key);
      create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub', true),'')::uuid $$;
      grant usage on schema public, auth to anon, authenticated;
      grant execute on function auth.uid() to anon, authenticated;`);
    const filename = readdirSync('supabase/migrations').find(n => n.endsWith('_shop_wait.sql'));
    // Embedded Postgres has no logical replication; hosted publication is verified at activation.
    const sql = readFileSync(`supabase/migrations/${filename}`, 'utf8').replace('alter publication supabase_realtime add table public.shop_wait;', '');
    await db.exec(sql);
    const owner = '00000000-0000-0000-0000-000000000001';
    const stranger = '00000000-0000-0000-0000-000000000002';
    await db.exec(`insert into auth.users values ('${owner}'),('${stranger}'); insert into shop_owners values ('${owner}'); set role anon;`);
    assert.ok((await db.query('select read_shop_wait() as data')).rows[0].data.server_now);
    await assert.rejects(db.query("update shop_wait set status='busy' where id=1"));
    await db.exec(`reset role; set role authenticated; select set_config('request.jwt.claim.sub','${stranger}',false);`);
    assert.equal((await db.query("update shop_wait set status='closed' where id=1 returning id")).rows.length, 0);
    await assert.rejects(db.query(`insert into shop_owners values ('${stranger}')`));
    await db.exec(`select set_config('request.jwt.claim.sub','${owner}',false);`);
    const saved = (await db.query("update shop_wait set status='available',wait_min=0,wait_max=15,valid_minutes=30 where id=1 and version=1 returning *")).rows[0];
    assert.equal(saved.version, 2);
    assert.equal(Date.parse(saved.expires_at) - Date.parse(saved.updated_at), 30 * 60000);
    assert.equal((await db.query("update shop_wait set status='busy' where id=1 and version=1 returning id")).rows.length, 0);
    await assert.rejects(db.query("update shop_wait set wait_max=-1 where id=1"));
    await assert.rejects(db.query("update shop_wait set updated_at='2099-01-01' where id=1"));
    await db.exec('reset role; delete from shop_owners; set role authenticated;');
    assert.equal((await db.query("update shop_wait set status='closed',wait_min=null,wait_max=null where id=1 returning id")).rows.length, 0);
  } finally { await db.close(); }
});
