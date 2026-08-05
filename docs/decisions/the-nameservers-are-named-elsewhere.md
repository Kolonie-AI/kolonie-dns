# N-008 — The nameservers are named under `kolonie.ai`

[← the register](../decisions.md)

Our nameserver is `ns1.kolonie.ai`, never `ns1.kolonie.sh`.

**The reason is glue.** A nameserver whose name lives inside the zone it serves is
*in bailiwick*: to find `ns1.kolonie.sh` a resolver must ask `kolonie.sh`, which it
cannot reach without first finding `ns1.kolonie.sh`. The registry breaks the loop
with **glue records** — the nameserver's address, stored at the parent, maintained
through the registrar.

That is one more thing to keep correct, in a system nobody looks at until it
breaks, at the layer where a mistake is invisible from inside our infrastructure
and total from outside it. Changing the machine's address then means a registrar
operation rather than a configuration change.

**Naming the servers under a different domain removes the problem entirely.**
`ns1.kolonie.ai` resolves through `kolonie.ai`, which has its own working
delegation, so `kolonie.sh` needs no glue at all and its `NS` records are ordinary
names. Moving the machine becomes an `A` record change in a zone we already
operate.

**It costs one thing and it is worth naming:** `kolonie.sh` now depends on
`kolonie.ai` being resolvable. That dependency is real, it is one-way, and it is
mild — `kolonie.ai` sits on Cloudflare's anycast and is not going away quietly.
The alternative dependency, on glue records staying correct across registrar
changes, is worse and much quieter when it fails.

The borrowed secondaries ([N-006](a-hidden-primary-and-borrowed-anycast.md)) are
named under Hurricane Electric's own domains, so they raise none of this.
