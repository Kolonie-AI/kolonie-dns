# N-024 — What a name may be

[← the register](../decisions.md)

A label is **lowercase `a`–`z`, digits, and the hyphen**; three to sixty-three
characters; it does not begin or end with a hyphen; and it is compared
case-insensitively because DNS is.

**No internationalised names. No punycode. Not now and not by accident.**

## Why the grammar is a decision and not a detail

[N-015](names-are-the-only-real-abuse-surface.md) says the dangerous part of this
service is the string on the left, because it is the part a human reads and
trusts. The reserved-name list defends against a name that *says* the wrong
thing. **The grammar defends against a name that says the right thing and is not
it.**

`аgent.kolonie.sh` — with a Cyrillic `а` — is a different label from
`agent.kolonie.sh` and renders identically in most places either will be read.
That is a homograph attack, it is decades old, it is why the registries that allow
IDN also run script-mixing rules, and it is not a thing to discover at scale.

**Accepting punycode is the same decision wearing a disguise.** `xn--`-prefixed
labels are ASCII, so a naive validator lets them through and a browser renders
them back into the very characters the rule was meant to exclude. The check has to
be on the encoded form as well.

## What it costs

An agent whose operator writes in a non-Latin script cannot have a name in it.
That is a real exclusion and it is accepted for now, with the reason written down
rather than glossed: the defence against homographs is script-mixing rules and a
confusables table, that machinery is larger than this entire service, and running
it badly would be worse than not offering the feature.

**It is a door that opens, not one that closes.** Adding IDN later is additive.
Retracting it after somebody has registered a confusable is not, because the
retraction takes a name away from somebody who did nothing wrong.

## The three-character floor

Two-character labels are worth more than they look — they are scarce, and they are
what an established service would sell. Reserving them costs nothing today and
keeps a decision available.

## Where it is enforced

**In the API, and in the schema where it can be.** A grammar that lives only in
application code is a grammar one code path forgets. The reserved-name list
([N-015](names-are-the-only-real-abuse-surface.md)) is checked in the same place
and at the same moment, because a name that passes one and fails the other must
fail with one answer rather than two.
