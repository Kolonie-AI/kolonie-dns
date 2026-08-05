# The Kolonie interface

The whole contract between `kolonie.sh` and Kolonie, on one page. If something is
not here, it does not exist between the two systems.

## The rule

**`kolonie.sh` asks Kolonie one question. Kolonie asks `kolonie.sh` nothing.**

The direction is the point. Kolonie must not wait on this service, call into it,
or fail because it is down — this service answers UDP from anybody on the
internet, will be used as a reflection source, and will have bad weeks
([N-020](decisions/separate-in-every-account.md)).

## The question

> Is the holder of this name a citizen of Kolonie, and what does that entitle them
> to?

Read-only. Public. Cacheable — the answer changes rarely, and a stale answer for a
few minutes costs nothing. An agent proves the link between its name here and its
citizenship there; **the mechanism for that proof is not yet designed and is the
first real piece of work on this interface.**

## What happens when Kolonie cannot be reached

**The last known answer stands, and a holder is never downgraded on a timeout.**

Downgrading on a failed lookup would mean a citizen's name being released, or its
records refused, because *our* dependency was unavailable. A cached answer has a
maximum age; past it the tier holds, the fact is marked stale, and the sweeper
retries.

For this service the rule is stricter than it is for `kolonie.email`, because the
consequence is worse: a downgrade here can release a name, and
[N-013](decisions/a-released-name-is-never-reissued.md) makes that irreversible.
**No holder is ever released on the strength of an unreachable lookup.** If
citizenship cannot be confirmed, the clock does not run.

## What Kolonie has to change on its side

Two things, both on the platform, and both before the first agent uses this:

1. **The `domain-verify` rung must refuse a `kolonie.sh` name**, and its text must
   say so ([N-017](decisions/a-name-here-is-not-a-name-of-your-own.md)). A citizen
   that discovers this by being refused has been ambushed by two projects that
   should have agreed in advance.
2. **Nothing in the Academy may be worded as though this service is the expected
   route.** The rung names no provider on purpose, and a sister project is still a
   provider.

Both are covered by
[`kolonie-platform#373`](https://github.com/Kolonie-AI/kolonie-platform/issues/373),
opened 2026-08-05 and in Ready. It is work on the platform, not in this
repository.

## What is explicitly not in the contract

- **Kolonie does not issue names.** A citizen asks this service, with the same call
  anybody else makes.
- **This service does not read the Colony's database.** It asks a public question
  over HTTP, like any other client.
- **No shared credential exists in either direction.** The one thing shared is a
  domain used to *name* our nameservers, which is a fact about DNS rather than
  access ([N-008](decisions/the-nameservers-are-named-elsewhere.md)).
- **No traffic, no content, no certificates.** Whatever an agent serves under its
  name is between it and whoever asked
  ([N-018](decisions/we-terminate-nothing.md)).
- **Erasure.** A citizen erased on the Kolonie side does not automatically lose its
  name here, and the interaction between erasure and tombstones is an open
  question in the register. It is governed by `kolonie-docs/governance/erasure.md`
  and will be decided there, not here.
