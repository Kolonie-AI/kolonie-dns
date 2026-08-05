# N-010 — Rate limiting is configured before the server is reachable

[← the register](../decisions.md)

Response Rate Limiting is on from the first query, not added after the first
incident.

**An authoritative nameserver on the open internet is an amplifier.** DNS answers
over UDP are larger than the questions that provoke them, and the source address
of a UDP packet is whatever the sender says it is. An attacker sends small queries
with a victim's address in them and we send the victim the large answers. The
victim is attacked with our bandwidth and our reputation, and we look like the
attacker to everyone measuring it.

DNSSEC makes this worse rather than better: signed answers are considerably larger
than unsigned ones, so [N-009](../decisions.md) raises the amplification factor at
the same time as it raises the service's quality. The two decisions belong
together and are written down together for that reason.

**PowerDNS has RRL built in**, so this is configuration rather than development —
which is exactly why it must not be deferred. There is no work saved by leaving it
out, only exposure gained.

**The rule for this repository:** the server does not receive its first public
query until rate limiting is set and has been observed limiting something. Not
*"configured"* in the sense of a line in a file nobody tested — observed, with the
counter moving, in the same session it is switched on.

Three neighbours of this decision, recorded here so they are found together:

- **`ANY` queries are refused or minimised.** They are the classic amplification
  lever and no legitimate client needs one.
- **Zone transfers are restricted to the secondaries' addresses and signed with
  TSIG** ([N-005](a-hidden-primary-and-borrowed-anycast.md)). An open `AXFR`
  publishes every holder's name in one request.
- **We publish no `CAA`, `SPF` or anything else at the zone apex by reflex.** The
  apex is shared by every holder, and a record there is a statement on behalf of
  all of them.
