// What the schema refuses, asserted against a real PostgreSQL 16.
//
// Run: DATABASE_URL=… node --test db/
//
// **Every test here is a rejection or a rule**, because a schema's value is what
// it will not let happen. A suite that only proved rows can be inserted would
// pass against a schema with no constraints at all, which is the failure
// `kolonie-docs/AGENTS.md` §10 describes: green that means nothing.
//
// The tests share one database and clean up after themselves rather than
// creating one each, because the thing under test includes PowerDNS's tables
// sitting beside ours and a per-test database would not have them.

import { after, before, beforeEach, describe, it } from 'node:test'
import assert from 'node:assert/strict'
import pg from 'pg'
import { migrate } from './migrate.mjs'

const url = process.env.DATABASE_URL
if (!url) {
  throw new Error(
    'DATABASE_URL is unset. These tests want a real PostgreSQL 16 — ' +
    '`npm run db:up` brings one up. They do not skip themselves: a suite that ' +
    'skips silently reports green while covering nothing.')
}

const db = new pg.Client({ connectionString: url })

/** The error a constraint raised, or `null` if the statement succeeded. */
async function refused(sql, params) {
  try {
    await db.query(sql, params)
    return null
  } catch (err) {
    return err
  }
}

async function holder(tier = 'free') {
  const agent = tier === 'citizen' ? `agent-${Math.random().toString(36).slice(2)}` : null
  const { rows } = await db.query(
    'INSERT INTO holders (tier, kolonie_agent_id, key_hash) VALUES ($1, $2, $3) RETURNING id',
    [tier, agent, 'not-a-key-just-a-hash-shaped-string'])
  return rows[0].id
}

// Migrating rather than resetting, and the reset is `npm test`'s own first step.
// Two test files that each dropped the schema would race, and `--test-concurrency=1`
// is what keeps them from racing over rows — a reset in here would defeat it.
before(async () => {
  await db.connect()
  await migrate(db, { quiet: true })
})

after(async () => { await db.end() })

beforeEach(async () => {
  // `names` is never deleted from in production — that is the whole of N-013 —
  // so the test's own cleanup is the one place it happens, and it happens in
  // the order the foreign keys allow.
  await db.query('DELETE FROM tombstones; DELETE FROM names; DELETE FROM holders;')
})

