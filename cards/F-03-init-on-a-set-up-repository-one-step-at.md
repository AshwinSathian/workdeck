---
id: F-03
title: Init on a set-up repository: one step at a time, the protocol section's end
size: S
depends:
done: false
---

## Read
- docs/evidence.md (the section "Hand runs of the planner in a scratch repository", and under it "Faults found")
- docs/design-0.2.md#103-workdeckinit
- skills/init/SKILL.md ("A repository that is already set up", and step 10)
- test/cases/60-skills.sh (the `test_init_` cases)

## Touch
- skills/init/SKILL.md
- test/cases/60-skills.sh

## Tests
- test_init_asks_the_four_steps_one_after_another
- test_init_does_not_end_the_protocol_section_inside_a_code_block
- test_init_offers_only_a_yes_or_a_no_for_the_protocol_section
- test_init_gives_every_next_step_of_step_10_on_a_set_up_repository

## Acceptance
- The section says each of the four steps is asked and answered before the next is looked at, and that they are not put into one question.
- The fourth step says a line that starts with `# ` inside a fenced code block does not end the protocol section.
- The fourth step says the question has two answers, replace the whole section or leave it, and that no partial change is offered.
- The line "Then do step 10" says that every next step of step 10 is given, `/workdeck:plan` among them, also when none of the four steps wrote anything.

## Out of scope
- A first run of init. The hand run was on a repository that had `workdeck.conf`.
- Init on an up-to-date repository, on a new one, after a changed check command, and with many `.snap` files. Not run in P-21; docs/development/later.md has the line.

## Notes
- In the hand run the session asked all four at once, took `# run the check` inside a fence for the section's end, said that a replacement would leave the fence open, and offered "add the two bullets only" as its first answer. Step 10 already names `/workdeck:plan`; the session left it out, so the line that sends a set-up repository to step 10 is what changes.
- Two cases hold checksums of the init skill's steps, and `test_init_replaces_a_protocol_section_that_differs_from_the_template` holds the sentence on where the section ends (test/cases/60-skills.sh). Update them and say so in the log.
- If the design's section 10.3 has to change to say where the section ends, add docs/design-0.2.md to `Touch` with the reason.
