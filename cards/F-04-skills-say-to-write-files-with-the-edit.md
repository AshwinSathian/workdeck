---
id: F-04
title: Skills say to write files with the edit tools; what the growth figure leaves out
size: S
depends:
done: false
---

## Read
- docs/evidence.md (the section "Hand runs of the planner in a scratch repository", and under it "Faults found")
- reference/implement.md
- skills/next-card/SKILL.md
- skills/plan/SKILL.md (steps 5 and 9)
- skills/handoff/SKILL.md (steps 6 to 8)
- docs/reference.md (the session log's measured fields)
- test/cases/60-skills.sh

## Touch
- reference/implement.md
- skills/next-card/SKILL.md
- skills/plan/SKILL.md
- skills/handoff/SKILL.md
- docs/reference.md
- test/cases/60-skills.sh

## Tests
- test_skills_say_to_write_files_with_the_edit_tools
- test_handoff_says_what_the_growth_figure_leaves_out
- test_plan_skill_says_what_the_growth_figure_leaves_out

## Acceptance
- `reference/implement.md` and the next-card, plan and handoff skills each say, once, that a card, an outline, a test, code and the session log are written and changed with the Write and Edit tools, and not with `python3`, `cat >>`, `sed -i` or another shell command.
- Handoff says the growth in the log and in the body is measured in step 6 and leaves out step 7. The plan skill says the figures in its body leave out the commit, the push and the pull request. docs/reference.md says the same of the measured fields.
- No step is reordered. `card log-new` stays before the commit.

## Out of scope
- A rule to run a `card` command alone. Chains of `card` commands with `echo "... $?"` or `sed -n` waited in the hand runs and chains with a plain `echo ---` did not; the runs do not show why. The session of P-23 that writes each prompt down by hand may.
- New permission entries.
- Making the figure whole. It would need the log written after the commit that holds it.

## Notes
- From the hand runs: every file a session wrote with a shell command came as a prompt chained with other commands, where a yes to the edit was also a yes to the rest. The Write and Edit tools ask too, in default mode, but show the change alone.
- The figure left out about 5,000 tokens in each of the two card sessions, and 1,607 and 4,182 in the two plan runs.
- The handoff skill and steps 1 to 5 of next-card are held by checksums in test/cases/60-skills.sh. Put the new sentence where a sum allows it or update the sum, and say so in the log.
- This card edits `skills/plan/SKILL.md` and `test/cases/60-skills.sh`, as F-01, F-02 and F-04 all do, and F-01 and F-04 both edit `skills/handoff/SKILL.md`. No dependency is written, because none needs the other's text. Start one after the other is merged.
