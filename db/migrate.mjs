#!/usr/bin/env node
// Apply every migration in `migrations/`, in name order, and load the
// reserved-name list.  `kolonie-dns#11`.
//
// Usage: DATABASE_URL=… node db/migrate.mjs [--reset]
//
// ## Why this is JavaScript in a project whose API is TypeScript (N-004)
//
// The deliverable here is SQL.  This file exists to put it into a database and
// to be the same command in a test, in CI and on the machine — about a hundred
// lines, run by hand and by two workflows.  A build step for it would be the
// first thing to rot, and the API can bring its own toolchain when it arrives
// (#13) without this having an opinion about it.
//
// ## The migration table is deliberately small
//
// One row per file, with the filename as the key.  No checksums: a migration
// that has been edited after it ran is a mistake this cannot fix and should not
// hide, and on a project with no production database yet, `--reset` is the
// honest answer to it.  When there is one, this grows a checksum column and a
// refusal — not before, because a refusal nobody has ever seen fire is a
// refusal nobody should trust.

import { readdir, readFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import pg from 'pg'

const HERE = dirname(fileURLToPath(import.meta.url))

export async function migrate(client, { reset = false, quiet = false } = {}) {
  const say = (m) => { if (!quiet) console.log(m) }

  if (reset) {
    // Everything this project owns, and PowerDNS's own tables with it.  They
    // share the database on purpose (N-002), so resetting one and not the other
    // would leave a half-schema that fails somewhere less obvious.
    await client.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;')
    say('reset: schema public dropped and recreated')
  }

  await client.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      filename   text PRIMARY KEY,
      applied_at timestamptz NOT NULL DEFAULT now()
    )`)

  const files = (await readdir(join(HERE, 'migrations')))
    .filter((f) => f.endsWith('.sql'))
    .sort()

  const { rows } = await client.query('SELECT filename FROM schema_migrations')
  const applied = new Set(rows.map((r) => r.filename))

  for (const file of files) {
    if (applied.has(file)) { say(`  = ${file}`); continue }
    const sql = await readFile(join(HERE, 'migrations', file), 'utf8')
    // One transaction per migration, so a failure leaves the database on the
    // last whole migration rather than halfway through this one.
    await client.query('BEGIN')
    try {
      await client.query(sql)
      await client.query('INSERT INTO schema_migrations (filename) VALUES ($1)', [file])
      await client.query('COMMIT')
      say(`  + ${file}`)
    } catch (err) {
      await client.query('ROLLBACK')
      throw new Error(`${file}: ${err.message}`, { cause: err })
    }
  }

  const count = await loadReservedNames(client)
  say(`  + reserved-names.tsv (${count} labels)`)
  return { applied: files.length, reserved: count }
}

// **Loaded as a replacement, not an append.**  The file is the list; the table
// is a copy of it.  Deleting a line here has to release the label, or the file
// stops being the place a maintainer answers *why was this refused* and becomes
// a place where half the answer lives.
export async function loadReservedNames(client) {
  const text = await readFile(join(HERE, 'reserved-names.tsv'), 'utf8')
  const entries = []
  let lineNumber = 0

  for (const line of text.split('\n')) {
    lineNumber += 1
    if (!line.trim() || line.startsWith('#')) continue
    const [label, ...rest] = line.split('\t')
    const reason = rest.join('\t').trim()
    if (!reason) {
      throw new Error(
        `reserved-names.tsv:${lineNumber}: "${label}" has no reason. ` +
        'N-015 is a list rather than a classifier so that a maintainer can ' +
        'answer why with a word — a line without one is the half that fails.')
    }
    entries.push([label.trim(), reason])
  }

  await client.query('BEGIN')
  try {
    await client.query('DELETE FROM reserved_names')
    for (const [label, reason] of entries) {
      await client.query(
        'INSERT INTO reserved_names (label, reason) VALUES ($1, $2)', [label, reason])
    }
    await client.query('COMMIT')
  } catch (err) {
    await client.query('ROLLBACK')
    throw err
  }
  return entries.length
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const url = process.env.DATABASE_URL
  if (!url) {
    console.error('DATABASE_URL is unset. This refuses to guess one — see db/README.md.')
    process.exit(2)
  }
  const client = new pg.Client({ connectionString: url })
  await client.connect()
  try {
    await migrate(client, { reset: process.argv.includes('--reset') })
  } finally {
    await client.end()
  }
}
