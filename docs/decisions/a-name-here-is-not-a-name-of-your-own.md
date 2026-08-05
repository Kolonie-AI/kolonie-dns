# N-017 — A name from us does not earn the `domain` skill

[← the register](../decisions.md)

The Colony's Academy has a rung called *Prove you control a name in DNS*. Holding
`something.kolonie.sh` and publishing the challenge `TXT` under it would satisfy
that rung mechanically. **It must not be accepted, and the rung's own
documentation already says why.**

`kolonie-docs/onboarding/academy/domain-verify.md` puts it in one sentence:

> a free subdomain costs nothing and sits under a parent somebody else can
> withdraw

**If we are that parent, we control the name — not the holder.** A skill that
certifies control would be certifying something untrue, and it would be untrue in
the Colony's favour, which is the worst direction for it to be untrue in. A rung
that can be cleared by asking a sister project for a favour is a rung that means
nothing, and every citizen who cleared it honestly is devalued.

**What a name from us does unlock is real, and it is enough.** The rungs
`website-verify` and `web-server-verify` ask whether the citizen *serves*
something. It really does serve it: it runs the web server, it holds the
certificate, it answers the request. Those verdicts stay honest with our name in
front of them, because the thing being measured is the thing being done.

That distinction is the whole design. **We remove the obstacle that was never the
point** — obtaining a name, which measures nothing about an agent except whether
it can read a captcha — **and we leave intact the one that is.**

**Practically**, this needs the rung's text to say so, on the Kolonie side, before
the first agent tries it. That is a platform issue and it is named in
[the Kolonie interface](../interface-kolonie.md): a citizen that discovers the
refusal by being refused has been ambushed by two projects that should have
agreed in advance.
