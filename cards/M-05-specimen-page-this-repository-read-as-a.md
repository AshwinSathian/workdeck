---
id: M-05
title: Specimen page: this repository read as a worked example
size: S
depends: M-03, M-04
done: true
---

## Read
- docs/development/plan-0.2.0.md (what "specimen" means for this repository)
- README.md#how-this-was-built
- docs/development/README.md
- docs/evidence.md
- docs/development/findings.md (the headings only, and findings 10, 14 and 16: the first real runs)
- docs/development/review-0.3.md (the form of a review record, as the newest one)
- cards/PLAN-01-scope-design-review-and-deck-for-0-2.md
- cards/T-01b-design-and-review-for-0-3.md (a card whose acceptance changed in the open, and says so)
- cards/REVIEW.md

## Touch
- docs/specimen.md (new)
- scripts/specimen-stats.sh (new)
- README.md (the section "How this was built" points at the page)
- docs/development/README.md (one row)
- docs/README.md (one line; M-03 creates the file)
- test/cases/02-plugin.sh
- .github/workflows/ci.yml the checkout takes the whole history: the test of the page's figures counts merge commits, and a checkout of one commit has none
- .github/workflows/release.yml the same, because its first job runs the same suite

## Tests
- test_specimen_figures_match_the_script
- test_specimen_page_points_at_files_that_exist
- test_specimen_stats_counts_a_fixture_deck

## Acceptance
- `docs/specimen.md` tells a reader who wants to run a project this way what to look at here, practice by practice. For each it names one or two real files, cards, logs or pull requests and says what to notice in them: a scope note before a design; a design with a table of what it relies on and how each claim is known; an adversarial review by an agent that did not write the work, with findings, evidence and decisions; a decision overturned by a review; a card that was split, and why; a card whose `Touch` grew, visible in its pull request; a session log with measured tokens and one without, and why; a finding that changed the design; a hand run recorded with what was not run; a test that holds form and says so; something left out on purpose in `later.md`.
- It has a section on what went wrong and is still wrong, with the same weight as the rest: the token fields that are `unknown`, the reviews nobody reviewed, the claims marked unverified, the test that passed on a file of one byte.
- It has one table of figures, and every figure in it is printed by `scripts/specimen-stats.sh`: cards by prefix and by size, cards split, session logs and how many have measured fields, pull requests merged from `card/` and `plan/` branches as git records them, review passes recorded, tests in the suite. A test runs the script and compares each figure with the page.
- The script reads git and the files, makes no network call, runs on bash 3.2 with the tools `bin/card` uses, and is tested against a small fixture deck with known counts.
- Every path the page names exists, and every pull request it names is given as a number with a link. A test checks the paths.
- The page states no claim about how well the method works. It points at `docs/evidence.md` for measurements, and says what has not been measured.
- The README's section "How this was built" is shortened to a paragraph and a link to the page, and loses nothing that the page does not now hold.

## Out of scope
- New measurements. P-23 owns the trial's figures; this page links them when they exist and says when they do not.
- Rewriting any record under `docs/development/`. Records are not edited to read better.
- The website's page of the same subject. The site's cards build it from this file.

## Notes
- This card can run before or after P-23. If before, the page's links to the trial are sentences that say it is to come, and P-23's session adds them: say so in the handoff so that P-23's `Touch` gains the file.
- Pull request numbers come from merge commit subjects (`Merge pull request #N from .../card/...`). A squash merge has another subject; the script should count both forms and the page should say how it counts.
- 2026-10-11, from this card's session. The figures are those of one commit, which the page names, and the script takes a commit as its argument. The `Acceptance` does not ask for this. Without it the table would be wrong after every merge, and every card would have to change the page. The cost: nothing moves the pin, and the page says so. P-24 is the natural card to move it.
- This card ran before P-23, so the page says the trial has not been run. P-23's `Touch` should gain docs/specimen.md.
- "Model" is the maintainer's word for what this repository should be. The page should not use it of itself: it shows the work and lets the reader judge.
