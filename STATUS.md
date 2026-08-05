# STATUS — what exists right now

Present tense only. **This file is rewritten, never appended to** — if it starts
reading like a diary, it has failed. Last rewritten 2026-08-05.

## In one line

The arrangement is written down, the domain is registered and pointing at the
wrong nameservers, nothing is built, and nothing can be deployed until a machine
exists.

## What exists

| | |
|---|---|
| This repository | Decisions, architecture, prior art, the Kolonie contract. No code |
| `kolonie.sh` | Registered 2026-08-04, expires 2027-08-04, `clientTransferProhibited` set. **Delegated to `joan.ns.cloudflare.com` and `anirban.ns.cloudflare.com`** — the Kolonie Cloudflare account, Free plan (measured 2026-08-05) |
| The measurement this rests on | Six providers attempted on 2026-08-05, one usable — [prior art](docs/prior-art.md) |
| On the Kolonie side | Nothing yet. No register row, no `area:dns` label, no note in `ARCHITECTURE.md` |

## What does not exist

No machine. No PowerDNS, no PostgreSQL, no API, no zone of ours, no secondary
relationship with Hurricane Electric, no TSIG key, no DNSSEC key, no `DS` record,
no Public Suffix List entry, no code, no tests, no landing page.

The tier model, the release clock and the API shape exist **as decisions only** —
nothing enforces them.

## What is blocked

**Everything that touches the deployment is blocked on a machine**, which is a
maintainer action: it costs money and it needs an account that is not Kolonie's
([N-020](docs/decisions/separate-in-every-account.md)).

Not blocked on it: the schema, the API shape, the reserved-name list, the tests
against a local PowerDNS, and the Public Suffix List submission — which should
start first, because it is the only item measured in weeks.

## What is decided

All of it is in [the register](docs/decisions.md), N-001 to N-023. The five that
shape everything else:

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

Six questions are open on purpose and are listed at the bottom of the register.

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

1. **Submit `kolonie.sh` to the Public Suffix List.** Weeks of latency, no
   dependency on anything else, and it cannot be retrofitted
   ([N-016](docs/decisions/names-are-the-only-real-abuse-surface.md))
2. **A machine**, which is the maintainer's to authorise
3. **Move the delegation off Cloudflare** to our own nameservers, named under
   `kolonie.ai` ([N-008](docs/decisions/the-nameservers-are-named-elsewhere.md))
4. **The write path**, which is the whole product: ask for a name → set an `A`
   record → it resolves, with rate limiting and DNSSEC on before the first public
   query
5. **Two issues on the Kolonie platform**, not here: the `domain-verify` rung must
   refuse a `kolonie.sh` name and say so
   ([the interface](docs/interface-kolonie.md))

Nothing in 1–5 is written as an issue yet. That is the next piece of work on this
repository, and only step 2 is blocked.
