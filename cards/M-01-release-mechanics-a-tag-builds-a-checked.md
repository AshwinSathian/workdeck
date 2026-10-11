---
id: M-01
title: Release mechanics: a tag builds a checked, attested release
size: S
depends:
done: false
---

## Read
- docs/development/plan-0.2.0.md (the track this card belongs to, and what the maintainer does by hand)
- docs/design-0.2.md#21-build-order (item 11: the version is the last commit before the tag)
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decision 1: where 0.2.0 is tagged from)
- cards/P-24-release-version-0-2-0.md (the card that makes the release; this card builds what it uses)
- cards/S-04-release-0-1-3-the-renamed-code-under-its.md (how 0.1.3 was released by hand)
- .github/workflows/ci.yml
- README.md#install
- CHANGELOG.md
- cards/REVIEW.md

## Touch
- .github/workflows/release.yml (new)
- scripts/release-check.sh (new)
- docs/releasing.md (new)
- README.md (the download line gains the checksum; a link to docs/releasing.md under Contributing)
- CONTRIBUTING.md (one line that points at docs/releasing.md)
- Makefile (a `release-check` target)
- test/cases/02-plugin.sh

## Tests
- test_release_check_passes_on_this_tree_and_fails_on_a_version_mismatch
- test_release_workflow_runs_the_check_and_publishes_card_with_its_checksum
- test_releasing_doc_lists_every_step_the_workflow_does_not_do

## Acceptance
- `scripts/release-check.sh <version>` exits 0 only when `card version`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` where it names a version, the top entry of CHANGELOG.md and the README's download line all name that version, and nothing is under `## [Unreleased]`. Each failure names the file. It runs on bash 3.2 with the tools `bin/card` uses.
- `.github/workflows/release.yml` runs on a pushed tag `v*`: it runs `make lint`, `make test` and the release check against the tag's version, and stops on any failure before anything is published.
- On success it creates the GitHub release for the tag with three assets: `card` (the file `bin/card` as tagged), `SHA256SUMS`, and a build provenance attestation for `card`. The release notes are that version's entry of CHANGELOG.md, cut out by the script and not written by hand.
- The workflow's permissions are the least it needs, stated per job, and every action in it is pinned to a commit.
- The README's install line for people and CI shows how to check the downloaded `card` against `SHA256SUMS`, and `templates/workdeck.yml` is not changed here (P-24 owns it).
- `docs/releasing.md` is the checklist a maintainer follows: what the workflow does, what stays by hand (the decision to tag, the version commit, the tag, the repository's homepage, announcing), how to make the release from a branch when design-0.2 section 22, decision 1, requires it, and how to withdraw a bad release.
- The workflow is not run by this card: no tag is pushed. The test reads the file. `docs/releasing.md` says the first real run is P-24's, and what to check in it.

## Out of scope
- The version, the changelog entry and the tag of 0.2.0. P-24 owns them.
- Pinning the actions of `ci.yml`. M-02 owns it.
- A package for a package manager, a container image, a signed tag.
- Any change to `bin/card` or to a skill.

## Notes
- The repository's rule is that scripts need only git and the standard tools. `sha256sum` is not on macOS and `shasum -a 256` is not on every Linux image: the workflow may use either, the script must not need one.
- `gh release create` is available on the runners, and `gh attestation verify` is how a user checks the provenance. Read the current GitHub documentation for the attestation action before writing the step, and cite the page in docs/releasing.md.
- 0.2.0 may be tagged from a branch and not from main (design-0.2, section 22, decision 1). The workflow must not assume the tag is on main.
- A user who has the plugin receives it when `version` changes on the main branch, wherever the tag is (design-0.2, section 19, row 18). The release workflow publishes the `card` file; it does not deliver the plugin. docs/releasing.md has to say so.
