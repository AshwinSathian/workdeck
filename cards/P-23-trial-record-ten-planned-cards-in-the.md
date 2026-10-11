---
id: P-23
title: Trial record: ten planned cards in the evidence page
size: M
depends: P-22
done: false
---

## Read
- docs/design-0.3.md (the first trial specification; it must be on the base branch)
- docs/design-0.2.md#14-trial-and-release
- docs/design-0.2.md#2-goals-and-non-goals (goal 6)
- docs/design-0.2.md#18-risks
- docs/design-0.2.md#22-decisions-locked-and-what-is-deferred (decision 1)
- docs/development/scope-0.2.md (the section "How we will know it works")
- docs/evidence.md (the trial section that P-22 wrote)
- log/ (the session logs of the trial cards)

## Touch
- docs/evidence.md
- docs/development/README.md
- test/cases/02-plugin.sh
- README.md (only the Known limits bullet on commands that are not pre-approved, and only if the prompts written down differ from it)

## Tests
- test_evidence_records_the_trial_of_the_planner

## Acceptance
- Ten planned cards were implemented and merged across the two trial repositories before this card started. If fewer were, the card stops with a `## Blocked` section.
- For each of the ten, docs/evidence.md has every measure of the table in design section 14, read from the place that table names.
- The two repositories' figures are in separate tables.
- The page gives, for each plan run, its growth and the outline findings with what was done about each, from the plan pull request's body.
- The page says how many of the ten were S and how many M, and says in words whether goal 6 was met.
- The page says whether any row had to be cut again before its card could be written. If one was, the page says the release waits, and for what.
- The page says whether either trial repository's CI, on `card lint` 0.1.3, failed on a planned deck.
- The page says which case of section 22, decision 1, holds on the main branch: no reachable half of a 0.3 feature, or one, named.
- The page states no threshold and no verdict. The maintainer reads the record and decides whether to tag.
- Every figure on the page can be traced to a pull request, a session log or a command, and the page says which.
- Every fault that P-21 listed is closed by a merged card, or is listed on the page as open.
- For one plan session and one card session of the trial, the page lists each permission prompt as the maintainer wrote it down when it appeared, under the conditions the last note gives. If the list differs from the README's Known limits bullet on commands that are not pre-approved, the bullet is corrected.
- The page says which of these the trial met, and what happened: a card changed after its approval, so that the part "Changes to the card since it was approved" holds a difference; a no in step 8 of plan; a plan pull request resumed in step 2; a revision that adds a row for new code; a refusal by `card plan new`. One that was not met is said to be not met.
- For each plan run of the trial, the page says what each launch of the plan reviewer was given and whether the reviewer ran `git hash-object`, read from the transcript, and whether the body has each finding of each reviewer run as one line.
- Where `/workdeck:init` was typed in a trial repository that had `workdeck.conf`, the page says, from the transcript, whether each of the four steps was asked alone and answered before the next, or said in one line that it had nothing to offer, whether the question about the branch and each question of the third step were asked alone, and whether the closing message named `/workdeck:plan`. Where the protocol section differed, the page says what the fourth step offered. If init was not typed in such a repository, the page says so.
- For one plan session and one card session of the trial, the page says, from the transcript: whether a card, an outline, a test, code, the session log or the body of a pull request was written or changed by a shell command that is not a `card` command, and which; whether `card tokens` ran before the commit of the plan and once only; whether handoff measured again; whether the body of each pull request, and handoff's report, says what its figures leave out; and by how much the growth in the log or the body is short of the transcript's. If a quick card was run, the same for its session.

## Out of scope
- The version, the tag, and the decision to release. P-24 carries it.
- A change to the plan skill, the outline format or any check because of what the trial showed. Each is a card of its own, written after the maintainer has read the record.
- New default budgets. Section 22, decision 6: the trial's figures decide, in a later card.
- The README's Evidence section. A quick card after the tag decision.

## Notes
- The second repository may be private. Then its figures are from its logs and cannot be checked from outside; say so, as the page does for the quick-card run of 0.1.
- The measure "files added to `Touch` after approval" is read from the part of each pull request body that handoff writes (P-15). If a body lacks it, `git diff <approval commit> HEAD -- <card file>` on the merged branch gives the same.
- With ten cards no count carries a threshold: a planner that misses a file on half its cards passes a "more than half" test 62 times in 100. Do not write one into the page.
- From the second review of P-15 (`docs/development/review-0.2.md`, eighteenth pass): a card that had a review-fixes session has the part as its first handoff wrote it. Handoff does not write the body again, so a `Touch` line added while fixing review comments is missing from it. For such a card read `git diff <approval commit> HEAD -- <card file>` on the merged branch, not the body.
- From the reviews of P-21 (`docs/development/review-0.2.md`, twenty-fourth pass): the last two `Acceptance` items and the README line under `Touch`. P-21 could only infer prompts from a pasted terminal and from waits in the transcripts, and two of its inferences were wrong. A session counts for the prompt record only if it was started with `--setting-sources project` and `--permission-mode default`, stayed in that mode, and every prompt was answered with a plain yes; without those the maintainer's own allow rules apply, which is how the quick-card run of 0.1 failed to show it.
- From the reviews of F-02 (`docs/development/review-0.2.md`, twenty-sixth pass): the `Acceptance` item on the plan reviewer's launches. Nobody had seen a session follow these sentences when F-02 was merged.
- From the reviews of F-03 (`docs/development/review-0.2.md`, twenty-seventh pass): the `Acceptance` item on init. Nobody had seen a session follow the sentences of F-03 when it was merged. What it says of a fenced code block needs a protocol section that differs and holds a fence; `docs/development/later.md` has that case.
- From the reviews of F-04 (`docs/development/review-0.2.md`, twenty-eighth pass): the `Acceptance` item on files written by a shell command. Nobody had seen a session follow the sentences of F-04 when it was merged. One fault that P-21 listed is not closed by F-04: the growth in a session log and in a plan body is measured before the commit, the push and the pull request. F-04 says what the figure leaves out and does not make it whole, so list that fault on the page as open. The growth this card reads from logs and from plan bodies for the table of design section 14 is short in the same way; `docs/reference.md`, under Configuration, says by how much it was in the hand runs.
