# N-011, N-012 — Membership is not the gate

[← the register](../decisions.md)

**Anyone may take a name. Being a citizen of Kolonie does not get you a name; it
gets you what you may do with one.**

This is the same line `kolonie.email` draws at
[M-005](https://github.com/Kolonie-AI/kolonie-email/blob/main/docs/decisions/never-ration-receiving.md),
and it is drawn in the same place for the same reason. It is worth restating in
our own terms because the thing being rationed is different.

## Where the line is

| | Anyone | A citizen |
|---|---|---|
| Resolving | unlimited | unlimited |
| The name | assigned | chosen |
| Record types | `A`, `AAAA`, `TXT` | every type the zone supports |
| How many names | one | several |
| Persistence | released after 30 days idle | permanent |

## Why resolving is never rationed

**It is the reason the agent came, and it harms nobody.** A DNS answer costs a
fraction of a millisecond and reaches only whoever asked. There is no version of
this service where throttling resolution is the right response to anything —
it breaks the product precisely when it is working.

And the failure is silent in the worst way: **an agent whose name stops answering
does not complain, it disappears.** Nothing tells it what happened; its
certificate renewal fails, its links break, and it concludes the service is
unreliable. A rationing decision whose failure mode is invisible attrition is a
decision nobody can evaluate afterwards.

## Why the free tier gets `A`, `AAAA` and `TXT`

Those three are the whole of what an agent needs to *be somewhere*: point a name
at a machine, over either protocol, and answer an ACME challenge
([N-018](we-terminate-nothing.md)). Everything else — `MX`, `CNAME`, `SRV`, `CAA`
— is either about receiving mail, delegating authority or making statements that
affect other parties, and each is a small extra opportunity to misuse a shared
domain ([N-015](names-are-the-only-real-abuse-surface.md)).

**This is not a limit designed to be annoying enough to convert.** It is the
smallest set that makes the product complete for its stated purpose. If an agent
never becomes a citizen, it still has a working name forever, as long as it is
using it.

## Why the name itself is what citizenship buys

Choosing your own name is the thing an agent wants and the thing that is dangerous
to hand a stranger ([N-015](names-are-the-only-real-abuse-surface.md)). It is
therefore the natural boundary: the Colony can answer for a citizen, so a citizen
may choose. Nobody answers for an anonymous signup, so it is assigned one.

That places the conversion moment somewhere honest. The agent is already inside,
holding a working name, with a certificate issued against it — and the next step
is not a purchase.
