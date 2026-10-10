---
id: F-02
title: Plan skill: what the reviewer is launched with, and every finding in the body
size: XS
depends:
done: false
---

## Read
- docs/evidence.md (the section "Hand runs of the planner in a scratch repository", and under it "Faults found")
- skills/plan/SKILL.md (steps 7, 8 and 9)
- agents/plan-reviewer.md
- test/cases/60-skills.sh (the `test_plan_skill_` cases)

## Touch
- skills/plan/SKILL.md
- agents/plan-reviewer.md
- test/cases/60-skills.sh

## Tests
- test_plan_skill_gives_the_reviewer_only_the_outline_and_the_base_branch
- test_plan_skill_lists_each_finding_of_both_runs_once
- test_plan_reviewer_does_not_hash_the_specification

## Acceptance
- Step 7 says the reviewer's prompt is the outline's path and the base branch and nothing else, on the first launch and on the second: no summary of earlier findings, of what was changed, or of what the user decided.
- Step 7 says where a decision of the user goes instead: into the outline, as a `does` or a `not` line, so that the second run reads it there and does not raise the question again.
- Step 9 says the body lists each finding of each run as the reviewer gave it, one line per finding with its severity, none merged, split or left out, each with what was done.
- `agents/plan-reviewer.md` says that `card plan` has compared `spec_blob` with the specification and that the reviewer does not run `git hash-object`.

## Out of scope
- Whether two runs on one outline agree. The twenty-fourth pass of docs/development/review-0.2.md has the one comparison that was made.
- A permission entry for `git hash-object`.

## Notes
- Seen in both plan runs of P-21, on Sonnet and on Opus. On Opus the first launch was also given the session's own choices, and the second three decisions of the user.
- The body of the first run gave five findings as fixed, one of them half of another, and left out a nit.
- This card edits `skills/plan/SKILL.md` and `test/cases/60-skills.sh`, as F-01, F-02 and F-04 all do, and F-01 and F-04 both edit `skills/handoff/SKILL.md`. No dependency is written, because none needs the other's text. Start one after the other is merged.
