---
id: M-02
title: CI and supply chain: pinned actions, link check, code owners
size: S
depends:
done: true
---

## Read
- docs/development/plan-0.2.0.md
- .github/workflows/ci.yml
- templates/workdeck.yml (the workflow init offers to users; it should follow what this repository does)
- SECURITY.md
- docs/development/later.md (the items on shellcheck versions and on skipped cases)
- cards/REVIEW.md

## Touch
- .github/workflows/ci.yml
- .github/dependabot.yml (new)
- .github/CODEOWNERS (new)
- scripts/check-links.sh (new)
- Makefile (a `links` target, and `check` that runs lint, test and links)
- SECURITY.md (what is pinned and how a release is verified, in two lines)
- templates/workdeck.yml (the action it uses is pinned the same way)
- test/cases/02-plugin.sh
- scripts/ci-shellcheck.sh (new) the one shellcheck version and its checksums, in one place for the two workflows that lint
- .github/workflows/release.yml M-01's workflow lints too: with the runner's older shellcheck a tag could fail a lint that CI passed. It gains the same install step and the link check, and nothing else
- docs/releasing.md four words: its list of what the release workflow checks gains the link check

## Tests
- test_every_workflow_action_is_pinned_to_a_commit
- test_workflows_state_their_permissions
- test_markdown_links_and_anchors_resolve
- test_check_links_reports_a_broken_link_and_a_broken_anchor

## Acceptance
- Every `uses:` line in `.github/workflows/` and in `templates/workdeck.yml` names a 40-character commit, with the version in a comment beside it. A test fails on a tag or a branch there.
- Every workflow has a top-level `permissions:` block, and none grants more than its jobs use.
- `.github/dependabot.yml` updates the `github-actions` ecosystem weekly, so the pins do not rot.
- `.github/CODEOWNERS` names the maintainer for everything, and separately for `bin/card`, `hooks/`, `templates/settings-permissions.json` and `.github/workflows/`: the files where a change is a security change.
- `scripts/check-links.sh` checks every relative link in every tracked markdown file: the target exists, and an `#anchor` matches a heading of the target as GitHub makes anchors. It skips links inside code fences and `http` links, makes no network call, and runs on bash 3.2 with the tools `bin/card` uses. Exit 1 with one line per broken link, `file:line: target`.
- `make check` runs lint, test and links, and CI runs the link check on both systems.
- Every link the script reports in this repository is fixed in this card, or listed in the card's Notes with the reason it stays.
- The version of shellcheck that CI installs is the same on both systems, or the workflow prints the two versions and `docs/development/later.md` loses the item only if it is.

## Out of scope
- The release workflow. M-01 owns it and pinned its own actions. This card's branch is cut from M-01's, and changes that workflow in two steps only, as `Touch` says.
- Checking external links. They change without a commit here, and a failing build on someone else's outage teaches nothing.
- A scorecard service, a code scanner for a language this repository does not have, branch protection: the last is a setting, in the plan's list for the maintainer.
- The website's workflow. The site's cards own it.

## Notes
- The link check may find many broken anchors in the design files, which cite sections by number in prose and not by link; prose is not checked.
- Cards cite `docs/design-0.2.md#14-trial-and-release` under `Read`. Those are links in the sense of this check only if written as markdown links; a `Read` item is a path with an anchor. Check them too: a `Read` item whose anchor matches no heading sends a session to nothing. Say in the script's header which of the two forms it reads.
- `claude plugin validate` installs Claude Code with npm at the latest version in CI. Pinning it would hide a breaking change that the validate step exists to catch. Leave it, and say so in a comment.
- 2026-10-11, from this card's session and its review. The link check found no broken link in this repository, so none is listed here; the reviewer planted two in a copy of each of the 166 files and all 332 were reported.
- The check also reads a markdown file that is neither tracked nor ignored, which is more than the `Acceptance` says. A new file is untracked until handoff commits it, and would otherwise be checked first in CI. The cost: a stray untracked file with a broken link fails `make test` until it is removed or ignored.
- The script is not a markdown parser. Its header lists what it does not read: a heading underlined with `===`, an HTML anchor, a path with parentheses, a letter outside ASCII in an anchor.
- Both systems now get shellcheck 0.11.0 from `scripts/ci-shellcheck.sh`, checked against a checksum, so `docs/development/later.md` loses its item. Whether the two runners accept the script is shown by this pull request's own CI run and by nothing before it.
