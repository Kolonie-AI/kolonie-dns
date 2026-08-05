# Operations

What running a DNS service obliges us to, beyond running a service. Read this
before deploying anything; most of it cannot be added afterwards without an
outage or an incident.

## The obligation nobody signs up for

**Authoritative DNS does not degrade. It vanishes.**

A slow web service is a slow web service. A nameserver that stops answering takes
every name under it with it — every website, every certificate renewal, every
webhook, for every holder, at once, with no error message anybody can read. There
is no partial failure and no graceful mode.

That is the whole reason for the hidden primary
([N-005](decisions/a-hidden-primary-and-borrowed-anycast.md)): the machine we are
most likely to break is not the machine anybody queries. Deploys, migrations, a
full disk, a bad release — none of them reach the public secondaries, which keep
serving the last transferred copy.

**It follows that the deploy story is unusually simple and must stay that way.**
Restarting the API is invisible. Restarting the primary is invisible. The only
operation with public consequence is a zone transfer, and that is the one to be
careful with.

## The three things that must be true before the first public query

1. **Response Rate Limiting is on and has been seen limiting something**
   ([N-010](decisions/an-open-resolver-is-a-weapon.md)) — observed with a moving
   counter, not merely present in a config file.
2. **`AXFR` is restricted to the secondaries and signed with TSIG.** An open
   transfer publishes every holder's name in a single request.
3. **At least two nameservers answer, on networks that do not fail together.**
   The registrar requires two; the reason is survivability, not paperwork.

## DNSSEC, and the one part we do not control

PowerDNS signs live, so the signing itself is a configuration flag. What is not
in our hands is the **`DS` record at the registry**: the parent zone must publish
a digest of our key, and only the registrar can put it there.

Two consequences:

- **Key rollover is a registrar operation**, not a deploy. Plan it, do not
  discover it.
- **A botched rollover is worse than no DNSSEC at all.** Validating resolvers will
  refuse answers they cannot verify, which is a total outage with a cause that is
  invisible from inside our infrastructure. Rehearse it before the first
  production key ages.

Whether the registrar's `DS` management can be automated is an open question in
the register and is worth answering before it becomes urgent.

## Monitoring: what actually tells you the truth

**Ask the secondaries, from outside, for a name you know.** That is the only check
that answers the real question. Every other signal — the process is up, the
database is reachable, the API returns 200 — can be green while the world gets
nothing.

Three more worth having, in order of how quietly they fail:

| Check | Fails quietly because |
|---|---|
| Zone serial on each secondary matches the primary | A transfer that stopped working looks exactly like a zone that has not changed |
| Time until the `DS`/`DNSKEY` pair diverges | Nothing warns you; validating resolvers simply start refusing |
| Free-secondary reachability from a second network | Our own monitoring lives on our own network, which is the one that is fine |

**A stopped transfer is the characteristic failure of this design**, so it gets its
own check. Everything else is the same operations work as any service.

## Abuse

**The address side is not our business.** A record points at an address; addresses
are public facts, and we never see what is served there
([N-018](decisions/we-terminate-nothing.md)).

**The name side is.** A name that impersonates is the one thing this service can
actually do harm with, which is why non-citizens do not choose theirs
([N-015](decisions/names-are-the-only-real-abuse-surface.md)). Take-down is a
decision about a name, taken against the Colony's red lines, and it is recorded
where the next person can read the reason.

**Prepare to be a reflection source in somebody else's report.** Even with rate
limiting, an authoritative server occasionally appears in an abuse complaint
because its answers were sent to a forged address. There should be an address that
answers such a complaint and a person willing to read it before anybody sends one.

## Backups

The database is the service. PowerDNS's tables *are* the zone, so a lost database
is a lost zone — and, unusually, **the secondaries hold a copy of the answer but
not of the ownership**. A restore that recovers records without recovering who
holds them is not a restore.

## Cost

Two to three small machines and a domain. Measured 2026-08-05: roughly
**10–15 €/month total**, against 20 $/month for the Cloudflare Pro plan that would
have capped at ~3500 records ([N-001](decisions/no-cloudflare.md)). The free
secondaries cost nothing and are the reason the figure is that low.
