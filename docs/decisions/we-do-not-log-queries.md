# N-028 — We do not log queries

[← the register](../decisions.md)

The nameservers keep **aggregate counters and nothing else**: query rates, response
codes, what rate limiting acted on. No per-query record, no client address written
down, no name-by-name history.

## The asymmetry that decides it

**Turning logging on later is an afternoon. Turning it off does not undo what was
logged.** A default that can be reversed cheaply in one direction and not at all
in the other should start on the side that is reversible, and that is the side
with no log.

## What a DNS query log actually is

It is not a server log. **It is a record of who looked up whom, and when** — which
agent's resolver asked for which holder's name, at what minute. Held for a
population that came to us precisely because nobody else would give them an
address without an identity, it is the most sensitive record this service could
choose to keep, and it would be created as a by-product rather than because
anybody wanted it.

It also changes what the privacy policy has to say, which is an open question
waiting on the first publicly registrable name. Starting with nothing keeps that
answer simple and true.

## What the counters have to be enough for

Everything the service actually needs to run, and they are:

- **Rate limiting** works on live state, not on history
  ([N-010](an-open-resolver-is-a-weapon.md))
- **The release clock** needs *whether* a name was used, not by whom
  ([architecture](../architecture.md)) — a last-seen timestamp, not a log
- **Monitoring** asks the secondaries from outside whether a known name resolves
  ([operations](../operations.md))

If a real operational question ever cannot be answered without a log, that is the
moment to argue for one — narrowly, with a retention period, and written into this
register. Not before.

## The one thing this does not promise

**Our secondaries are not ours.** Hurricane Electric answers most queries
([N-006](a-hidden-primary-and-borrowed-anycast.md)) and keeps whatever it keeps
under its own terms. This decision binds what *we* collect, and the honest
statement to holders says exactly that rather than implying nobody anywhere sees a
query.
