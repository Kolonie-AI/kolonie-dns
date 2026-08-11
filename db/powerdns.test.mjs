// A record written through the database is answered by a real PowerDNS.
//
// Run: DATABASE_URL=… PDNS_ADDRESS=127.0.0.1:5354 node --test db/
//
// ## Why a real nameserver and not a mock
//
// `docs/architecture.md`'s load-bearing claim is that the API and the nameserver
// are separate programs sharing a database, so *"a bug in the API cannot stop
// the zone answering"* (N-004). A mock of PowerDNS would assert that about the
// mock. This asserts it about PowerDNS 4.9 reading the same rows the schema
// tests write — which is also the first time anything in this project has
// answered a DNS query at all.
//
// ## It does not skip itself
//
// `operations/testing.md` on the Kolonie side: *"a suite that skips them
// silently reports green while covering nothing."* If `PDNS_ADDRESS` is unset
// this fails and says which command brings the server up.

import { after, before, describe, it } from 'node:test'
import assert from 'node:assert/strict'
import { Resolver } from 'node:dns/promises'
import pg from 'pg'
import { migrate } from './migrate.mjs'

const url = process.env.DATABASE_URL
const address = process.env.PDNS_ADDRESS

if (!url || !address) {
  throw new Error(
    'DATABASE_URL and PDNS_ADDRESS are both required. `npm run db:up` starts ' +
    'PostgreSQL 16 and PowerDNS together and prints both.')
}

const db = new pg.Client({ connectionString: url })
const resolver = new Resolver({ timeout: 2000, tries: 2 })
resolver.setServers([address])

// The zone the tests write into. It is `kolonie.sh` because that is the zone,
// and it resolves nowhere but this container: the delegation still points at
// Cloudflare (#12) and the hidden primary answers nothing public (N-005).
const ZONE = 'kolonie.sh'

before(async () => {
  await db.connect()
  await migrate(db, { quiet: true })

  await db.query(`
    INSERT INTO domains (name, type) VALUES ($1, 'NATIVE')
    ON CONFLICT (name) DO NOTHING`, [ZONE])

  // The SOA every zone needs before PowerDNS will answer for it. The
  // nameservers are named under `kolonie.ai` and never under `kolonie.sh`
  // (N-008), which is why there are no glue records here to get wrong.
  await db.query(`
    INSERT INTO records (domain_id, name, type, content, ttl)
    SELECT id, $1::varchar, 'SOA', 'ns1.kolonie.ai. hostmaster.kolonie.ai. 1 10800 3600 604800 300', 300
      FROM domains WHERE name = $1`, [ZONE])
})

after(async () => {
  await db.query('DELETE FROM records; DELETE FROM domains;')
  await db.end()
})

describe('a name resolves through PowerDNS', () => {
  it('answers an A record written beside the name row, in one transaction', async () => {
    const { rows } = await db.query(
      "INSERT INTO holders (tier, key_hash) VALUES ('free', 'hash') RETURNING id")
    const holder = rows[0].id

    await db.query('BEGIN')
    await db.query('INSERT INTO names (label, holder_id) VALUES ($1, $2)', ['resolves', holder])
    await db.query(`
      INSERT INTO records (domain_id, name, type, content, ttl)
      SELECT id, $1, 'A', $2, 300 FROM domains WHERE name = $3`,
      [`resolves.${ZONE}`, '203.0.113.9', ZONE])
    await db.query('COMMIT')

    const answer = await resolver.resolve4(`resolves.${ZONE}`)
    assert.deepEqual(answer, ['203.0.113.9'])
  })

  it('answers a TXT record, which is what DNS-01 needs (N-018)', async () => {
    // The whole of *we terminate nothing*: a holder obtains its own certificate
    // through a `TXT` write when port 80 is not reachable. If this stops
    // working, the argument for having no proxy stops holding.
    await db.query(`
      INSERT INTO records (domain_id, name, type, content, ttl)
      SELECT id, $1, 'TXT', $2, 60 FROM domains WHERE name = $3`,
      [`_acme-challenge.dns01.${ZONE}`, '"a-challenge-token"', ZONE])

    const answer = await resolver.resolveTxt(`_acme-challenge.dns01.${ZONE}`)
    assert.deepEqual(answer.flat(), ['a-challenge-token'])
  })

  it('answers nothing for a label nobody holds', async () => {
    await assert.rejects(
      () => resolver.resolve4(`never-issued.${ZONE}`),
      (err) => err.code === 'ENOTFOUND' || err.code === 'ENODATA')
  })
})
