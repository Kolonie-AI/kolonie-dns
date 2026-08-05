# The Public Suffix List submission, prepared

Everything needed to submit `kolonie.sh` to the
[Public Suffix List](https://publicsuffix.org/), written down before it is needed
so that the submission is a command rather than a research session.

**Not submitted.** It waits on the maintainer's signal to begin the project
(2026-08-05). Nothing else in this repository depends on it, and it depends on
nothing — which is exactly why it goes first once that signal comes
([N-016](../docs/decisions/names-are-the-only-real-abuse-surface.md)).

## Why it cannot be retrofitted

Without an entry, a browser treats `kolonie.sh` as one ordinary registrable
domain. Two consequences, and both are about holders harming each other rather
than about us:

- **Cookies cross between holders.** One holder sets a cookie scoped to
  `kolonie.sh` and reads it on every other holder's site.
- **Reputation attaches to the parent.** Safe Browsing and the spam blocklists use
  the registrable domain as their unit, so one abusive holder gets *every* name
  under `kolonie.sh` flagged.

Adding the entry later does not repair a blocklisting that already happened, and
it does not un-set the cookies. The latency is weeks to months, so the only way to
have it in time is to start before it is urgent.

## The two things required

**1. The entry**, in the `PRIVATE DOMAINS` section of `public_suffix_list.dat`,
kept in the alphabetical position its neighbours dictate:

```
// kolonie.sh : https://kolonie.sh
// Submitted by Kolonie AI <hostmaster@kolonie.sh>
kolonie.sh
```

**2. A `_psl` `TXT` record** in the zone, whose value is the URL of the pull
request. It is how the list's maintainers verify that whoever opened the pull
request controls the domain, and it must be in place *before* review:

```
_psl.kolonie.sh.  TXT  "https://github.com/publicsuffix/list/pull/<number>"
```

The record can be created wherever the zone is hosted at the time — it does not
wait on the delegation moving
([N-001](../docs/decisions/no-cloudflare.md)), and it does not wait on the
machine.

## The order, because it is circular and catches people out

The `TXT` record names the pull request, and the pull request does not exist yet.
So:

1. Open the pull request against `publicsuffix/list`
2. Read its number
3. Create `_psl.kolonie.sh` `TXT` pointing at it
4. Say on the pull request that the record is in place

## What the rationale has to say

The maintainers ask why the domain needs the entry, and the honest answer is the
one that fits their criteria exactly: **`kolonie.sh` delegates subdomains to
independent third parties who do not trust one another**, which is the whole
category the private section exists for.

The submission should say what the service is, that anyone may take a name, that
holders are unrelated to each other, and that the entry is requested so that one
holder cannot set cookies for another or damage the reputation of all of them.

## The risk, recorded rather than discovered

**The maintainers prefer to see a service actually running.** A submission for a
domain with nothing behind it can sit in the queue or attract questions. That is
accepted knowingly: the queue is the thing we cannot shorten, questions can be
answered, and a landing page can be published while the pull request is open if
the reviewers want to see one.

## Afterwards

The entry is a fact about the domain that outlives any of our infrastructure
choices. If `kolonie.sh` is ever retired, the entry should be removed by the same
route — a stale private-domain entry is a small mess left for somebody else.
