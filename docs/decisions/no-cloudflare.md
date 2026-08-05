# N-001 — No Cloudflare

[← the register](../decisions.md)

The first sketch put the zone in a Cloudflare account of its own and had our API
call theirs. It had a great deal going for it: no nameserver to operate, no
uptime to own, anycast included, and a working example three metres away — the
Colony already runs `kolonie.ai` there.

**It was rejected by the maintainer on the arithmetic, and the arithmetic is
right.**

| | Cloudflare Free | Cloudflare Pro | Ours |
|---|---|---|---|
| DNS records per zone | 200 | ~3500 | no ceiling |
| Cost | 0 | 20 $/month | 2–3 small machines, ~10–15 €/month |

Measured 2026-08-05. The ceiling is the point: **a plan that costs money and still
caps below the number we intend to reach is the worst of both.** A hundred
thousand names is the stated ambition, and there is no Cloudflare tier that
reaches it at a price this project can justify — Business is 200 $/month for the
same ~3500.

**The decision makes the project smaller, not larger, and that is the part worth
recording.** The Cloudflare design needed a reverse proxy, wildcard certificates
and a hostname-to-origin routing table, because proxying was the reason to be
there at all. Without Cloudflare, none of that exists: agents obtain their own
certificates ([N-018](we-terminate-nothing.md)) and we answer DNS queries and
nothing else. Half the system went away with this decision.

**What it costs us is an operation, and the honest name for it is 24/7.** An
authoritative nameserver that stops answering does not degrade — every name under
it vanishes, along with every website and every certificate renewal that depends
on it. That obligation is real and it is what [N-005](a-hidden-primary-and-borrowed-anycast.md)
and [N-010](an-open-resolver-is-a-weapon.md) exist to make survivable.

**Cloudflare is not banned from the project.** It stays where it already is, in
front of `kolonie.ai`, and nothing here argues it should move. What is decided is
that the *agents' zone* does not live there.

**One consequence with a date on it.** `kolonie.sh` was registered 2026-08-04 and
is delegated to `joan.ns.cloudflare.com` and `anirban.ns.cloudflare.com`, in the
Kolonie Cloudflare account, on the Free plan (measured 2026-08-05). Acting on this
decision means changing the delegation at the registrar, and until that happens
none of the rest of this repository is live. It is also the reason this decision
is cheap: **delegation is one field at the registrar, so choosing wrong here is
reversible in an afternoon** — which is not true of most infrastructure choices
and is why starting small would have been safe too.
