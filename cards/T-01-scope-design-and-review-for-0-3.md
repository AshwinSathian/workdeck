---
id: T-01
title: Scope, design and review for 0.3
size: M
depends:
done: true
---

## Read
- README.md#roadmap
- docs/design.md
- docs/design-0.2.md
- docs/development/scope-0.2.md (the form of a scope note, and what 0.2 left to 0.3)
- docs/development/review-0.2.md (the form of a review record; findings 6 and 31 on cards that touch the same file)
- docs/development/findings.md
- docs/development/later.md
- cards/PLAN-01-scope-design-review-and-deck-for-0-2.md (the method this card repeats)
- cards/REVIEW.md
- bin/card (card_branches, deck_table, base_ref: how state is read from branches today)
- hooks/

## Touch
- docs/development/scope-0.3.md (new)
- docs/development/README.md (one row per new record)
- test/cases/02-plugin.sh (one case; the tests gate needs a named test)

## Tests
- test_scope_note_for_0_3_is_listed_and_exists

## Acceptance
- The scope note is one page and says what 0.3 is (teams: claiming a card, worktrees, parallel sessions), who it is for, what is out and the open risks.
- The note is a draft and its status line says so: the maintainer has not approved it, and it ends with the questions that are the maintainer's to decide, each with a recommendation.
- Every claim in the note about Claude Code or git behavior cites the documentation page it came from or the run that showed it, and anything not checked is marked unverified.
- The design was not started.
- No file under bin/, hooks/, skills/, agents/, templates/ or reference/ changed.

## Out of scope
- The design, the review record and the design as amended from the review. T-01b owns them, and the approval of this note with them.
- A deck for 0.3. The planner writes it in the 0.2 trial (P-22 and P-23); this card writes no card.
- Product code for 0.3.
- Any change to docs/design-0.2.md or to a card of the 0.2 deck, except P-22's dependency, which the split moved to T-01b.
- Shaping the design's sections to suit the planner. It is written for people; the bias of an author who knows it will be planned is recorded in docs/development/scope-0.2.md, risk 9.

## Notes
- This card is outside the 0.2 deck and depends on none of its cards. It can be started by id at any time while 0.2 is built. P-22 waits for it.
- Its id sorts after the deck on purpose, so `card next` offers the deck first. A design written after the spike (P-01) knows whether the outline format of 0.2 changed; one written before it does not.
- 0.2 serves the plugin to users from the main branch when its version changes (docs/design-0.2.md, section 19, row 18). The 0.3 design has to say how a half-built team feature stays unreachable on that branch.
- PLAN-01 took more than one session for the same four outputs. If the budget warning appears, hand off with `/workdeck:handoff split`: the scope note is the natural first part. P-22 is a card with a file and does not wait for a remainder, so in that handoff change P-22's `depends` from T-01 to the remainder that writes docs/design-0.3.md.
- 0.2 left these to 0.3: claiming, worktrees and parallel sessions, a script check that orders cards touching the same file, and two people planning at once (docs/design-0.2.md, section 2).
- The reviewer is a subagent launched for the purpose, not the session that wrote the design. Its reading stays out of this session's context, which is most of what makes the card fit. A pass by the writing agent is weaker evidence and the record says so where one is made, as the third part of docs/development/review-0.2.md does.
- 2026-10-11: split at handoff after the first of the four outputs, as the note above foresees. This card holds the scope note as a draft; T-01b holds the rest, and P-22 now depends on T-01b.
- test_docs_have_one_design_file_and_a_development_folder fails on any tracked file that names one of the old documentation directories; its pattern lists them.
