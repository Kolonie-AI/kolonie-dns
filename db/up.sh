#!/bin/bash
# Bring up PostgreSQL 16 and PowerDNS, migrated and ready, and print what the
# tests need.
#
# Usage: npm run db:up
#
# It prints two `export` lines on stdout and nothing else, which is the shape
# `opencode-worker.sh exports` reads: the check prerequisite in `AGENTS.md` §9 is
# this command, and the worker runs the check with the environment it emits.
# Everything chatty goes to stderr.
#
# ## The order is the whole of this file
#
# **PowerDNS starts after the migrations, not with them.** It fills its zone
# cache at startup by selecting from `domains`, and a `domains` that does not
# exist yet is a fatal error rather than an empty result — measured 2026-08-11:
# `PDNSException while filling the zone cache … relation "domains" does not
# exist`, container exited 1. Composing the two services with `depends_on` alone
# gets this wrong every time, because what PowerDNS waits for is the database
# accepting connections and what it needs is the schema.
#
# **The reset is here rather than in `npm test`.** Dropping the schema out from
# under a running PowerDNS leaves it holding prepared statements against tables
# that no longer exist. The tests clean up after themselves, so a second `npm
# test` against a stack that is already up is correct without one.

set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
COMPOSE=("docker" "compose" "-f" "$HERE/docker-compose.yml")

export DATABASE_URL="postgres://kolonie_dns:postgres@127.0.0.1:5434/kolonie_dns"
export PDNS_ADDRESS="127.0.0.1:5354"

{
  "${COMPOSE[@]}" down -v
  "${COMPOSE[@]}" up -d --wait postgres
} >&2

node "$HERE/migrate.mjs" --reset >&2

"${COMPOSE[@]}" up -d --wait pdns >&2

# PowerDNS has no healthcheck of its own — the image carries no `dig` to write
# one with — so it is given a moment to bind its socket. Two seconds rather than
# a retry loop, because the failure this guards against is a race of
# milliseconds and a loop around it would hide a real refusal to start.
sleep 2

echo "export DATABASE_URL=$DATABASE_URL"
echo "export PDNS_ADDRESS=$PDNS_ADDRESS"
