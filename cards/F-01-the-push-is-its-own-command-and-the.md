---
id: F-01
title: The push is its own command, and the refspec deny rule
size: S
depends:
done: true
---

## Read
- docs/evidence.md (the section "Hand runs of the planner in a scratch repository", and under it "Faults found")
- docs/design-0.2.md#19-claude-code-behavior-this-design-relies-on (row 12; read the `permissions` page again, on the page itself)
- templates/settings-permissions.json
- skills/handoff/SKILL.md (step 7)
- skills/plan/SKILL.md (step 9)
- test/cases/02-plugin.sh (the `test_permission_template_` cases and the `matches` helper above them)
- README.md (Known limits: the bullet that starts "The permission entries are not a sandbox")

## Touch
- templates/settings-permissions.json
- skills/handoff/SKILL.md
- skills/plan/SKILL.md
- test/cases/02-plugin.sh
- test/cases/60-skills.sh
- docs/design-0.2.md
- CHANGELOG.md
- README.md (only the Known limits bullet on the permission entries)
- docs/development/review-0.2.md (the record of the two reviews of this card, as every card of 0.2 has one)

## Tests
- test_permission_template_has_no_rule_that_mixes_a_wildcard_with_the_prefix_form
- test_permission_template_does_not_pre_approve_a_push_with_a_refspec
- test_handoff_runs_the_push_as_its_own_command
- test_plan_skill_runs_the_push_as_its_own_command

## Acceptance
- No rule of the template mixes `*` with a trailing `:*`.
- `git push origin card/<name>:main` and `git push origin plan/<name>:main` are not pre-approved. In this order of preference: a deny rule that the `permissions` page says refuses them; an `ask` rule, if the page has that kind, so that they prompt; allow entries narrowed until they no longer match a branch name with a colon. The session log says which was chosen and quotes the sentence of the page it rests on.
- If the page gives none of the three, the rule is removed, and the README's bullet on the permission entries says in words that a push with a refspec from a card or plan branch is pre-approved and that the base branch must be protected on the git host.
- Step 7 of handoff and step 9 of the plan skill each say that the push is run as its own command, with nothing chained before or after it and nothing after the branch name.
- Row 12 of design section 19 says what the hand runs showed: a redirect and a pipe after the branch name did not make a deny rule match, and a push that led a longer command was denied.
- The `## [Unreleased]` entry of the changelog has a line for the changed rule, and says what the owner of a repository set up earlier does: init merges only entries that are missing and removes none.
- The `matches` helper of test/cases/02-plugin.sh no longer reads `*:*` as a shell pattern, and the three cases that rest on it are changed to fit the rule chosen: `test_permission_template_denies_refspec_pushes`, `test_permission_template_denies_known_bad_pushes` and `test_permission_template_denies_a_plan_branch_push_with_a_further_argument`.

## Out of scope
- Which deny rule matched the denied push. It is not known, and the fix does not need it.
- The two README bullets that waited for the hand runs. F-05 owns them.

## Notes
- Claude Code 2.1.296 prints at every start: `Bash(git push *:*) mixes * with the trailing :* prefix syntax, so it is matched as a literal prefix`. Its advice, `Bash(git push *)`, would refuse every push and is not the fix.
- A pattern for "has a colon" may not exist: a rule that ends in `:*` is the prefix form. That is why the second acceptance item has three ways and the third has the case where none holds.
- `test_handoff_prints_the_changes_to_the_card_since_it_was_approved` holds a checksum of the handoff skill without the 0.2 addition (test/cases/60-skills.sh). A change to step 7 changes the sum; update it and say so in the log.
- No session can be run by a test. After the change, start Claude Code once in a repository with the new entries and write in the session log whether the warning is gone.
- This card edits `skills/plan/SKILL.md` and `test/cases/60-skills.sh`, as F-01, F-02 and F-04 all do, and F-01 and F-04 both edit `skills/handoff/SKILL.md`. No dependency is written, because none needs the other's text. Start one after the other is merged.
