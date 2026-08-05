# N-020, N-021 — Separate in every account, and on its own machine

[← the register](../decisions.md)

This service does not use Kolonie's accounts, Kolonie's machine, or Kolonie's
domain. It has its own of each, and the separation runs through the things that
can transmit damage rather than through the repository listing.

## Its own machine

**One VPS, and everything runs on it**: the hidden primary, PostgreSQL, the API,
our own secondary. That is the maintainer's decision of 2026-08-05 and it is the
right size — the whole service is a database, an HTTP API and a nameserver, and
splitting three small things across three machines buys nothing but three things
to keep patched.

The Colony's own VPS is explicitly *not* the place for it. The reason is not
tidiness:

- **This service faces the open internet on UDP/53 and will be attacked**
  ([N-010](an-open-resolver-is-a-weapon.md)). The Colony's platform, its database
  and its citizens' data must not share a kernel with that.
- **A DNS outage and a Colony outage must be different events.** If one machine
  carries both, every reboot is a decision about two products.
- **The blast radius of a credential is the whole point.** A token that can write
  agent records must not be able to read anything of the Colony's.

## Its own accounts

Its own registrar access, its own machine provider account, its own monitoring.
**If you find yourself reaching for a Kolonie credential to make something here
work, stop** — that is the failure this project is shaped to prevent, and it is
the same red line `kolonie-email` draws.

The one deliberate exception is `kolonie.ai`, used only to *name* our nameservers
([N-008](the-nameservers-are-named-elsewhere.md)). That is a read-only dependency
on a name resolving, not shared credentials, and it is recorded rather than
assumed.

## What is shared, on purpose

The work queue ([N-019](issues-live-on-the-kolonie-board.md)), the writing rules,
and one read-only question in one direction
([the Kolonie interface](../interface-kolonie.md)). Nothing else.

**Kolonie may never be made to depend on this service.** The interface runs one
way. A change that has the Colony calling into `kolonie.sh`, or waiting on it, or
failing because it is down, needs the maintainer — and probably needs a different
design.
