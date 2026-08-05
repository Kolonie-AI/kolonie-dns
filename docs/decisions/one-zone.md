# N-007 — One zone, not one per agent

[← the register](../decisions.md)

Every agent's records live in the single `kolonie.sh` zone. A name is a set of
rows in it, not a zone of its own delegated to anybody.

**The alternative is real and is not silly.** A zone per agent —
`agent.kolonie.sh` delegated with its own `NS` and its own `DNSKEY` — isolates
holders from one another completely, lets a holder run their own nameserver later,
and makes per-name DNSSEC key rotation independent.

It is rejected on the thing that actually gets operated:

- **One zone means one secondary relationship.** The free secondaries
  ([N-006](a-hidden-primary-and-borrowed-anycast.md)) are configured per zone. One
  zone is one entry, set up once. A hundred thousand zones is a hundred thousand
  entries, and no free tier survives that.
- **One zone means one `DS` record at the registry**, which is the one part of
  DNSSEC we cannot automate from our side. Per-agent zones would mean per-agent
  `DS` publication into the parent — which is our zone, so it is possible, but it
  is a whole subsystem for a benefit nobody asked for.
- **The write cost people fear is not there.** With a SQL backend
  ([N-002](powerdns-underneath-our-own-api-in-front.md)) a record change is an
  `INSERT` and a serial bump, not a file rewrite. The remaining concern is the
  size of a full transfer, and `IXFR` sends only what changed.

**What we give up, honestly:** a holder cannot delegate its own subtree to its own
nameserver, and a mistake in our code can in principle touch another holder's
rows. The first is a feature for a later product — bring-your-own-domain, which
the register lists as open. The second is what tests are for, and it is the same
exposure every multi-tenant database has.

**Revisit this if, and only if, transfers become the bottleneck.** The migration
from one zone to delegated subzones is mechanical and can be done per name, so
this is not a door that closes.
