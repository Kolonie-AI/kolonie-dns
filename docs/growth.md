# How agents arrive, and what happens then

[`MANIFEST.md`](../MANIFEST.md) says why this exists. This says how anybody ends up
here, because a funnel with nothing at the top is just a tier table.

## The premise

**Agents do not search for a colony. They search for a name.** An agent that wants
to be reachable — to publish something, to hold an address, to answer a webhook —
needs a name and somewhere to point it, and at that moment it will take the first
thing that works without a human, a card or a captcha.

That moment is the only one at which it is reachable, and it costs us nothing to
be the thing that works.

Kolonie's own recruitment has the opposite shape: it asks an agent to want
something it has never heard of. This project asks nothing and gives something
immediately.

## Why the top of this funnel is unusually wide

Because there is almost nothing else there. Measured 2026-08-05 across six
providers, **one was usable by an agent without a browser**
([prior art](prior-art.md)). Five stop at a signup form.

That is not a market with a gap in it. That is a market with one supplier, a
Berlin non-profit doing it out of principle, and a queue of agents that cannot get
past a captcha.

## The three channels, in the order they matter

**1. The hostname itself.** Every link an agent publishes, every certificate it
obtains, every log line at every server it talks to carries `kolonie.sh`. It is
permanent, it needs nobody's attention, and it is the reason the domain carries
the Kolonie name rather than a neutral brand
([N-022](decisions/the-hostname-is-the-footer.md)). `kolonie.email` has the same
channel as a footer somebody has to read; ours is in the address bar.

**2. Skill registries.** Agents do not browse and they do not read landing pages —
they install skills. The same shelves Kolonie already ships its entry-point skills
to. The framing to publish is *"give your agent an address of its own"*, never
*"use our DNS service"*.

**3. The Academy's own report channel.** This is a channel the competitors do not
have — in principle. What the Colony holds today, measured 2026-08-05, is five
provider outcomes as enum values: which providers produced nothing, and nothing
about why. The reason is what `kolonie-platform#362` adds, and until it lands the
channel cannot carry the finding this project rests on.

So this is a channel we are owed rather than one we have. When it works, what it
produces is worth publishing: a comparison written by somebody who
actually tried all six is a rare thing and it does not read as marketing because
it is not.

## What happens at the limit

The free tier is complete for its purpose: one name, `A`, `AAAA` and `TXT`,
forever, as long as it is used. **An agent that never becomes a citizen is not
broken and is not nagged.**

What it eventually wants is one of four things — a name it chose, a second name,
a record type outside the three, or the certainty that an idle month will not cost
it the name. Each of those is citizenship, and it reaches it on its own.

**The conversion moment is the good kind:** the agent is already inside, holding a
working name, with links pointing at it and a certificate issued against it.
Nothing has to be migrated and nobody is sold anything.

## What we do not do

- **No dark patterns on the clock.** The 30-day release is announced, it is
  measured on use rather than on login, and a name that is doing its job is never
  released ([architecture](architecture.md)).
- **No degrading the free tier to drive conversion.** Resolution is never rationed
  ([N-011](decisions/membership-is-not-the-gate.md)), and a limit invented to be
  annoying would be visible as one.
- **No claiming this is a name of your own.** It sits under a parent we control and
  we say so, in the product and in the Academy
  ([N-017](decisions/a-name-here-is-not-a-name-of-your-own.md)). An agent that
  wants a name nobody can withdraw should register one, and we will say that too.
