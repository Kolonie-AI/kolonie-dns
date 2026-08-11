#!/bin/bash
# What this repository checks about itself. `AGENTS.md` §9.
#
# Usage: bash .github/scripts/check.sh
#
# ## Why there is one at all, on a repository with no code
#
# `kolonie-docs#231` made the organisation's hourly worker read each repository's
# check command out of its `AGENTS.md`. A repository that names none **stops the
# run** rather than having one guessed for it — so until `kolonie-dns#15` this
# repository was a trap: the first issue labelled `agent:opencode` on #9–#14
# would have failed for a reason that had nothing to do with it, and the failure
# would have looked like the issue's fault.
#
# The honest answer was not `true`. A check command that passes whatever the tree
# looks like teaches the next reader that green means nothing, which is
# `kolonie-docs/AGENTS.md` §10's own argument, and it would have made the trap
# quieter rather than removing it.
#
# So this checks what there is. Today that is Markdown. Four of the five failures
# below are the ones `kolonie-email/.github/scripts/check.sh` already checks —
# real failures that have happened to sibling repositories, and all four apply
# here unchanged with `M-` becoming `N-`:
#
#   1. a relative link that resolved when it was written and does not now
#   2. a decision file the register never cites
#   3. an `N-` number used twice, which §4 of `AGENTS.md` says is the reason this
#      numbering space exists at all
#   4. a secret in the tree, which is §5's first red line
#
# **The fifth is this repository's own**, and it is here because §5 names a red
# line the mail repository does not have:
#
#   5. an address of this project's machine, in any file
#
# The machine is arriving (#10) and the first person to paste its address into a
# runbook will not be doing it maliciously. That is exactly the failure a pattern
# catches and review does not.
#
# **It grows with the repository rather than being replaced by what comes next.**
# When `db/`, `api/` and `dns/` hold code, their tests are added below and these
# stay: a broken link does not stop mattering because there is now a suite.

set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$ROOT" || exit 1

FAILED=0

fail() {
  printf '   FAIL %s\n' "$1"
  FAILED=1
}

heading() {
  printf '\n── %s\n' "$1"
}

