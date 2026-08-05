# N-015, N-016 — Names are the only real abuse surface

[← the register](../decisions.md)

Almost nothing about running a DNS provider is dangerous. Records point at
addresses; addresses are public facts. **The dangerous part is the string on the
left**, because it is the part a human reads and trusts.

## What we refuse

**A reserved-name list**, checked before anything is issued: brand names,
financial institutions, the obvious login-shaped words, our own infrastructure
labels, and the labels of Kolonie's other services. It is a list rather than a
classifier so that a maintainer can always answer *why did this get refused* with
a word.

**Names for non-citizens are assigned, not chosen**
([N-012](membership-is-not-the-gate.md)). That single rule removes nearly the
whole category: an anonymous signup cannot obtain a name that says anything at
all, because it does not pick one. What is left to police is citizens, who are
answered for.

## The Public Suffix List

**`kolonie.sh` is submitted to the [Public Suffix List](https://publicsuffix.org/)
before the first public name exists**, as a private-domain entry, exactly as
`github.io`, `vercel.app` and every other service of this shape has done.

Two things follow from being on it, and both are why this is not optional:

- **Cookies stop crossing between holders.** Without a PSL entry, a browser treats
  `kolonie.sh` as an ordinary registrable domain, so one holder can set a cookie
  scoped to it and read it on every other holder's site.
- **Reputation attaches to the holder, not to the parent.** Safe Browsing, spam
  blocklists and the various reputation systems use the registrable domain as
  their unit. Off the list, one abusive holder gets *every* name under
  `kolonie.sh` flagged, including the Colony's own.

**It has a calendar dependency and that is why it is a decision rather than a
task.** The submission is a pull request against a repository with human
maintainers and a queue measured in weeks to months. It cannot be done in the week
we launch. It has to be done first, and everything else can proceed while it is
pending.

## What we do not do

**We do not inspect what is served at an address.** We answer queries; the content
is somebody else's and we never see it ([N-018](we-terminate-nothing.md)).
Take-down of a name is a decision about the *name* — the Colony's red lines apply
to it — and is not a judgement about a page.
