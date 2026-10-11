---
id: T-01c
title: Review of the 0.3 design, and the design as amended
size: M
depends: T-01b
done: false
---

## Read
- docs/design-0.3.md (the draft this card has reviewed and amends; its section 22 lists where it left the scope note)
- docs/development/scope-0.3.md (the six decisions the design has to follow)
- docs/development/review-0.3.md (the first pass, and the form of the record)
- docs/development/review-0.2.md (the form of a pass on a design; the third part says what a pass by the writing agent is worth)
- cards/T-01b-design-and-review-for-0-3.md (its Notes: what the design had to settle, and what was not checked)
- cards/REVIEW.md

## Touch
- docs/design-0.3.md (amended from the review)
- docs/development/scope-0.3.md (amended where the design, as reviewed, leaves it)
- docs/development/review-0.3.md (the passes on the design, after the first)
- docs/development/README.md (the rows for the design and the record)
- test/cases/02-plugin.sh (one case; the tests gate needs a named test)

## Tests
- test_development_records_for_0_3_are_listed_and_exist

## Acceptance
- The maintainer approved the draft of the design, or said what to change, before the review was launched. Merging T-01b's pull request is not that approval: its body says so.
- An agent that did not write the design reviewed the scope and the design against the code, and was told to assume both are wrong. The review record lists each finding with its evidence, and which the maintainer accepted.
- The design follows each of the six decisions of the scope note, or the review record says which one it changed and that the maintainer agreed. The eight open points of the design's section 22 each have a decision in the record.
- The scope and the design agree with each other and with the review record: no rule is in one and missing from the other.
- The maintainer approved each of this card's two outputs before the next was started: the review record, and the design as amended from the review. The design's status line then starts "Status: approved ".
- The design is one markdown file that is committed, so `/workdeck:plan` can take it as written.
- No file under bin/, hooks/, skills/, agents/, templates/ or reference/ changed.

## Out of scope
- A deck for 0.3. The planner writes it in the 0.2 trial (P-22 and P-23); this card writes no card.
- Product code for 0.3.
- Any change to docs/design.md, docs/design-0.2.md or a card of the 0.2 deck.
- Shaping the design's sections to suit the planner (docs/development/scope-0.2.md, risk 9).

## Notes
- The remainder of T-01b, split on 2026-10-11 after the draft of the design. P-22 depends on this card now: the trial plans the design as amended, not the draft.
- The test this card writes holds what T-01b's test, test_design_for_0_3_is_listed_and_numbered, does not: that the review record no longer says "The design is not written yet", that it has a heading for a pass on the design ("## ... pass, 2026-..: the design"), and that the design's status line starts "Status: approved ". T-01b wrote those three assertions, saw them fail and took them out at the split. It should hold more than strings where it can: the reviews of T-01's test found it passed on a file of one byte.
- An amendment that renumbers the design's sections, or changes the heading "... behavior this design relies on" or the columns of its table, changes T-01b's test. T-01's test holds the scope note's status line, its last heading and the six numbers under it.
- The reviewer is a subagent launched for the purpose, not the session that wrote the design. The plugin's agents may not be installed: T-01 and T-01b used a general-purpose agent. A pass by the writing agent is weaker evidence and the record says so.
- For the reviewer to attack first, from the writer: whether `card` should push at all, and what `Bash(card *)` then pre-approves (section 16); the detached HEAD a stopped start leaves in the main working tree; the mark that is missing for a branch with no claim commit against the scope's words; `WORKDECK_UNRELEASED`; whether `held mine` by email is enough; the row whose claim fails after `card plan start` wrote its file; and `card conflicts` run after the commit, when a conflict can no longer change what is handed off.
- Not run by T-01b: `git checkout --no-track -b`; anything on GitHub with a claim branch; a real `claude --worktree` session; the suite of this repository in a linked worktree. Rows 5, 6 and 19 of the design's section 19 are unverified, and rows 7, 13 (the version), 14 (exit 128), 15 and 20 rest on an earlier reading.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file that names one of the old documentation directories; its pattern lists them.
