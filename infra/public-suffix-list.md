# The Public Suffix List submission, prepared

Everything needed to submit `kolonie.sh` to the
[Public Suffix List](https://publicsuffix.org/), written down before it is needed
so that the submission is a command rather than a research session.

**Not submitted, and no longer for the reason this file used to give.** The
maintainer's word was given on 2026-08-11 (`#9`). Reading the list's own
[Guidelines](https://github.com/publicsuffix/list/wiki/Guidelines) and
[`CONTRIBUTING.md`](https://github.com/publicsuffix/list/blob/main/CONTRIBUTING.md)
against this file the same day turned up **one criterion `kolonie.sh` fails
today and cannot argue its way past**, and a second it is likely to fail. Both
are below, and the first is why nothing has been opened.

## What blocks it, measured 2026-08-11

**The registration must have more than two years left, and the rationale has to
say so.** From `CONTRIBUTING.md`: *"Lack of proper domain ownership or expiry
dates less than 2Y away"* is listed among the things that cause a request to be
rejected. The Guidelines are more specific still — the pull request must contain
an affirmative statement that at least two years remain at submission time, plus
a commitment to keep more than one year on the clock afterwards. The reason given
is that a change needs time to reach the software downstream of the list.

`kolonie.sh` was registered 2026-08-04 and **expires 2027-08-04** (RDAP,
2026-08-11). That is 358 days. There is no wording that makes the required
statement true, so the submission is either rejected on a criterion anybody can
check, or it carries a false statement made in the Colony's name. **Renewing to
at least 2029-08 is the whole of the fix**, it costs money and registrar access,
and it is therefore the maintainer's (`AGENTS.md` §7).

**And the scale bar is stronger than this file used to record.** It said the
maintainers *"prefer to see a service actually running"* and called the risk
accepted. The Guidelines put it higher: efforts *"not serving more then thousands
of users are quite likely to be declined"*, and private, sandbox, test, lab or
beta setups *"will likely be turned down"*. Today `kolonie.sh` serves nobody and
resolves nothing. That is a *likely decline*, not a delay — a different thing to
accept, and it is what the machine (`#10`), the delegation (`#12`) and the
product (`#13`) change.

**The queue is still the argument for going early**, and it is not an argument
for going now. A rejected submission does not hold a place in it.

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

**1. The entry**, in the `PRIVATE DOMAINS` section of `public_suffix_list.dat`:

```
// Kolonie AI : https://kolonie.sh
// Submitted by Kolonie AI <hostmaster@kolonie.sh>
kolonie.sh
```

**The first comment line is the organisation, not the domain**, and that is what
the sorting is on — `CONTRIBUTING.md` calls the sort order the most common cause
of lost review time. This file used to give the first line as `// kolonie.sh :
https://kolonie.sh`, which is the domain twice and would have sorted under `k`
for the wrong reason.

Measured against `publicsuffix/list@main` on 2026-08-11, the block goes **between
`KnightPoint Systems, LLC` and `KoobinEvent, SL`** — `Kn` before `Ko`, and
`Ko-l` before `Ko-o`:

```
// KnightPoint Systems, LLC : http://www.knightpoint.com/
// Submitted by Roy Keene <rkeene@knightpoint.com>
knightpoint.systems

// Kolonie AI : https://kolonie.sh          ← here
// Submitted by Kolonie AI <hostmaster@kolonie.sh>
kolonie.sh

// KoobinEvent, SL : https://www.koobin.com
// Submitted by Iván Oliva <ivan.oliva@koobin.com>
koobin.events
```

**`hostmaster@kolonie.sh` has to receive mail before it is written down.** The
Guidelines say the submitter address *"must be one you actually control, since it
may be used for authentication"*. A role address is what they ask large
submitters for, so the choice is right; an address that bounces is worse than a
personal one that does not.

**2. A `_psl` `TXT` record** in the zone, whose value is the URL of the pull
request. It is how the list's maintainers verify that whoever opened the pull
request controls the domain, and it must be in place *before* review:

```
_psl.kolonie.sh.  TXT  "https://github.com/publicsuffix/list/pull/<number>"
```

The record can be created wherever the zone is hosted at the time — it does not
wait on the delegation moving
([N-001](../docs/decisions/no-cloudflare.md)), and it does not wait on the
machine. The Cloudflare credential both development agents hold reaches it.

**It stays published after approval.** The Guidelines say so in capitals: a
missing `_psl` record is the signal future automation will read as *this entry is
no longer wanted*. Removing it after the merge would eventually remove the entry.

## The order, because it is circular and catches people out

The `TXT` record names the pull request, and the pull request does not exist yet.
So:

1. Run the list's own checks — `make test` in a clone of `publicsuffix/list`.
   **It needs `autoreconf`**: the target builds `libpsl` from source, and on a
   host without autotools it fails at `autoreconf: not found` before it reaches
   the list. Install them, or run the linter under `linter/` alone and say in the
   pull request which was run
2. Open the pull request against `publicsuffix/list`
3. Read its number
4. Create `_psl.kolonie.sh` `TXT` pointing at it
5. Say on the pull request that the record is in place

## What the rationale has to say

The maintainers ask why the domain needs the entry, and the honest answer is the
one that fits their criteria exactly: **`kolonie.sh` delegates subdomains to
independent third parties who do not trust one another**, which is the whole
category the private section exists for.

The submission should say what the service is, that anyone may take a name, that
holders are unrelated to each other, and that the entry is requested so that one
holder cannot set cookies for another or damage the reputation of all of them.

It must **also** carry, because the Guidelines require each one by name:

- the count of domains requested — one
- whether this is internal or general use — general
- the expiry statement and the renewal commitment (see the top of this file)
- input and output examples: `a.kolonie.sh` and `b.kolonie.sh` are different
  sites, and `kolonie.sh` is not a registrable domain

## Afterwards

The entry is a fact about the domain that outlives any of our infrastructure
choices. If `kolonie.sh` is ever retired, the entry should be removed by the same
route — a stale private-domain entry is a small mess left for somebody else.
