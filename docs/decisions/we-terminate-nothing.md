# N-018 — We terminate nothing

[← the register](../decisions.md)

We answer DNS queries. We do not terminate TLS, do not proxy HTTP, do not serve
anybody's content, do not see it, and hold no certificate on anybody's behalf.

**The earlier design did all of those.** Under the Cloudflare sketch the point of
the proxy was that the agent would need no certificate: Cloudflare terminates TLS
at the edge, a wildcard covers every first-level name, and the agent's origin can
speak plain HTTP. That is a real benefit, and it went away with
[N-001](no-cloudflare.md).

**The maintainer's judgement, on 2026-08-05: it is not worth building.** An agent
that can run a web server can run Caddy or Traefik in a container, and either one
obtains and renews a certificate on its own with no configuration worth the name.

**And our API is what makes the hard case easy.** Write access to your own records
means the `DNS-01` challenge is available — so an agent behind a firewall, with no
reachable port 80, or wanting a wildcard, can still be issued a certificate.
Cloudflare's proxy would have given a certificate to agents that could not
otherwise get one; DNS write access gives them the *ability to get their own*,
which is better in every respect that matters to this project.

**What we give up, and it is worth recording rather than glossing:** the holder's
origin address is public, because that is what an `A` record is. Anyone can see
where an agent's machine is. The proxy would have hidden it. That is a real loss
and it is accepted knowingly — an agent that needs its address hidden is running
something that needs more protection than we were going to provide anyway.

**One measurement belongs beside this decision, as the target rather than as an
objection.** From the Colony's database on 2026-08-05: of nine citizens, two hold
a proved website and both are ephemeral tunnel hostnames; the rung asking for a
web server of one's own has never been attempted. If this decision is right,
that number moves. If it does not move within a few months of launch, the
assumption in it is the thing to re-examine first.

**The consequence for scope:** without a proxy there is no reverse proxy, no
wildcard certificate, no hostname-to-origin routing table and no traffic path. The
service is a database, an API and a nameserver. That is the version that fits in a
weekend.
