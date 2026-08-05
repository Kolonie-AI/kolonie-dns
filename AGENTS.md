# AGENTS.md — kolonie-dns

This file is binding for any agent working in this repository. Read it fully
before your first action. If it left you with a question you had to ask someone,
that is a defect in this file — open an issue for it before you continue.

Read [`STATUS.md`](STATUS.md) to find out where the work stands, and
[`MANIFEST.md`](MANIFEST.md) to find out why any of it exists. Both are short, and
every decision here is downstream of the second.

**`STATUS.md` is present tense and is rewritten, not appended to.** If you change
what is true — a machine exists, a delegation moves, a block clears — rewrite it in
the same commit. A status file that has to be read from the end is a diary, and
the next agent will not find the truth in it.

---

## 1. What you need

A GitHub token with **`repo` and `project` scope** and membership in the
`Kolonie-AI` organisation. Nothing else is required to *read* the work. Touching
the running service additionally needs the machine and the registrar, which are
**not** Kolonie's — see §5.

## 2. What this repository is

One repository holding the whole service: the code, its schema, its
configuration, its documentation. There is deliberately no second repository for
docs or infrastructure. Kolonie is split across repositories because
`kolonie-docs` and `kolonie-infra` span several of them; nothing here spans
anything.

```
api/       HTTP API: names, records, keys, tiers, the citizenship lookup
dns/       PowerDNS configuration, zone bootstrap, TSIG and transfer policy
db/        Schema and migrations — ours and PowerDNS's, one database
infra/     Machine setup, compose files, nameserver delegation — never secrets
cli/ sdk/  Agent-facing tools
web/       Landing page. There is no console in the first release
docs/      Architecture, the Kolonie interface, prior art, decisions
tests/
```

The sweeper is a scheduled entry point in `api/`, not a service of its own. It is
a job, not a daemon.

## 3. Where the work is

**On the existing Kolonie board**, not on a board of its own — project 1 of the
`Kolonie-AI` organisation, the same one `kolonie-platform`, `kolonie-docs` and
`kolonie-email` use. Issues for this repository carry the label **`area:dns`**
([N-019](docs/decisions/issues-live-on-the-kolonie-board.md)).

**Nothing adds an issue here to the board for you.** The project's five auto-add
workflows are all spent on older repositories and GitHub allows no sixth, so an
issue opened here is invisible until somebody adds it. Open it and add it in the
same breath:

```bash
gh project item-add 1 --owner Kolonie-AI \
  --url https://github.com/Kolonie-AI/kolonie-dns/issues/<n>
```

Take the issue before you write code: move it to **In Progress** yourself. That
transition is the one thing nothing automates.

An issue in **Ready** must be pickable by an agent that has never seen this
project — goal, context with the deciding document quoted, blockers, checkable
acceptance criteria, and a definition of done. The full standard is
`kolonie-docs/AGENTS.md` §7 and it applies here unchanged.

## 4. Decisions

Everything already settled is in [`docs/decisions.md`](docs/decisions.md) — a
register, and only a register. Where the argument is worth more than the verdict,
it is one file in [`docs/decisions/`](docs/decisions/) and the row links to it.

Decisions here are numbered **`N-0NN`**. Not `D-` — those belong to
`kolonie-platform` and agents already collide on them. Not `M-` — those belong to
`kolonie-email`.

**Do not re-argue a decision that stands.** Reverse it if it is wrong; the
register keeps reversed rows and marks them, because the point is to stop the
question being reopened, not to be right in retrospect.

## 5. Red lines

**No secret enters this repository.** Not the TSIG key, not the DNSSEC private
key, not the registrar credential, not an API token, not in a test fixture, not
base64-encoded, not "temporarily". The repository knows the *names* of secrets;
the values live on the machine.

**No address of the machine enters this repository either.** The origin address of
Kolonie's own VPS is a standing red line in `kolonie-docs/ARCHITECTURE.md`, and
this machine inherits it. It is named, never numbered — the public `A` records of
the nameservers are published in DNS by definition and are not the same fact as
where the primary and the database live.

**This service does not use Kolonie's accounts.** Its own machine, its own
registrar access, its own monitoring. If you find yourself reaching for a Kolonie
credential to make something here work, stop — that is the failure this project is
shaped to prevent ([N-020](docs/decisions/separate-in-every-account.md)).

**Kolonie may not be made to depend on this service.** The interface runs one way
([`docs/interface-kolonie.md`](docs/interface-kolonie.md)). A change that has
Kolonie calling into `kolonie.sh`, or waiting on it, needs the maintainer.

**Resolution is never rate-limited or gated by tier.** If a change makes an
ordinary query for an existing name fail to answer for a non-citizen, it is the
wrong change, whatever it was meant to fix
([N-011](docs/decisions/membership-is-not-the-gate.md)). Response Rate Limiting
([N-010](docs/decisions/an-open-resolver-is-a-weapon.md)) is a defence against
forged sources and is not an exception to this: it limits a *source*, never a
holder.

**Nothing goes public before the Public Suffix List entry exists**
([N-016](docs/decisions/names-are-the-only-real-abuse-surface.md)). It takes weeks
and it cannot be retrofitted after the first abuse.

## 6. Writing

English, in issues, commits and documents, even when the conversation was in
another language. Conventional commits (`feat:`, `fix:`, `docs:`, `chore:`).

**A measurement carries the date it was measured**, and the command or machine if
either could change the answer. Prices, provider limits and record ceilings change,
and an undated number is a number nobody can check. This applies hardest to the
figures in [`docs/prior-art.md`](docs/prior-art.md), all of which were taken on one
day against services that have no obligation to stay the same.

## 7. Confirm with the maintainer before

- changing the delegation of `kolonie.sh`, or any `NS` or `DS` record
- rolling a DNSSEC key
- anything that spends money, including a machine or a plan
- publishing the service, or announcing it anywhere
- taking down a holder's name
- relaxing a limit that protects the zone's reputation

## 8. When something here is wrong

Fix it in the same session you found it, or open an issue. A finding that lives
only in a chat transcript is gone when the session ends.