describe('what a label may be (N-024)', () => {
  const good = ['abc', 'a-b', 'agent-007', 'x'.repeat(63), 'k8s-node-1']
  const bad = {
    'ab': 'two characters, under the three-character floor',
    '': 'empty',
    ['x'.repeat(64)]: 'sixty-four characters',
    '-abc': 'leading hyphen',
    'abc-': 'trailing hyphen',
    'ABC': 'uppercase',
    'a_b': 'underscore',
    'a.b': 'a dot is a second label',
    'bücher': 'not ASCII',
    'xn--bcher-kva': 'punycode, which is ASCII and is the bypass the rule exists for',
    'ab--cd': 'an IDNA-reserved prefix that is not xn-- yet',
  }

  for (const label of good) {
    it(`accepts ${label}`, async () => {
      const h = await holder()
      assert.equal(await refused('INSERT INTO names (label, holder_id) VALUES ($1, $2)', [label, h]), null)
    })
  }

  for (const [label, why] of Object.entries(bad)) {
    it(`refuses ${JSON.stringify(label)} — ${why}`, async () => {
      const h = await holder()
      const err = await refused('INSERT INTO names (label, holder_id) VALUES ($1, $2)', [label, h])
      assert.ok(err, `${label} was accepted and should not have been`)
    })
  }

  it('says which rule refused it, rather than naming a constraint', async () => {
    const h = await holder()
    const err = await refused('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['xn--bcher-kva', h])
    assert.match(err.hint ?? '', /N-024/)
  })
})

describe('the reserved-name list (N-015)', () => {
  it('refuses a reserved label', async () => {
    const h = await holder()
    const err = await refused('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['login', h])
    assert.ok(err)
  })

  it('answers why with the word the maintainer wrote', async () => {
    const h = await holder()
    const err = await refused('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['paypal', h])
    assert.match(err.hint ?? '', /N-015: financial institution/)
  })

  it('refuses a reserved label a citizen chose, not only an assigned one', async () => {
    const h = await holder('citizen')
    const err = await refused('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['kolonie', h])
    assert.ok(err)
  })

  it('holds a reason for every label, and the loader refuses one without', async () => {
    const { rows } = await db.query(
      "SELECT count(*)::int AS n FROM reserved_names WHERE reason IS NULL OR reason = ''")
    assert.equal(rows[0].n, 0)
  })

  it('reserves the zone\'s own labels even though the grammar already refuses them', async () => {
    const { rows } = await db.query(
      "SELECT label FROM reserved_names WHERE label IN ('_psl', '_acme-challenge')")
    assert.equal(rows.length, 2)
  })
})

describe('a released name is never reissued (N-013)', () => {
  async function release(label) {
    await db.query('UPDATE names SET holder_id = NULL WHERE label = $1', [label])
    await db.query('INSERT INTO tombstones (label, reason) VALUES ($1, $2)', [label, 'clock'])
  }

  it('refuses to issue a tombstoned label to somebody else', async () => {
    const first = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['released-one', first])
    await release('released-one')

    const second = await holder()
    const err = await refused(
      'INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['released-one', second])

    assert.ok(err, 'a tombstoned label was reissued')
    assert.match(err.hint ?? '', /N-013/)
  })

  it('refuses it by the primary key too, with every trigger out of the way', async () => {
    // The previous test proves the *message*. This one proves the *constraint*,
    // and they are not the same claim: the trigger answers first, so if the
    // trigger were the only thing standing there, dropping it would silently
    // reopen reissue. Inserting with no holder takes the trigger's reissue
    // branch out of play — there is nobody to hand it to — and what is left
    // refusing the label is the primary key on a row that never left the table.
    //
    // That is the whole of why `names` holds released labels rather than
    // `tombstones` holding them alone: PostgreSQL cannot put a primary key
    // across two tables, so uniqueness that spans release would have had to be
    // a trigger, which is the "one bug away" this issue names.
    const first = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['released-pk', first])
    await release('released-pk')

    const err = await refused('INSERT INTO names (label) VALUES ($1)', ['released-pk'])
    assert.ok(err, 'a tombstoned label was inserted again')
    assert.equal(err.code, '23505', 'refused by something other than the primary key')
  })

  it('refuses the reissue that looks like an update rather than an insert', async () => {
    const first = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['released-two', first])
    await release('released-two')

    const second = await holder()
    const err = await refused(
      'UPDATE names SET holder_id = $2 WHERE label = $1', ['released-two', second])

    assert.ok(err, 'a tombstoned label was handed to a second holder by UPDATE')
    assert.match(err.hint ?? '', /N-013/)
  })

  it('refuses to delete the row that makes the label unavailable', async () => {
    const h = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['released-three', h])
    await release('released-three')

    const err = await refused('DELETE FROM names WHERE label = $1', ['released-three'])
    assert.ok(err, 'the row was deleted, which frees the label for reissue')
    assert.equal(err.code, '23503')
  })

  it('refuses a tombstone beside a live holder', async () => {
    const h = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['still-held', h])
    const err = await refused(
      'INSERT INTO tombstones (label, reason) VALUES ($1, $2)', ['still-held', 'clock'])
    assert.ok(err)
  })

  it('records nothing about who held it', async () => {
    const { rows } = await db.query(`
      SELECT column_name FROM information_schema.columns
       WHERE table_name = 'tombstones'`)
    const columns = rows.map((r) => r.column_name).sort()
    assert.deepEqual(columns, ['label', 'reason', 'released_at'])
  })

  it('lets the sweeper touch a tombstoned row without that being a reissue', async () => {
    const h = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['released-four', h])
    await release('released-four')
    assert.equal(await refused("SELECT note_name_used('released-four')"), null)
  })
})

