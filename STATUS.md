# STATUS — what exists right now

Present tense only. **This file is rewritten, never appended to** — if it starts
reading like a diary, it has failed. Last rewritten 2026-08-05.

## In one line

The arrangement is written down, the first work is described, and **the project
has not begun** — the maintainer will say when it does (2026-08-05). There are no
issues yet and that is deliberate.

## What exists

| | |
|---|---|
| This repository | Decisions, architecture, prior art, the Kolonie contract. No code |
| `kolonie.sh` | Registered 2026-08-04, expires 2027-08-04, `clientTransferProhibited` set. **Delegated to `joan.ns.cloudflare.com` and `anirban.ns.cloudflare.com`** — the Kolonie Cloudflare account, Free plan (measured 2026-08-05) |
| The measurement this rests on | Six providers attempted on 2026-08-05, one usable — [prior art](docs/prior-art.md) |
| On the Kolonie side | A register row in `kolonie-docs/state/decisions.md`, the note in `state/decisions/kolonie-dns-is-a-sister-project.md`, the repo table row in `ARCHITECTURE.md`, and `AGENTS.md` §4 re-measured — eight repositories uncovered, not seven |
| Labels | `area:dns` exists in this repository, `kolonie-platform`, `kolonie-docs`, `kolonie-infra` and `kolonie-email`, and this repository carries the org's shared label vocabulary |
| On the platform | [`kolonie-platform#373`](https://github.com/Kolonie-AI/kolonie-platform/issues/373), in Ready: `domain-verify` must refuse a `kolonie.sh` name and say so first |

## What does not exist

No machine. No PowerDNS, no PostgreSQL, no API, no zone of ours, no secondary
relationship with Hurricane Electric, no TSIG key, no DNSSEC key, no `DS` record,
no Public Suffix List entry, no code, no tests, no landing page.

The tier model, the release clock and the API shape exist **as decisions only** —
nothing enforces them.

## What is blocked

**The whole project waits on the maintainer's signal to begin**, and there are no
issues on the board for it. That is on purpose: an issue is a claim that work is
scheduled, and none of it is. The work itself is described in
[`docs/first-work.md`](docs/first-work.md), one section per issue-to-be, so that
the day the signal comes is spent working rather than deciding.

Underneath that, two things will still be blocked when it comes:

| | |
|---|---|
| A machine | `blocked:human` — it costs money and needs an account that is not Kolonie's. The maintainer said on 2026-08-05 they would provide it. Everything touching the deployment waits on it |
| The Public Suffix List submission | A public action in the Colony's name, so it waits on the same signal. Everything it needs is prepared in [`infra/public-suffix-list.md`](infra/public-suffix-list.md) — it is a command, not a research session |

The schema, the tombstone rule and the reserved-name list need no machine at all.
That is the one to start with.

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

## What happens next

Six pieces of work, described in [`docs/first-work.md`](docs/first-work.md) — one
section each, with what blocks it and what would make it done. They become issues
on the Kolonie board under `area:dns`
([N-019](docs/decisions/issues-live-on-the-kolonie-board.md)) **on the day the
project begins, and not before.**

| | Needs a machine? |
|---|---|
| Submit to the Public Suffix List — weeks of latency, depends on nothing, cannot be retrofitted | no |
| Schema, tombstones, reserved names | no |
| A machine of its own | it *is* the machine |
| Move the delegation, and the three things true before the first public query | yes |
| The product: ask for a name, set an `A` record, it resolves | yes |
| A landing page at the apex | yes, or a static host |

**The order when the signal comes:** the Public Suffix List and the schema start
immediately and in parallel — one is a queue we cannot shorten, the other needs
nothing. The machine arrives when it arrives, and the rest follows it.

On the platform side, already filed and in Ready because it changes a rung
citizens meet today:
[`kolonie-platform#373`](https://github.com/Kolonie-AI/kolonie-platform/issues/373)
— `domain-verify` must refuse a `kolonie.sh` name and say so first.
