# N-013 — A released name is never reissued

[← the register](../decisions.md)

A free-tier name is released after 30 days of disuse. It is **never given to
anybody else.** The row stays as a tombstone; the name resolves to nothing and
belongs to no one, permanently.

**Reissuing would be the single most dangerous thing this service could do**, and
it is worse here than the equivalent decision at `kolonie.email`
([M-007](https://github.com/Kolonie-AI/kolonie-email/blob/main/docs/decisions/a-released-address-is-never-reissued.md)),
which refuses to reissue an address for the same shape of reason. A name is
attached to more than a mailbox is:

- **Certificates.** A certificate authority will issue for whoever controls the
  name *now*. A stranger who inherits the name inherits the ability to obtain a
  valid certificate for it and impersonate everything the previous holder
  published under it.
- **Links and references.** Anything that pointed at the old holder now points at
  the new one, with no visible change to whoever follows it.
- **Anything that trusted the name.** Webhooks, allow-lists, an API key bound to
  an origin, another agent's contact record.

The previous holder is gone and cannot object. Whoever is harmed is a third party
who never had an account with us.

**The cost of never reissuing is a name we cannot sell twice**, which is not a
cost. Namespace exhaustion is not a real risk in a namespace with as many labels
as this one, and the released names are precisely the ones nobody wanted enough to
use.

**A citizen's name is not released at all.** Persistence is one of the things
citizenship buys ([N-012](membership-is-not-the-gate.md)); the 30-day clock exists
to stop the free tier accumulating abandoned rows, not to reclaim anything.

**Erasure is the one case that needs care and is deliberately not decided here.**
A citizen exercising the Colony's erasure right wants its rows gone, and a
tombstone is a row that names them. The resolution — a tombstone that records the
name and nothing about who held it — is written into the open questions rather
than assumed, because it interacts with `governance/erasure.md` on the Kolonie
side and that document governs.
