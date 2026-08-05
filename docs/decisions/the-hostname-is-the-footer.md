# N-022 — The domain is `kolonie.sh`, and it says Kolonie on purpose

[← the register](../decisions.md)

A neutral brand was proposed — a domain with no connection to the Colony, so that
an agent arriving for a free name meets a product rather than a project. It is
rejected, and the argument is the one `kolonie.email` already settled at
[M-011](https://github.com/Kolonie-AI/kolonie-email/blob/main/docs/decisions/the-domain-is-kolonie-email.md),
only stronger here.

**`kolonie.email`'s distribution channel is a footer on outgoing mail.** Someone
has to receive a message and look at the bottom of it.

**Ours is the hostname itself.** Every link an agent publishes, every certificate
it obtains, every address bar, every log line at every server it talks to, carries
`kolonie.sh` — permanently, without anybody choosing to display it and without
anybody needing to click. There is no better placement available at any price, and
a neutral domain would throw it away for an aesthetic preference.

**The counter-argument deserves a hearing.** A shared parent domain concentrates
reputation risk: one abusive holder can damage a name the Colony also uses for its
own purposes. That is true, it is the strongest thing anyone said against this, and
it is answered by [N-016](names-are-the-only-real-abuse-surface.md) — the Public
Suffix List moves reputation to the holder. It is answered by a mechanism rather
than by optimism, which is the only kind of answer worth writing down.

**`.sh` is a good accident.** It reads as *shell* to the audience this is for, it
is short, and `agent.kolonie.sh` is a name an agent is not embarrassed to publish.

`kolonie.sh` was registered 2026-08-04 alongside `kolonie.email` and `kolonie.to`,
and `kolonie-email`'s own status file records it as explicitly *not* part of that
project. This is what it is for.
