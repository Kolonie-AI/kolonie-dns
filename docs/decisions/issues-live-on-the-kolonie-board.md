# N-019 — Issues live on the Kolonie board

[← the register](../decisions.md)

Work for this repository sits on **project 1 of the `Kolonie-AI` organisation** —
the same board `kolonie-platform`, `kolonie-docs` and `kolonie-email` use — under
the label **`area:dns`**. There is no board of its own.

**A board is a work queue, not a security boundary.** What has to stay separate
here is what can transmit damage: accounts, credentials, the machine, the domain
([N-020](separate-in-every-account.md)). A queue transmits nothing. The same
agents work both projects, and a second board would only be a second place to
look — and the place people forget to look is where issues go to die.

It also keeps a `p1` here visibly competing with a `p1` on the platform. That
competition is the truth about where the maintainer's attention goes, and it is
better seen than split across two brackets where both look urgent.

`kolonie-email` decided the identical question the same way on 2026-08-04
([M-010](https://github.com/Kolonie-AI/kolonie-email/blob/main/docs/decisions/issues-live-on-the-kolonie-board.md)),
and this follows it deliberately rather than arriving at it again.

**The trap, and it is silent.** GitHub allows a project five auto-add workflows
and the Colony has spent all five on older repositories. **No workflow will ever
add an issue from this repository to the board.** An issue opened here and not
added by hand is not waiting — it is invisible, and nothing anywhere says so.

So the rule is one line and it belongs in the same breath as opening the issue:

```bash
gh project item-add 1 --owner Kolonie-AI \
  --url https://github.com/Kolonie-AI/kolonie-dns/issues/<n>
```

`kolonie-docs/AGENTS.md` §4 holds the full account of why this cannot be
automated: every alternative costs a stored `project`-scope token, which was
refused on `kolonie-docs#118`.
