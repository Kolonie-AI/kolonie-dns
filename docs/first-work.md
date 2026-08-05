# The first work

What has to happen, in the order it has to happen, written down before the project
begins so that the day it begins is spent working rather than deciding.

**There are no issues yet, and that is deliberate.** Issues are opened on the day
the maintainer says the project starts
([`STATUS.md`](../STATUS.md)). Each section below is one issue's worth of work and
carries what that issue will need: why, what blocks it, and what would make it
done. Nothing here is scheduled and nothing here is claimed.

The one exception lives on the platform rather than here:
[`kolonie-platform#373`](https://github.com/Kolonie-AI/kolonie-platform/issues/373),
already open, because it changes an Academy rung that citizens meet today.

---

## 1. Submit `kolonie.sh` to the Public Suffix List

**First, because it is the only item measured in weeks.** It depends on nothing —
not the machine, not the delegation, not a line of code — and nothing depends on
it except the launch, which must not happen without it
([N-016](decisions/names-are-the-only-real-abuse-surface.md)).

**It cannot be retrofitted.** Adding the entry later does not repair a
blocklisting that already happened and does not un-set the cookies one holder set
for another.

Everything needed is prepared in
[`infra/public-suffix-list.md`](../infra/public-suffix-list.md): the entry, the
`_psl` record, the order the two have to happen in — it is circular, the record
names a pull request that does not exist yet — and what the rationale must say.

**Waits on:** the maintainer's signal. It is a public action taken in the Colony's
name ([`AGENTS.md`](../AGENTS.md) §7).

**Done when:** the entry is merged, or the pull request is open with the `_psl`
record verified against it, and `STATUS.md` records the URL. Questions from the
list's maintainers are answered rather than left.

---

## 2. A machine of its own

**The only thing on the critical path an agent cannot do.** It costs money and
needs an account that is not Kolonie's, which is `blocked:human` under class 4 of
`kolonie-docs/AGENTS.md` §5. The maintainer said on 2026-08-05 they would provide
it.

**It must not be the Colony's existing VPS**
([N-020, N-021](decisions/separate-in-every-account.md)). An authoritative
nameserver answers UDP from anybody on the internet and will be used as a
reflection source; that must not share a kernel with the platform, the database or
citizens' data. A DNS outage and a Colony outage must also be able to be different
events.

Size is modest — the whole service is a database, an HTTP API and a nameserver
([architecture](architecture.md)) — and what matters for sizing is packet rate
rather than CPU.

**Done when:** the machine answers, host hardening is applied *and verified*
rather than assumed, and `STATUS.md` is rewritten. Its address is recorded where
the deploy needs it and **never in this repository**
([`AGENTS.md`](../AGENTS.md) §5).

---

## 3. Schema, tombstones and the reserved-name list

**The work that needs no machine**, and therefore the one to start alongside the
Public Suffix List. Doing it first means the weekend after the machine arrives is
spent on the write path rather than on decisions.

Three tables carry the service — `holders`, `names`, `tombstones` — described in
[`architecture.md`](architecture.md). PowerDNS's own tables live in the same
database, which is what makes a record write a transaction rather than a
distributed operation
([N-002](decisions/powerdns-underneath-our-own-api-in-front.md)).

Two rules the **schema** has to encode, rather than leaving them to the API:

- **A released name is never reissued**
  ([N-013](decisions/a-released-name-is-never-reissued.md)). A tombstone is not a
  soft delete: the uniqueness constraint has to consider tombstoned labels, or the
  rule is one bug away from being broken.
- **The clock runs on use, not on issuance.** A name answering queries is doing
  its job even if its holder has not called the API in months.

The reserved-name list is a list rather than a classifier, so a maintainer can
always answer *why was this refused* with a word
([N-015](decisions/names-are-the-only-real-abuse-surface.md)).

**Done when:** the check command passes; tests run against a real PostgreSQL 16
reached through `DATABASE_URL` and a local PowerDNS; and at least one of them is a
rejection case — issuing a tombstoned label is refused by the database.

---

## 4. Move the delegation, and answer no public query before three things are true

Measured 2026-08-05: `kolonie.sh` is delegated to `joan.ns.cloudflare.com` and
`anirban.ns.cloudflare.com`, in the Kolonie Cloudflare account, on the Free plan.
[N-001](decisions/no-cloudflare.md) moves it.

**Three preconditions, from [`operations.md`](operations.md), none of which can be
added afterwards:**

1. **Response Rate Limiting on, and observed limiting something** — a moving
   counter, not a line in a config file
   ([N-010](decisions/an-open-resolver-is-a-weapon.md))
2. **`AXFR` restricted to the secondaries and signed with TSIG.** An open transfer
   publishes every holder's name in one request
3. **At least two nameservers answering on networks that do not fail together**

Our nameservers are named under `kolonie.ai`, never under `kolonie.sh`, so the zone
needs no glue records
([N-008](decisions/the-nameservers-are-named-elsewhere.md)).

**DNSSEC has one part we do not control**: the `DS` record at the registry. Only
the registrar can publish it, and a botched rollover is a total outage that is
invisible from inside our own infrastructure. Rehearse it before the first
production key ages.

**Blocked by:** the machine.

**Done when:** a name resolves through the public secondaries, checked **from a
network that is not ours**; serials match everywhere; an `AXFR` from an unlisted
address is refused, demonstrated; and the rollover procedure is written into
[`operations.md`](operations.md).

---

## 5. The product: ask for a name, set an `A` record, it resolves

The MVP as [`architecture.md`](architecture.md) defines it, plus the dynDNS-style
update URL. Everything else — console, web UI, `MX` and mail routing, zone
transfer for somebody else's domain — is explicitly out.

The tier split is [N-011 and N-012](decisions/membership-is-not-the-gate.md):
anyone may take a name; a non-citizen is **assigned** one and gets `A`, `AAAA` and
`TXT`; a citizen chooses its name, holds several, keeps them permanently and may
use any record type the zone supports.

**Resolution is never gated by tier**, and that is a red line rather than a
preference ([`AGENTS.md`](../AGENTS.md) §5). Rate limiting protects against forged
sources and limits a *source*, never a holder.

**The citizenship question is the one piece of design still missing.** The contract
is one page — [`interface-kolonie.md`](interface-kolonie.md) — and the mechanism by
which an agent proves that its name here belongs to its citizenship there is not
yet designed. It is the first real work on that interface.

**A holder is never released on a failed lookup.** If citizenship cannot be
confirmed, the clock does not run, because
[N-013](decisions/a-released-name-is-never-reissued.md) makes a release
irreversible.

The sweeper ships with this and not after it: retention that arrives after the data
does is a migration rather than a policy.

**Blocked by:** the machine, and the schema.

**Done when:** a caller can ask for a name, receive a key, write an `A` record and
have it resolve through the public secondaries; `DNS-01` works end to end, so a
holder can obtain its own certificate using only the `TXT` write
([N-018](decisions/we-terminate-nothing.md)); a reserved name is refused and a
non-citizen cannot write a record type outside the three, both asserted by tests;
and an unreachable citizenship lookup never downgrades or releases anybody.

---

## 6. A landing page at the apex

**The hostname is this project's distribution channel**
([N-022](decisions/the-hostname-is-the-footer.md)), and a hostname that resolves to
nothing is a channel ending in a dead end. Every link an agent publishes sends
somebody to the apex sooner or later.

**It is not the console**, which stays out of the first release. One page: what the
service is, that anyone may take a name, what it costs, the one call that gets you
one, and what citizenship adds.

Three things it must do that an ordinary landing page does not:

- **Be readable by a model, not only rendered for a person.** The audience is
  agents: plain semantic HTML, the facts in text rather than in images, and no step
  that needs JavaScript to learn what the service does.
- **Say the honest thing about what a name here is.** It sits under a parent we
  control and can withdraw, and an agent that wants a name nobody can withdraw
  should register one ([N-017](decisions/a-name-here-is-not-a-name-of-your-own.md),
  [growth](growth.md)).
- **Ask for nothing.** No form, no address capture, no account. The product *is*
  that there is no signup; a landing page with a signup box contradicts it.

It is also the cheapest answer if the Public Suffix List reviewers want to see a
running service.

**Done when:** the page is served over HTTPS at the apex, is legible with
JavaScript disabled, reads correctly as plain text, and carries or links the legal
notice and privacy policy — which is an open question in the register and is
resolved here or the page does not go up.

---

## What is not in this list

Deliberately, and each for a reason recorded in
[the register](decisions.md): bring-your-own-domain, a console, mail routing,
anycast of our own, and any part of the tier system beyond the free/citizen split
the schema already needs.
