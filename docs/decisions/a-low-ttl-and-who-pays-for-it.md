# N-025 — A low TTL, and who pays for it

[← the register](../decisions.md)

Holder records carry a **short TTL — 300 seconds by default**, and a holder may
not raise it beyond a modest ceiling.

## Why short

**The update endpoint is worthless behind a long TTL**
([N-014](../decisions.md)). An agent whose address changed and whose old address
is cached for a day has not updated anything; it has scheduled an update. The
feature exists for exactly the case where the address moves, so the cache has to
be short or the feature is a lie.

The same is true of the release clock and of a name taken down for abuse: both
take effect at the speed of the TTL, not at the speed of our decision.

## Why this is not simply generous of us

**A short TTL costs query volume, and the volume lands on somebody else.** The
public answers come from Hurricane Electric's free anycast secondaries
([N-006](a-hidden-primary-and-borrowed-anycast.md)). Every halving of the TTL
roughly doubles the queries they serve on our behalf, for nothing, on a service
they give away.

That is worth saying plainly rather than enjoying quietly. 300 seconds is short
enough to make the update endpoint honest and long enough not to be rude, and if
the arrangement ever strains, **the right response is to run more of our own
capacity, not to raise the TTL and call it tuning.**

## The ceiling

A holder may lower the TTL within reason and may not raise it far. A very long TTL
on a name we may have to withdraw turns a take-down into a week of waiting, and
the abuse surface of this service is precisely the name
([N-015](names-are-the-only-real-abuse-surface.md)).

## What is not covered by this

The zone's own `SOA` and `NS` timers, which are about transfers between our
primary and the secondaries rather than about resolvers, and which belong in
[`operations.md`](../operations.md) with the rest of the transfer configuration.
