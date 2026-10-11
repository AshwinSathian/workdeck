---
id: M-04
title: Example: a planned deck, from specification to card
size: S
depends:
done: false
---

## Read
- docs/development/plan-0.2.0.md
- examples/hello-deck/ (the form of an example: its README, its deck and how the suite checks them)
- docs/design-0.2.md#5-outline-format
- docs/design-0.2.md#6-rows-in-the-deck
- docs/design-0.2.md#7-planned-cards
- docs/reference.md (the part on `card plan`)
- test/cases/02-plugin.sh (the case that runs the hello-deck example and compares its README with real output)
- cards/REVIEW.md

## Touch
- examples/planned-deck/ (new: README.md, workdeck.conf, specs/, cards/, cards/plan/, log/, src/, tests/, test.sh)
- examples/hello-deck/README.md (one line that points at the planned example)
- README.md (the line that names the examples)
- test/cases/02-plugin.sh

## Tests
- test_planned_deck_example_passes_lint_and_plan
- test_planned_deck_example_shows_a_row_a_planned_card_and_a_remainder
- test_planned_deck_readme_output_is_real

## Acceptance
- `examples/planned-deck/` is a small project that the planner's parts can be read from without running an agent: a specification of about forty lines with five or six headings, its outline with four to six rows and a `Not planned` list, one row already done as a planned card with its session log, one planned card that was split with its remainder, and at least two rows with no card file yet, one ready and one waiting.
- In it `card lint` and `card plan` pass, `card list` shows `[row]` on the rows with no file, and `card next` offers the ready row. `card show` for that row prints `row: no card file yet`.
- The done planned card's `Read` starts with the specification and its `(row ...)` comment, as `card plan start` writes it, and `card plan check` passes for the card that is not started.
- The README walks the example in the order a user meets it: the specification, the outline and why each row is cut as it is, what `/workdeck:plan` did to produce it, what `/workdeck:next-card` does with a row, the approval commit, and what handoff adds to the pull request. Every block of command output in it is real: a test runs the command in a copy of the example and compares.
- The README says plainly what the example cannot show from files alone: the plan reviewer's findings, the question to the user, and the commits, which a directory inside another repository does not have. For those it links the trial's pull requests in `docs/evidence.md` once P-23 has them, and until then says they are to come.
- The example's own test, `test.sh`, passes, and the code it tests is as small as hello-deck's.
- `card` 0.1.3 `lint` passes on the example's deck: the case that fetches 0.1.3 covers it, or says why it cannot.

## Out of scope
- An outline produced by a real plan run. The example is written by hand to show the format; the trial (P-22, P-23) is the record of real runs.
- A change to hello-deck beyond the one line.
- An example for 0.3.

## Notes
- The example sits inside this repository, so its deck has no branches of its own: every state that needs a branch (`active`, `review`, `blocked`) cannot be shown, and the README should say so and not fake it.
- `card` finds the repository root with git, so a test that runs `card` in the example has to copy it to a temporary repository first, as the hello-deck case does.
- `card plan check M-04` fails on the `Touch` entry for the new directory: a directory cannot be marked `(new)`, and the files in it are not known until the example is written. The check is not a gate for a hand-written card. Replace the entry with the files once they exist.
- Pick a subject for the specification that is not the planner itself and not hello-deck's greeting again: something with a real dependency between two rows and one heading that produces no card.