describe('the clock runs on use, not on issuance', () => {
  const longAgo = "now() - INTERVAL '31 days'"

  it('releases a free name that has not been used in 30 days', async () => {
    const h = await holder()
    await db.query(
      `INSERT INTO names (label, holder_id, issued_at, last_used_at)
       VALUES ($1, $2, ${longAgo}, ${longAgo})`, ['stale-name', h])
    const { rows } = await db.query('SELECT label FROM names_due_for_release')
    assert.deepEqual(rows.map((r) => r.label), ['stale-name'])
  })

  it('leaves an old name alone while it is still being used', async () => {
    const h = await holder()
    await db.query(
      `INSERT INTO names (label, holder_id, issued_at, last_used_at)
       VALUES ($1, $2, ${longAgo}, now())`, ['old-but-working', h])
    const { rows } = await db.query('SELECT label FROM names_due_for_release')
    assert.deepEqual(rows, [])
  })

  it('never releases a citizen\'s name (N-012)', async () => {
    const h = await holder('citizen')
    await db.query(
      `INSERT INTO names (label, holder_id, issued_at, last_used_at)
       VALUES ($1, $2, ${longAgo}, ${longAgo})`, ['citizen-name', h])
    const { rows } = await db.query('SELECT label FROM names_due_for_release')
    assert.deepEqual(rows, [])
  })

  it('does not offer an already-released name a second time', async () => {
    const h = await holder()
    await db.query(
      `INSERT INTO names (label, holder_id, issued_at, last_used_at)
       VALUES ($1, $2, ${longAgo}, ${longAgo})`, ['gone-already', h])
    await db.query('UPDATE names SET holder_id = NULL WHERE label = $1', ['gone-already'])
    await db.query('INSERT INTO tombstones (label, reason) VALUES ($1, $2)', ['gone-already', 'clock'])
    const { rows } = await db.query('SELECT label FROM names_due_for_release')
    assert.deepEqual(rows, [])
  })

  it('moves the clock on use and on nothing else', async () => {
    const h = await holder()
    await db.query(
      `INSERT INTO names (label, holder_id, issued_at, last_used_at)
       VALUES ($1, $2, ${longAgo}, ${longAgo})`, ['touched', h])
    await db.query("SELECT note_name_used('touched')")
    const { rows } = await db.query(
      "SELECT last_used_at > now() - INTERVAL '1 minute' AS fresh, issued_at < now() - INTERVAL '30 days' AS old FROM names WHERE label = 'touched'")
    assert.equal(rows[0].fresh, true)
    assert.equal(rows[0].old, true, 'issued_at moved, and it should not have')
  })
})

describe('holders', () => {
  it('refuses a citizen who is nobody on the Kolonie side', async () => {
    const err = await refused(
      'INSERT INTO holders (tier, key_hash) VALUES ($1, $2)', ['citizen', 'hash'])
    assert.ok(err)
  })

  it('refuses to delete a holder that still holds a name', async () => {
    const h = await holder()
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['held-name', h])
    const err = await refused('DELETE FROM holders WHERE id = $1', [h])
    assert.ok(err)
  })
})

describe('one database, two schemas (N-002)', () => {
  it('has PowerDNS\'s own tables beside ours', async () => {
    const { rows } = await db.query(`
      SELECT table_name FROM information_schema.tables
       WHERE table_schema = 'public'
         AND table_name IN ('domains', 'records', 'cryptokeys', 'tsigkeys',
                            'holders', 'names', 'tombstones', 'reserved_names')`)
    assert.equal(rows.length, 8, 'the two schemas are not both here')
  })

  it('writes a name and its record in one transaction', async () => {
    // The property N-004 is about: because the two schemas share a database,
    // issuing a name and publishing its record is a transaction. If it were two
    // services, this test would be a distributed one and could not be written.
    const h = await holder()
    await db.query('BEGIN')
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['atomic', h])
    await db.query("INSERT INTO domains (name, type) VALUES ('kolonie.sh', 'NATIVE')")
    await db.query(`
      INSERT INTO records (domain_id, name, type, content, ttl)
      SELECT id, 'atomic.kolonie.sh', 'A', '203.0.113.9', 300 FROM domains WHERE name = 'kolonie.sh'`)
    await db.query('ROLLBACK')

    const { rows } = await db.query("SELECT count(*)::int AS n FROM records WHERE name = 'atomic.kolonie.sh'")
    assert.equal(rows[0].n, 0, 'the rollback did not reach both schemas')
    await db.query("DELETE FROM domains WHERE name = 'kolonie.sh'")
  })
})
