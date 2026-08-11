# db/

Schema and migrations. Ours and PowerDNS's own tables share one database, which
is what makes a record write a transaction — see
[`../docs/architecture.md`](../docs/architecture.md).

## Bring it up and run the tests

```bash
npm ci
eval "$(npm run --silent db:up)"   # PostgreSQL 16 and PowerDNS, migrated
npm test
```

`db:up` throws the containers away and rebuilds them, so it is also how you get
back to a clean database. `npm run db:down` puts them away.

Nothing here reaches the machine. The credentials in
[`docker-compose.yml`](docker-compose.yml) are `postgres` in plain sight on a
loopback-bound port, in a container that is discarded; the machine's own live on
the machine and never in this repository (`AGENTS.md` §5).

## What is in here

| | |
|---|---|
| [`migrations/001-powerdns.sql`](migrations/001-powerdns.sql) | PowerDNS 4.9's own schema, taken from the image unmodified. **Do not edit it** — it is upstream's, and a local change to it is one that upgrading silently reverts |
| [`migrations/002-kolonie.sql`](migrations/002-kolonie.sql) | `holders`, `names`, `tombstones`, the reserved-name table, and the two rules the schema encodes rather than leaving to the API |
| [`reserved-names.tsv`](reserved-names.tsv) | The list, with a reason on every line (N-015). Edited by hand; loaded as a replacement, so deleting a line releases the label |
| [`migrate.mjs`](migrate.mjs) | Applies the migrations in name order and loads the list |
| [`up.sh`](up.sh) | The stack, in the order it has to start in |
| [`pdns/pdns.conf`](pdns/pdns.conf) | PowerDNS for the tests, with every cache off. Not the machine's configuration |
| [`schema.test.mjs`](schema.test.mjs) | What the schema refuses |
| [`powerdns.test.mjs`](powerdns.test.mjs) | That a real PowerDNS answers what the database was told |

## The one design decision worth knowing before you read the SQL

**A released name keeps its row in `names`.** The holder is cleared and a
tombstone is written beside it; the row itself never leaves.

That is what makes the uniqueness constraint consider tombstoned labels *by
construction* — the primary key already refuses a label that has ever been taken,
without anybody remembering to look in a second table. N-013 says a released name
is never reissued, and the alternative shape — deleting the row and keeping only
a tombstone — would put uniqueness in two tables with no constraint able to span
them. PostgreSQL cannot express a primary key across two tables, so that version
comes down to a trigger somebody can drop.

There is a test for each half: one for the message a caller gets, and one that
takes the trigger out of play and proves the primary key refuses it anyway.

## What is not here yet

The API (N-004, and [#13](https://github.com/Kolonie-AI/kolonie-dns/issues/13))
and the sweeper that reads `names_due_for_release`. The view is here because the
release rule is a policy, and a policy written into one program is a policy the
second program gets wrong.
