# A map of `docs/`

Every file and directory here, one line each, in the order a newcomer should read them. The [README](../README.md) at the root comes before all of them: it covers installing, the loop, the card format, the skills and the hooks.

Two kinds of file live here, and the lists below say which is which:

- A **living** page describes the project as it is now, and changes when the project does.
- A **record** says what was planned, decided or found at one time. Records are never edited to read better. One changes only by an amendment that says it is one, or by an addition at its end, so that what was believed then can still be read.

## To use WorkDeck

- [`reference.md`](reference.md): living. Every `card` command, the card states, the outline format and the configuration keys.
- [`evidence.md`](evidence.md): living. What has been measured, where each number comes from, and what has not been shown.

## To understand why it is built this way

Read these three in order: each adds to the one before and is numbered the same way.

- [`design.md`](design.md): record. The design of 0.1, the core: cards, gates, hooks, the loop. Its last sections list every change made to it during the build.
- [`design-0.2.md`](design-0.2.md): record. The design of 0.2, the planner, which cuts a specification into rows. Its section 21 is the order the 0.2 cards follow.
- [`design-0.3.md`](design-0.3.md): record. The design of 0.3, teams: claiming a card, worktrees and parallel sessions. Not built.

## To work on WorkDeck

[`CONTRIBUTING.md`](../CONTRIBUTING.md) at the root comes first.

- [`releasing.md`](releasing.md): living. The checklist for a release: what the release workflow does and what stays by hand.
- [`site-spec.md`](site-spec.md): record, once planned. The specification of the project's website, written to be cut into cards by the planner.

## How it was built

None of this is needed to use WorkDeck. It is here so that every decision can be traced.

- [`specimen.md`](specimen.md): living. Start here. This repository read as a worked example: what to look at, practice by practice, what went wrong, and a table of figures that a script prints.

- [`development/README.md`](development/README.md): living. The index of the records below, with a longer line on each.
- [`development/plan-0.1.md`](development/plan-0.1.md): record. The build plan of 0.1, written before any code and kept as written.
- [`development/findings.md`](development/findings.md): record, added to. What turned out wrong or awkward while building, with the evidence and what was decided.
- [`development/later.md`](development/later.md): living. What was left out on purpose, added to as the work goes on.
- [`development/scope-0.2.md`](development/scope-0.2.md): record. The scope of 0.2 on one page, approved before its design was written.
- [`development/review-0.2.md`](development/review-0.2.md): record, added to. The adversarial reviews of the 0.2 scope and design, pass by pass: each finding, its evidence and what was decided.
- [`development/spike-0.2.md`](development/spike-0.2.md): record. The spike before the 0.2 build: the planner run by hand on two specifications before any check was written.
- [`development/spike-0.2/`](development/spike-0.2/): record. The spike's drafts of the plan skill and the plan reviewer, and the two outlines they produced.
- [`development/scope-0.3.md`](development/scope-0.3.md): record. The scope of 0.3 on one page, amended from the reviews of its design.
- [`development/review-0.3.md`](development/review-0.3.md): record. The reviews of the 0.3 scope and design, with the decisions taken from them.
- [`development/plan-0.2.0.md`](development/plan-0.2.0.md): record. The plan for the 0.2.0 release in three tracks: the trial, this repository as a specimen, and the website.

## Outside this directory

- [`../cards/`](../cards/): the repository's own deck. A card that is done is a record. [`../cards/REVIEW.md`](../cards/REVIEW.md) holds the rules every change is reviewed against.
- [`../log/`](../log/): one session log for each card session. Records.
- [`../examples/`](../examples/): a small project to run the commands in.
- [`../CHANGELOG.md`](../CHANGELOG.md): what each version changed, and what an upgrade needs.