# --- 1: every relative link resolves ----------------------------------------
# Only relative ones. An external URL that 404s is somebody else's repository
# changing under us, which a check run on every push would report as our defect
# and which no commit here can fix.
heading "every relative link resolves"
broken=0
while IFS= read -r file; do
  # `](target)` where the target is neither absolute, nor a fragment, nor a mail
  # link. The fragment is stripped: a link to `#section` inside a file that
  # exists is not a broken path, and checking anchors would mean parsing headings
  # for a class of defect nobody has hit here yet.
  while IFS= read -r target; do
    [ -n "$target" ] || continue
    path=${target%%#*}
    [ -n "$path" ] || continue
    resolved=$(cd "$(dirname "$file")" && printf '%s' "$(realpath -m "$path")")
    if [ ! -e "$resolved" ]; then
      fail "$file → $target"
      broken=$((broken + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "$file" \
             | sed -E 's/^\]\(//; s/\)$//' \
             | grep -vE '^(https?:|mailto:|#)')
done < <(find . -name '*.md' -not -path './.git/*')
[ "$broken" -eq 0 ] && echo "   ok"

# --- 2: the register and the directory agree --------------------------------
# The failure this catches is one-directional and silent: a decision written as a
# file and never added to the register is invisible to anybody reading the
# register, which §4 calls the one place a settled question is answered.
heading "every decision file is in the register"
uncited=0
for file in docs/decisions/*.md; do
  [ -e "$file" ] || continue
  slug=$(basename "$file" .md)
  if ! grep -q "decisions/$slug.md" docs/decisions.md; then
    fail "docs/decisions/$slug.md is not cited by docs/decisions.md"
    uncited=$((uncited + 1))
  fi
done
[ "$uncited" -eq 0 ] && echo "   ok ($(ls docs/decisions/*.md 2>/dev/null | wc -l) files, all cited)"

# --- 3: no `N-` number is used twice ----------------------------------------
# §4: the whole reason this repository numbers `N-` rather than `D-` is that `D-`
# belongs to `kolonie-platform` and is already contested by two agents. A
# collision here would be the same defect arriving by the door that was built to
# keep it out.
#
# **Only the number that opens a row counts as an assignment.** A register row
# cites other decisions in its prose and the open-questions table below it cites
# several — reading every `N-` in the file would report `N-013` as a duplicate
# because two rows refer to it, which is the register working rather than
# failing.
heading "no N- number is used twice"
dupes=$(grep -oE '^\|[[:space:]]*N-[0-9]+' docs/decisions.md \
          | grep -oE 'N-[0-9]+' | sort | uniq -d)
if [ -n "$dupes" ]; then
  while read -r d; do fail "$d opens more than one row of the register"; done <<< "$dupes"
else
  echo "   ok ($(grep -cE '^\|[[:space:]]*N-[0-9]+' docs/decisions.md) decisions, all distinct)"
fi

# --- 4: no secret in the tree -----------------------------------------------
# §5's first red line, made checkable. It is deliberately a small set of shapes
# that are unambiguous rather than a broad one that cries wolf: a check nobody
# believes is worse than none, and a false positive on every `token` in prose is
# how that happens.
#
# The TSIG key and the DNSSEC private key are this repository's own two, and both
# have a shape. A TSIG secret is base64 in a `key` clause; a DNSSEC private key
# arrives as a PEM block or as BIND's `Private-key-format` file.
#
# **This file is excluded from its own scan.** The patterns are here, so a scanner
# that read itself would fail on every run — and the noise would be
# indistinguishable from the finding.
heading "no secret in the tree"
found=0
while IFS= read -r hit; do
  fail "$hit"
  found=$((found + 1))
done < <(grep -rInE \
  -e '-----BEGIN [A-Z ]*PRIVATE KEY-----' \
  -e '^Private-key-format:' \
  -e '(ghp|gho|ghs)_[A-Za-z0-9]{30,}' \
  -e 'github_pat_[A-Za-z0-9_]{30,}' \
  -e '(API_KEY|APIKEY|AUTH_TOKEN|SECRET|PASSWORD|PRIVATE_KEY|TSIG_KEY)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+-]{16,}' \
  -e 'secret[[:space:]]+"[A-Za-z0-9+/]{20,}={0,2}"' \
  --exclude-dir=.git \
  --exclude='check.sh' \
  . 2>/dev/null)
[ "$found" -eq 0 ] && echo "   ok"

# --- 5: no address of this project's machine --------------------------------
# §5's second red line: *"No address of the machine enters this repository
# either. It is named, never numbered."*
#
# So this refuses a literal address anywhere in the tree rather than trying to
# tell ours from somebody else's — a check that had to know our own address would
# need it written down here, which is the thing being prevented.
#
# **Four ranges are allowed, and each is allowed for a reason a reader can
# check**: the loopback and the unspecified address, because a runbook binding
# PowerDNS to `127.0.0.1` is describing a socket rather than a location; and the
# three documentation ranges of RFC 5737 — `192.0.2.0/24`, `198.51.100.0/24`,
# `203.0.113.0/24` — which exist for exactly this, so an example in
# `operations.md` has somewhere legitimate to live. Nothing else. A private
# `10.x` is still an address of a machine, and the hidden primary will have one.
#
# IPv6 is matched narrowly, on the documentation range's siblings rather than on
# the general form: `2001:db8::/32` is allowed and any other global unicast
# address — `2000::/3`, which is what a hexadecimal digit of 2 or 3 in the first
# position means — is refused. A pattern for every IPv6 form would match `N-005`
# ranges, times and hashes throughout the prose, and a check nobody believes is
# worse than none.
#
# **The allowed ranges are matched against the address and not against the
# line.** `grep -o` prints one match per line rather than the line it sat on, so
# a runbook that names `127.0.0.1` and the primary's real address in one sentence
# still fails on the second — which filtering whole lines would have let through,
# quietly, on exactly the file most likely to carry both.
heading "no address of this project's machine"
addresses=0
while IFS= read -r hit; do
  fail "$hit"
  addresses=$((addresses + 1))
done < <(grep -roInE \
  -e '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
  -e '\b[23][0-9a-fA-F]{3}:[0-9a-fA-F:]{2,}\b' \
  --exclude-dir=.git \
  --exclude='check.sh' \
  . 2>/dev/null \
  | grep -vE ':(127(\.[0-9]{1,3}){3}|0\.0\.0\.0|192\.0\.2\.[0-9]{1,3}|198\.51\.100\.[0-9]{1,3}|203\.0\.113\.[0-9]{1,3})$' \
  | grep -viE ':2001:0?db8:')
[ "$addresses" -eq 0 ] && echo "   ok"

echo
if [ "$FAILED" -ne 0 ]; then
  echo "something is wrong above."
  exit 1
fi
echo "all good"
