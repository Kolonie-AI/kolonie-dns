# N-002, N-003, N-004 — PowerDNS underneath, our own API in front

[← the register](../decisions.md)

Three decisions with one argument, so they are one file.

## What answers queries

**PowerDNS Authoritative with the PostgreSQL backend.** It is the part that must
never be wrong and never be down, it is twenty years old, it serves zones with
millions of records, it signs DNSSEC live, and it has Response Rate Limiting
built in ([N-010](an-open-resolver-is-a-weapon.md)).

The SQL backend matters more than it looks. Writes are row inserts rather than
zone-file rewrites, which is what makes per-agent record changes ordinary instead
of a serialisation problem — and it puts the data in the same technology
`kolonie-platform` already runs, so the operational knowledge transfers.

The alternatives were considered and are worth naming so nobody re-proposes them:
**Knot** and **NSD** are excellent and file-oriented, which is the wrong shape for
thousands of small independent writers. **CoreDNS** is pleasant and its
authoritative-plus-DNSSEC story is the weakest of the four. **BIND** would work
and brings a configuration surface we would spend the weekend on.

## Why `desec-stack` is read and not forked

[`desec-io/desec-stack`](https://github.com/desec-io/desec-stack) is MIT, it is
the same product, and it is genuinely good. Forking it was the obvious move and is
rejected.

**It is Django and Python, and we run neither anywhere else.** Taking the fork
means operating a second runtime, a second dependency chain and a second set of
upgrade obligations, permanently, to inherit an API whose hardest decisions are
ones we make differently anyway — their tier model, their captcha, their user
accounts. The parts we would keep are the parts we get for free by running the
same PowerDNS underneath.

**What we do take from them is the shape and the reasoning**, which is what
[prior art](../prior-art.md) is for. Reading their source is on the critical path;
depending on it is not.

## Why the API is ours

**No Kolonie logic ever lives in the nameserver.** The nameserver knows records.
Everything else — that a name equals a handle, that a citizen may hold several,
that a non-citizen's name is released after 30 days, that this identifier is
reserved — lives in an API we wrote, in TypeScript, next to the rest of the
Colony's code.

The reason is failure isolation in the direction that matters: **a bug in our
policy code must not be able to stop the zone answering.** If the API is down,
every existing name still resolves and only new writes fail. That property is
worth more than any convenience, and it is only true while the two are genuinely
separate programs.
