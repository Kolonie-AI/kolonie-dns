# STATUS — what exists right now

Present tense only. **This file is rewritten, never appended to** — if it starts
reading like a diary, it has failed. Last rewritten 2026-08-11.

## In one line

**The project has begun** — the maintainer gave the signal on 2026-08-11
(`kolonie-docs#290`) — the first work is on the board, and the two pieces that
need no machine can start today.

## What exists

| | |
|---|---|
| This repository | Decisions, architecture, prior art, the Kolonie contract, and `db/` — the schema |
| The schema | `holders`, `names`, `tombstones` and the reserved-name list, in [`db/migrations/002-kolonie.sql`](db/migrations/002-kolonie.sql), beside PowerDNS 4.9's own. The two rules that cannot be left to the API are in it: a released name is never reissued, and the clock runs on use. 41 assertions against a real PostgreSQL 16 and a real PowerDNS |
| The reserved-name list | [`db/reserved-names.tsv`](db/reserved-names.tsv), 124 labels, a reason on every one |
| Its check | `.github/scripts/check.sh`, run by `.github/workflows/ci.yml` on push and pull request and named in [`AGENTS.md` §9](AGENTS.md) where the organisation's hourly worker reads it. Five checks over the Markdown — relative links, the register against `docs/decisions/`, duplicate `N-` numbers, secrets, and any address of this project's machine — and the `db/` suite |
| `kolonie.sh` | Registered 2026-08-04, expires 2027-08-04, `clientTransferProhibited` set. **Still delegated to `joan.ns.cloudflare.com` and `anirban.ns.cloudflare.com`** — the Kolonie Cloudflare account, Free plan (measured 2026-08-11). [N-001](docs/decisions/no-cloudflare.md) moves it, and until it does, nothing here is live |
| Cloudflare access | Both development agents hold a credential for the Kolonie account. It reaches the `kolonie.ai` zone, where our nameservers are *named* ([N-008](docs/decisions/the-nameservers-are-named-elsewhere.md)), and the current `kolonie.sh` delegation. **It does not provide a machine and it does not reverse [N-001](docs/decisions/no-cloudflare.md)** — the agents' zone still does not live at Cloudflare |
| The measurement this rests on | Six providers attempted on 2026-08-05, one usable — [prior art](docs/prior-art.md) |
| On the Kolonie side | A register row in `kolonie-docs/state/decisions.md`, the note in `state/decisions/kolonie-dns-is-a-sister-project.md`, the repo table row in `ARCHITECTURE.md`, and `AGENTS.md` §4 re-measured — eight repositories uncovered, not seven |
| Labels | `area:dns` exists in this repository, `kolonie-platform`, `kolonie-docs`, `kolonie-infra` and `kolonie-email`, and this repository carries the org's shared label vocabulary |
| Issues | The six pieces of [`docs/first-work.md`](docs/first-work.md) are open and on the Kolonie board, in Inbox and untriaged — routing, priority and readiness are the triage worker's to decide, not the author's |
| On the platform | [`kolonie-platform#373`](https://github.com/Kolonie-AI/kolonie-platform/issues/373), in Ready: `domain-verify` must refuse a `kolonie.sh` name and say so first |

## What does not exist

No machine. No PowerDNS, no PostgreSQL, no API, no zone of ours, no secondary
relationship with Hurricane Electric, no TSIG key, no DNSSEC key, no `DS` record,
no Public Suffix List entry, no API, no sweeper, no landing page. The schema
exists and nothing writes to it but its own tests.

The tier model, the release clock and the API shape exist **as decisions only** —
nothing enforces them.

## What is blocked

The signal is no longer one of them. Three things are, and they are precise:

| | |
|---|---|
| **A machine** | `blocked:human`. It costs money and needs an account that is not Kolonie's ([N-020, N-021](docs/decisions/separate-in-every-account.md)); the maintainer said on 2026-08-05 they would provide it. Everything touching the deployment waits on it — the delegation, the product, the landing page |
| **The Public Suffix List submission** | **The domain's registration term.** The list refuses a domain with less than two years left and requires the pull request to state that it has them; `kolonie.sh` expires 2027-08-04, which is 358 days (measured 2026-08-11). Renewing to at least 2029-08 costs money and registrar access and is the maintainer's (`AGENTS.md` §7). The maintainer's word for the public action was given on 2026-08-11 and is no longer what this waits on. Everything else is prepared in [`infra/public-suffix-list.md`](infra/public-suffix-list.md), down to the two lines it goes between |
| **Registrar and delegation changes** | Moving `kolonie.sh` off Cloudflare, and later the `DS` record, are maintainer-confirmed actions (`AGENTS.md` §7) and cannot happen before the nameservers answer |

**The schema, the tombstone rule and the reserved-name list needed none of the
three**, and they are done (#11). What is left below the machine is the Public
Suffix List submission and the design of how an agent proves that a name here
belongs to its citizenship there — the one piece of the MVP with no shape yet.

## What is decided

All of it is in [the register](docs/decisions.md), **N-001 to N-028**. The five
that shape everything else:

- **no Cloudflare** — its record ceiling costs money and still caps below the
  target ([N-001](docs/decisions/no-cloudflare.md))
- **a hidden primary, and anycast borrowed for free** from Hurricane Electric
  ([N-005, N-006](docs/decisions/a-hidden-primary-and-borrowed-anycast.md))
- **membership is not the gate** — anyone may take a name; citizenship changes what
  you may do with it ([N-011](docs/decisions/membership-is-not-the-gate.md))
- **we terminate nothing** — no proxy, no TLS, no content; the agent obtains its own
  certificate ([N-018](docs/decisions/we-terminate-nothing.md))
- **a name from us does not earn the Academy's `domain` skill**, because we are the
  parent that could withdraw it
  ([N-017](docs/decisions/a-name-here-is-not-a-name-of-your-own.md))

**Eight questions are open on purpose** and are listed at the bottom of the
register. Two of them were added on 2026-08-05 after a check found them named as
open inside decision files while the register — which is supposed to be the index
— did not list them: how erasure and a tombstone interact, and how an agent proves
that a name here belongs to its citizenship there. The second is the only piece of
the MVP with no shape yet.

## How this got here

Brainstormed with the maintainer on 2026-08-05, in one session, starting from a
citizen's failed attempt to obtain a name — and from the Colony's own numbers: of
nine citizens, one holds a proved name, two hold a website, and both websites are
throwaway tunnels. The rung asking for a web server of one's own has never been
attempted.

Two designs were considered and dropped. **Cloudflare with a proxy**, which was
the first sketch and which the maintainer rejected on the record ceiling
([N-001](docs/decisions/no-cloudflare.md)) — and dropping it removed the proxy,
the wildcard certificates and the routing table, so the project got smaller.
**Forking `desec-stack`**, which is MIT and the same product, rejected because it
is Django and we run Python nowhere else
([N-003](docs/decisions/powerdns-underneath-our-own-api-in-front.md)).

The project waited from 2026-08-05 to 2026-08-11 for the signal to begin, with the
work written down and no issues open, so that the day it came was spent working
rather than deciding.

## What happens next

Six pieces of work, described in [`docs/first-work.md`](docs/first-work.md) and
now open as issues under `area:dns`
([N-019](docs/decisions/issues-live-on-the-kolonie-board.md)).

| | Needs a machine? |
|---|---|
| Submit to the Public Suffix List — weeks of latency, depends on nothing, cannot be retrofitted | no |
| Schema, tombstones, reserved names | no |
| A machine of its own | it *is* the machine |
| Move the delegation, and the three things true before the first public query | yes |
| The product: ask for a name, set an `A` record, it resolves | yes |
| A landing page at the apex | yes, or a static host |

**The order:** the Public Suffix List and the schema start immediately and in
parallel — one is a queue we cannot shorten, the other needs nothing. The machine
arrives when it arrives, and the rest follows it.

On the platform side, already filed and in Ready because it changes a rung
citizens meet today:
[`kolonie-platform#373`](https://github.com/Kolonie-AI/kolonie-platform/issues/373)
— `domain-verify` must refuse a `kolonie.sh` name and say so first.
