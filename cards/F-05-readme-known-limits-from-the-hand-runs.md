---
id: F-05
title: README Known limits from the hand runs
size: XS
depends: F-01, F-04
done: true
---

## Read
- docs/evidence.md (the section "Hand runs of the planner in a scratch repository", and under it "Faults found")
- README.md (Known limits: the bullet that starts "Not run:" and the bullet that starts "Some commands are not pre-approved")
- cards/P-21-hand-runs-of-plan-next-card-and-init-in.md (the note from the second review of P-19)

## Touch
- README.md
- test/cases/02-plugin.sh
- docs/development/review-0.2.md (the record of the reviews, the twenty-ninth pass)

## Tests
- test_readme_known_limits_say_what_the_hand_runs_showed

## Acceptance
- The "Not run" bullet is replaced by what was seen: a redirect and a pipe after the branch name did not make a deny rule match, and the skills now run the push as its own command.
- The bullet on commands that are not pre-approved names `git checkout`, `git pull`, `git add` and `git commit` as before, and says that in five hand-run sessions the commands that wrote files from the shell and several chained commands also waited for an answer.
- The bullet says that this is inferred from a pasted terminal and from waits in the transcripts, that no prompt was recorded as such, and it points to docs/evidence.md. It no longer says that nothing was recorded.
- The bullet names no command as prompted that has a permission entry.

## Out of scope
- Any other bullet of Known limits. F-01 owns the one on the permission entries.
- The FAQ sentence "works as before". It is a line in docs/development/later.md.
- A list from prompts written down by hand. P-23 makes that record and has the README in its `Touch` for it.

## Notes
- Depends on F-01 and F-04: both change what a session runs, and these bullets describe it.
