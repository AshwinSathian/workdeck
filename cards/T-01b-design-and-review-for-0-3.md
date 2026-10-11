---
id: T-01b
title: Design and review for 0.3
size: M
depends: T-01
done: true
---

## Read
- docs/development/scope-0.3.md (the scope this card designs, its six decisions and what was run for its risks)
- docs/development/review-0.3.md (the first pass: what the reviews of the note found and ran, and what nobody ran)
- README.md#roadmap
- docs/design.md
- docs/design-0.2.md
- docs/development/scope-0.2.md (what 0.2 left to 0.3)
- docs/development/review-0.2.md (the form of a review record; findings 6 and 31 on cards that touch the same file)
- docs/development/findings.md
- docs/development/later.md
- cards/PLAN-01-scope-design-review-and-deck-for-0-2.md (the method this card repeats)
- cards/REVIEW.md
- bin/card (card_branches, deck_table, base_ref: how state is read from branches today)
- hooks/
- skills/next-card/SKILL.md (step 4: the base branch is checked out, which a linked worktree refuses)

## Touch
- docs/development/scope-0.3.md (amended from the review of the design)
- docs/design-0.3.md (new)
- docs/development/review-0.3.md (the passes on the design, after the first)
- docs/development/README.md (one row per new record)
- test/cases/02-plugin.sh (one case; the tests gate needs a named test)

## Tests
- test_development_records_for_0_3_are_listed_and_exist

## Acceptance
- The scope note was on the base branch before the design was written. Its six decisions were taken by the session that wrote it, on the maintainer's instruction, and the maintainer approved it by merging pull request 40.
- The design follows each of the six decisions, or the review record says which one it changed. It changed one, the order for a row in decision 2, and the scope note is amended with it; the maintainer's agreement is the merge.
- The design is its own file, docs/design-0.3.md, numbered like docs/design.md. It adds to docs/design.md and docs/design-0.2.md and says so.
- Every claim about Claude Code or git behavior cites the documentation page it came from, and anything not checked is marked unverified.
- An agent that did not write the design reviewed the scope and the design against the code, and was told to assume both are wrong. The review record lists each finding with its evidence, and which the maintainer accepted.
- The scope and the design agree with each other and with the review record: no rule is in one and missing from the other.
- The maintainer did not approve the three outputs one by one. After the draft of the design the maintainer told the session to have pull request 41 attacked by an agent that did not write it, to take every open decision and to carry them out. Merging that pull request is the approval of the design as decided, of the scope note as amended and of the review record.
- The design is one markdown file that is committed, so `/workdeck:plan` can take it as written.
- No file under bin/, hooks/, skills/, agents/, templates/ or reference/ changed.

## Out of scope
- A deck for 0.3. The planner writes it in the 0.2 trial (P-22 and P-23); this card writes no card.
- Product code for 0.3.
- Any change to docs/design-0.2.md or to a card of the 0.2 deck, except P-22's dependency in a split (see Notes).
- Shaping the design's sections to suit the planner. It is written for people; the bias of an author who knows it will be planned is recorded in docs/development/scope-0.2.md, risk 9.

## Notes
- 2026-10-11: the card was split at handoff after the draft of the design, into this card and a T-01c, and pull request 41 was opened for the draft. The maintainer then delegated the decisions (see `Acceptance`), the review and the amendments were made in the same pull request, and the split was undone: T-01c is gone and P-22 depends on this card again. The record is the second and third passes of docs/development/review-0.3.md.
- The remainder of T-01, split on 2026-10-11 after the scope note. T-01's test, test_scope_note_for_0_3_is_listed_and_exists, stays; this card adds the one for all three records.
- 0.2 serves the plugin to users from the main branch when its version changes (docs/design-0.2.md, section 19, row 18). The 0.3 design has to say how a half-built team feature stays unreachable on that branch.
- If the budget warning appears, hand off with `/workdeck:handoff split`: the design before its review is the natural part. P-22 does not wait for a remainder, so in that handoff change P-22's `depends` to the card that ends with docs/design-0.3.md amended from the review.
- Not checked for the scope note, and the design's to check or to mark unverified: a real `claude --worktree` session (the hooks' working directory there, and which branch Claude Code deletes when the session ends on a `card/*` branch), and anything on GitHub with a branch that holds only the claim commit.
- From the reviews of the note, for the design to settle: the command of `card` that makes the claim commit and where its differing line comes from; how the start asks the remote for a branch of an id after a failed push (`git ls-remote` is not among the permission entries); the lookup of a card's branch by id, which must not be next-card's `git branch --list "card/<id>*"`, since that lists a longer id too; a quick card's branch named by its id alone; how a claim only on the remote is known to be the user's own; the conflict report at handoff (`git merge-tree --write-tree` needs git 2.38); and the sentences of next-card that a claim made first makes false, "nothing was committed and no branch exists" among them.
- T-01's test, test_scope_note_for_0_3_is_listed_and_exists, holds the start of the note's status line, "Status: decided on ", its last heading, "## Decided on ", the numbers 1 to 6 under it and the heading "### The six decisions" of the review record. An amendment that changes one of them changes the test.
- The test this card writes should hold more than that the three files exist: the second review of the note found that T-01's test passed on a file of one byte.
- The reviewer is a subagent launched for the purpose, not the session that wrote the design. Its reading stays out of this session's context, which is most of what makes the card fit. A pass by the writing agent is weaker evidence and the record says so where one is made, as the third part of docs/development/review-0.2.md does.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file that names one of the old documentation directories; its pattern lists them.
