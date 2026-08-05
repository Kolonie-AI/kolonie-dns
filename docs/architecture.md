# Architecture

The shape the [decisions](decisions.md) add up to. Nothing here is a new decision;
if this document and the register disagree, the register is right.

## The whole thing, on one machine

```
                      ┌──────────────────────── our VPS ────────────────────────┐
                      │                                                          │
   agent ──HTTPS──────┼──▶  API (TypeScript)                                     │
   writes a record    │        │                                                 │
                      │        ▼                                                 │
                      │    PostgreSQL  ◀──reads──  PowerDNS Authoritative        │
                      │                             (hidden primary)             │
                      │                                  │                       │
                      └──────────────────────────────────┼───────────────────────┘
                                                         │ AXFR / NOTIFY, TSIG
                                          ┌──────────────┴──────────────┐
                                          ▼                             ▼
                              Hurricane Electric              our own secondary
                              ~24 anycast PoPs, free
                                          │                             │
                                          └──────────┬──────────────────┘
                                                     ▼
                                          the world's resolvers
```

Four pieces, and the split between them is the load-bearing part:

| Piece | Knows about | Does not know about |
|---|---|---|
| **API** | citizens, tiers, reserved names, quotas, the 30-day clock | how a query is answered |
| **PostgreSQL** | records, holders, tombstones | — |
| **PowerDNS** | records | Kolonie, tiers, holders, anything |
| **Secondaries** | a copy of the zone | everything else |

**A bug in the API cannot stop the zone answering.** Names already published keep
resolving; only new writes fail. That property is the reason the API and the
nameserver are separate programs sharing a database rather than one program
([N-004](decisions/powerdns-underneath-our-own-api-in-front.md)).

## What an agent actually does

1. **Ask for a name.** Anonymous callers are assigned one; citizens choose
   ([N-012](decisions/membership-is-not-the-gate.md)).
2. **Get a key.** Hashed at rest, rotatable, not the name's identity.
3. **Write a record.** `A`, `AAAA` or `TXT` on the free tier; anything the zone
   supports for citizens.
4. **Or send a heartbeat.** A dynDNS-shaped update URL that sets the `A` record to
   the caller's own address, for agents whose address moves
   ([N-014](decisions.md)).
5. **Obtain a certificate.** `HTTP-01` if port 80 is reachable, `DNS-01` through
   the `TXT` write if it is not — which is the case a proxy would have solved and
   this solves better ([N-018](decisions/we-terminate-nothing.md)).

That is the entire product surface. There is no console, no dashboard and no web
UI in the first release.

## The data

Three tables carry the service; everything else is bookkeeping.

| Table | Holds | Note |
|---|---|---|
| `holders` | who holds names, their tier, their hashed key | a holder may or may not be a Kolonie citizen |
| `names` | the label, its holder, when it was issued, when it was last used | uniqueness lives here |
| `tombstones` | labels that have been released | never reissued ([N-013](decisions/a-released-name-is-never-reissued.md)) |

PowerDNS's own tables (`domains`, `records`, `cryptokeys`) sit alongside them in
the same database and are **written only by the API**, never by hand. That the two
schemas share a database is what makes a record write a transaction rather than a
distributed operation.

## Where the clocks are

**One clock, and it runs on use rather than on issuance.** A free-tier name is
released 30 days after it was last used — resolved or written. A citizen's name has
no clock at all.

*Last used* is deliberately generous: a name that is answering queries is doing its
job even if its holder has not called the API in months. Measuring only API writes
would release names that are working, which is the failure the whole 30-day rule
exists to avoid causing.

## What runs on a schedule

One sweeper, and it does three things: release names that have passed the clock,
write their tombstones, and refresh cached citizenship answers whose maximum age
has passed ([the Kolonie interface](interface-kolonie.md)).

**Retention that arrives after the data does is a migration rather than a policy**,
so the sweeper is built with the first release and not after it.

## What is not here, on purpose

- **No proxy, no TLS termination, no traffic path**
  ([N-018](decisions/we-terminate-nothing.md))
- **No zone per agent** ([N-007](decisions/one-zone.md))
- **No bring-your-own-domain.** A different product; listed as open in the register
- **No console.** The API is the interface an agent sees; a landing page is
  marketing, not product
- **No anycast of our own.** Borrowed, for now
  ([N-006](decisions/a-hidden-primary-and-borrowed-anycast.md))

## The MVP

Ask for a name → set an `A` record → it resolves. Plus the update URL, DNSSEC and
rate limiting, because the last two are configuration and the first is twenty
lines.

Explicitly not in it: console, web UI, `MX` and mail routing, zone transfer for
somebody else's domain, and any part of the tier system beyond the free/citizen
split the schema already needs.
