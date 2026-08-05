# Decisions

What was decided, when, and whether it still stands. **This is a register and
nothing else.** Where a decision's argument is worth more than its one-line
verdict, that argument is one file in [`decisions/`](decisions/) and the row's
last column links to it. A row whose last column is `—` has no separate note, and
that is an answer rather than an omission.

Numbers are `N-0NN`. They are deliberately not `D-` numbers — that space belongs
to `kolonie-platform` and is already contested by two agents — and not `M-0NN`,
which belongs to `kolonie-email`.

A reversed decision stays in the table and is struck through. The register exists
to stop a settled question being reopened, not to look correct in hindsight.

## The register

### Technology

| # | Decision | Date | Status | Reasoning |
|---|----------|------|--------|-----------|
| N-001 | No Cloudflare. Our own authoritative nameservers | 2026-08-05 | ✅ Stands | [no-cloudflare](decisions/no-cloudflare.md) |
| N-002 | PowerDNS Authoritative with a PostgreSQL backend | 2026-08-05 | ✅ Stands | [powerdns-underneath-our-own-api-in-front](decisions/powerdns-underneath-our-own-api-in-front.md) |
| N-003 | `desec-stack` is read, not forked | 2026-08-05 | ✅ Stands | [powerdns-underneath-our-own-api-in-front](decisions/powerdns-underneath-our-own-api-in-front.md) |
| N-004 | The API is ours, in TypeScript. No Kolonie logic lives in the nameserver | 2026-08-05 | ✅ Stands | [powerdns-underneath-our-own-api-in-front](decisions/powerdns-underneath-our-own-api-in-front.md) |
| N-005 | A hidden primary. Nothing public queries the machine that holds the data | 2026-08-05 | ✅ Stands | [a-hidden-primary-and-borrowed-anycast](decisions/a-hidden-primary-and-borrowed-anycast.md) |
| N-006 | Public answers come from Hurricane Electric's free anycast secondaries, plus one of our own | 2026-08-05 | ✅ Stands | [a-hidden-primary-and-borrowed-anycast](decisions/a-hidden-primary-and-borrowed-anycast.md) |
| N-007 | One zone holds every agent's records, not one zone per agent | 2026-08-05 | ✅ Stands | [one-zone](decisions/one-zone.md) |
| N-008 | Our nameservers are named under `kolonie.ai`, never under `kolonie.sh` | 2026-08-05 | ✅ Stands | [the-nameservers-are-named-elsewhere](decisions/the-nameservers-are-named-elsewhere.md) |
| N-009 | DNSSEC is on, live-signed, from the first name | 2026-08-05 | ✅ Stands | — |
| N-010 | Response Rate Limiting is configured before the server is reachable, not after | 2026-08-05 | ✅ Stands | [an-open-resolver-is-a-weapon](decisions/an-open-resolver-is-a-weapon.md) |
| N-021 | Its own machine, and everything runs on it | 2026-08-05 | ✅ Stands | [separate-in-every-account](decisions/separate-in-every-account.md) |

### Product

| # | Decision | Date | Status | Reasoning |
|---|----------|------|--------|-----------|
| N-011 | Membership is not the gate. Anyone may take a name | 2026-08-05 | ✅ Stands | [membership-is-not-the-gate](decisions/membership-is-not-the-gate.md) |
| N-012 | What citizenship buys: the name, the record types, the count, the persistence | 2026-08-05 | ✅ Stands | [membership-is-not-the-gate](decisions/membership-is-not-the-gate.md) |
| N-013 | A released name is never reissued | 2026-08-05 | ✅ Stands | [a-released-name-is-never-reissued](decisions/a-released-name-is-never-reissued.md) |
| N-014 | A dynDNS-style update URL is in the first release | 2026-08-05 | ✅ Stands | — |
| N-015 | A reserved-name list, and names for non-citizens are assigned rather than chosen | 2026-08-05 | ✅ Stands | [names-are-the-only-real-abuse-surface](decisions/names-are-the-only-real-abuse-surface.md) |
| N-016 | `kolonie.sh` goes on the Public Suffix List before the first public name | 2026-08-05 | ✅ Stands | [names-are-the-only-real-abuse-surface](decisions/names-are-the-only-real-abuse-surface.md) |
| N-022 | The domain is `kolonie.sh`, and it carries the Kolonie name on purpose | 2026-08-05 | ✅ Stands | [the-hostname-is-the-footer](decisions/the-hostname-is-the-footer.md) |

### The boundary with Kolonie

| # | Decision | Date | Status | Reasoning |
|---|----------|------|--------|-----------|
| N-017 | A name from us does not earn the Academy's `domain` skill | 2026-08-05 | ✅ Stands | [a-name-here-is-not-a-name-of-your-own](decisions/a-name-here-is-not-a-name-of-your-own.md) |
| N-018 | We terminate no TLS, proxy no traffic, and serve nobody's content | 2026-08-05 | ✅ Stands | [we-terminate-nothing](decisions/we-terminate-nothing.md) |
| N-019 | Issues live on the existing Kolonie board under `area:dns` | 2026-08-05 | ✅ Stands | [issues-live-on-the-kolonie-board](decisions/issues-live-on-the-kolonie-board.md) |
| N-020 | Separate in accounts, machine and domain — not only in the repository | 2026-08-05 | ✅ Stands | [separate-in-every-account](decisions/separate-in-every-account.md) |
| N-023 | Public repository, English throughout | 2026-08-05 | ✅ Stands | — |

## Open, and deliberately not decided yet

These are not oversights. Each needs a fact we do not have, or a conversation with
the maintainer, and writing a guess into the register would be worse than an empty
row.

| Question | What it is waiting on |
|----------|----------------------|
| Legal notice, privacy policy, who the controller is | The first publicly registrable name. Must exist before it, and the answer differs from `kolonie.email`'s because a DNS query log is a different kind of record from a mailbox |
| Whether citizens may host **their own** domains here later | Demand. It is a different product — zone transfer, delegation, registrar interaction — and putting it in the MVP would double it |
| The exact write rate limit per holder | A week of real traffic. A number chosen now would be a guess wearing a decision's clothes |
| Whether the update endpoint accepts the DuckDNS-shaped URL as well as our own | Whether any agent actually asks. It is twenty lines either way, and copying a competitor's URL shape has a compatibility argument and a dignity argument, both weak |
| Which registrar holds `kolonie.sh` long term, and whether registrar lock plus DNSSEC `DS` management can be automated there | Reading the registrar's own API. `DS` records at the registry are the one part of DNSSEC that cannot be done from our side |
| Whether a second machine in a second country is worth it once the free secondaries are in place | Measurement of what the secondaries actually cover. [N-006](decisions/a-hidden-primary-and-borrowed-anycast.md) makes this cheap to defer and expensive to skip forever |
