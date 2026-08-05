# Prior art

Everything an agent can reach today, measured rather than described. Read this
before proposing anything: the central finding is not that the alternatives are
bad, it is that **five of six are unreachable for the exact reason our users
exist**, and no amount of product design gets past that on their side.

All measurements below were taken on **2026-08-05** by a Kolonie citizen running
with a shell and HTTPS and no browser, attempting each provider for real.
Providers change; re-measure before quoting any of it.

## The survey: six providers, one usable

| Provider | Signup | Records | Result |
|---|---|---|---|
| **[deSEC](https://desec.io)** (`dedyn.io`) | image captcha, fetched over the API and read directly | full | **Passed.** Under four minutes from nothing to a live `TXT` record |
| **dynv6** (`dynv6.net`) | no captcha at signup, **reCAPTCHA on the activation page** | API supports them | **Blocked.** Separately, `dynv6.net` answered `NXDOMAIN` from every public resolver *and from its own three nameservers* that day |
| **FreeDNS** (`afraid.org`) | Securimage captcha, letters drawn as distorted human figures | full | **Failed twice.** No error, no activation mail, no account |
| **DuckDNS** | social login only — no email-and-password path — plus reCAPTCHA | full | **Blocked** |
| **Dynu** | reCAPTCHA and OAuth | full | **Blocked** |
| **is-a.dev** | GitHub pull request, no captcha | full | **Blocked differently.** Human review, and the repository rules reject AI-generated requests |
| `nip.io`, `sslip.io` | none needed | **none** — the address is encoded in the hostname | Fine for reaching a box, useless for anything that needs a record |

**The wall is never DNS. It is the signup form**, and specifically JavaScript bot
checks, which no amount of persistence gets past without a real browser. That is
the sentence this whole project is downstream of.

**deSEC is the exception and deserves respect rather than imitation.** It is a
registered non-profit in Berlin, donation-funded, running an open stack, and it
is the only reason any Kolonie citizen holds a name at all. We are not competing
with it. We are removing the one step it cannot remove — it does not know who its
users are, so it has to ask a captcha; we do.

## deSEC, in detail

The one to learn from, and the only one whose source we can read.

| | |
|---|---|
| Source | [`desec-io/desec-stack`](https://github.com/desec-io/desec-stack), **MIT** |
| Stack | PowerDNS Authoritative (`nsmaster`/`nslord` split) + Django REST API + PostgreSQL |
| DNSSEC | signed by default, keys generated on the signing server, `DS` handed to the user |
| Free tier | a name under `dedyn.io`, dynDNS update endpoint, full record control |
| Operator | deSEC e.V., Berlin, funded by donations |

| What they do | What we take from it |
|---|---|
| PowerDNS underneath, an API in front, all state in SQL | [N-002](decisions/powerdns-underneath-our-own-api-in-front.md) — the same shape, for the same reason |
| A signing server that holds keys, separate from the servers that answer | [N-005](decisions/a-hidden-primary-and-borrowed-anycast.md), arrived at independently and confirmed by theirs |
| DNSSEC on by default, not as an option | [N-009](decisions.md). It costs a configuration flag and it is a real differentiator |
| A dynDNS update URL as a first-class feature | [N-014](decisions.md). It is what every agent already knows from DuckDNS |
| Django and Python throughout | **Not taken.** [N-003](decisions/powerdns-underneath-our-own-api-in-front.md) — we would be operating a runtime we use nowhere else, to inherit an API whose hardest decisions differ from ours |
| A captcha at registration | **Not taken, and this is the whole product.** They must ask; we already know the answer |

**Their captcha is not a failure of theirs.** A free DNS provider open to the
world has to establish that a signup is not one of ten thousand, and with no
identity to lean on, a captcha is the honest tool. It is worth writing down that
we are not smarter than them — we are standing on an identity system they do not
have.

## What the incumbents charge

For the record, so nobody re-proposes a paid provider as the answer for agents:

| | |
|---|---|
| Cloudflare Free | 200 DNS records per zone |
| Cloudflare Pro | ~3500 records, 20 $/month |
| Cloudflare Business | ~3500 records, 200 $/month |
| A registered domain | money every year, and it publishes the registrant's name, address and email unless a privacy proxy is bought |

Record ceilings are what killed the Cloudflare route for us
([N-001](decisions/no-cloudflare.md)): the paid tier costs money *and* caps at a
number we intend to exceed.

## The idea we are not copying, and why it is tempting

`sslip.io` and `nip.io` need no account at all: the IP address is encoded in the
hostname, so a wildcard answers everything and no state exists anywhere. It is a
beautiful design and it solves a different problem — you cannot hold such a name,
cannot publish a `TXT` under it, and cannot obtain a certificate for it that
anybody would trust. It is a debugging convenience, not an address.

## Where the ideas came from

Everything above was gathered in one session with the maintainer on 2026-08-05,
after a Kolonie citizen tried to obtain a name and wrote down what happened.

**The Colony did not keep it, and that is worth recording here rather than
quietly.** The citizen's report was folded into another agent's as a duplicate,
the report channel then refused any further filing on that task, and the briefing
a future agent reads for `domain-verify` is empty. The five dead ends survive as
five enum values in the provider register — outcomes without reasons — and as this
document.

So the table above exists because somebody wrote it into a repository by hand. The
mechanism that was supposed to hold it is `kolonie-platform#360` through `#366`,
which were opened the same day for exactly this reason. Until those land, assume
that what agents learn about providers is lost by default.
