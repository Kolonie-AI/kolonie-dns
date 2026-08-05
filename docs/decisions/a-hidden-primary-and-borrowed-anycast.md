# N-005, N-006 — A hidden primary, and borrowed anycast

[← the register](../decisions.md)

## The shape

```
  API (TypeScript)  ──writes──▶  PostgreSQL  ──▶  PowerDNS  ── AXFR/NOTIFY ──▶  public secondaries
        │                                        (hidden primary)                 │
   agents write here                       answers nobody from outside      agents' resolvers ask here
```

**Nothing on the public internet queries the machine that holds the data.** The
primary is reachable only for zone transfers, to a list of addresses, with TSIG.
Everything the world asks is answered by secondaries that hold a copy and can do
nothing else.

Three things follow, and they are the whole reason for the arrangement:

- **A compromise of the API or the database does not become a DNS outage.** The
  secondaries keep serving the last transferred copy while the primary is
  repaired.
- **The public surface is small and boring.** A server that only answers queries
  has almost no attack surface; a server that also accepts writes has all of ours.
- **Load never reaches us.** A resolution storm hits the secondaries, and they are
  built for it.

deSEC arrived at the same split — their `nslord`/`nsmaster` division exists for
this reason — which is corroboration rather than inspiration; we drew it before
reading theirs.

## Why the secondaries are borrowed

**[Hurricane Electric](https://dns.he.net/) provides free secondary DNS**, and it
is the decision that turns *"we run our own nameservers"* from a serious
undertaking into a weekend. Measured 2026-08-05 from their published service
description: roughly two dozen anycast points of presence, IPv6 throughout, no
artificial zone limit, `NOTIFY` honoured, TSIG supported for the transfer.

That is anycast-grade resolution, on somebody else's global network, for nothing —
which is a better answer than we could build and a considerably better one than we
could afford.

**We still run one secondary of our own.** Not for capacity: for independence. A
service we do not pay for is a service that can change its terms, and a project
whose entire public availability rests on one free tier has a single point of
failure wearing a friendly face. One secondary we control means the free one is
an improvement rather than a dependency.

**A registrar requires at least two nameservers, and that is the floor rather than
the goal.** What actually matters is that no single network, provider or country
takes every answer down at once — which the arrangement above satisfies from the
first day.

## What is deferred

Running our own anycast. It is the professional endgame, it is what deSEC
eventually built, and at our scale it would be a cost with no user-visible effect.
The register keeps it as an open question rather than a plan.
