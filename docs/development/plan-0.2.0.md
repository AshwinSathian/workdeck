# Plan for the 0.2.0 release

Date: 2026-10-11
Status: written by a session on the maintainer's instruction, after the 0.3 design merged (pull request 41). Not reviewed. Merging the pull request that adds it approves the three tracks and their order; the cards and the website's specification are each approved as they are started.

The maintainer asked for three things together: the 0.2.0 release, the repository brought to the state of a specimen for a project run this way, and a comprehensive website. This page says what each is, what order they go in, what the maintainer has to do by hand, and what is not decided.

## What is already true

- 0.1.3 is released. `card` and the plugin on the main branch hold all of 0.2's code, unreleased: `card version` prints 0.1.3.
- The 0.2 deck has three cards left: P-22 (trial setup), P-23 (the trial's record) and P-24 (the release). P-22 is ready and carries a question only the maintainer can answer.
- The 0.3 design is on the main branch, decided. It is one of the two specifications the trial plans.

## The three tracks

### Track 1: the trial and the release

P-22, P-23, P-24, as designed in `docs/design-0.2.md`, section 14. Nothing in them changes except two things: P-24 now waits for the cards of track 2, and it refreshes the website's generated regions if the site exists.

The trial is most of the work, and most of it is the maintainer's: two plan runs and about ten card sessions across two repositories, each ending in a pull request to merge. It must be run with the plugin loaded (`claude --plugin-dir <checkout of main>`): every session so far in this repository ran the skills by hand, so no log here has measured tokens, and the trial exists to get them.

One result stops the release: a row that had to be cut again before its card could be written.

### Track 2: the repository as a specimen

Five hand-written cards, M-01 to M-05. They are written by hand, not planned, because each is small and names files that exist.

| Card | What | Why it is part of the release |
|---|---|---|
| M-01 | A tag builds the release: the suite, a version check, `card` with its checksum and a provenance attestation, notes cut from the changelog; `docs/releasing.md` | P-24 uses it. 0.1.3 was released by hand |
| M-02 | Actions pinned to commits, permissions stated, updates for the pins, a link and anchor check for every markdown file, code owners | A repository that tells others to pin `card` should pin what it runs |
| M-03 | Issue forms, SUPPORT.md, a map of `docs/`, a first contribution walked through the loop, how decisions are made | A stranger's first hour |
| M-04 | `examples/planned-deck/`: a specification, its outline, a planned card, a split and rows not yet started, with real output in its README | 0.2 has no example. hello-deck shows 0.1 only |
| M-05 | `docs/specimen.md`: what to look at here, practice by practice, with the failures, and figures printed by a script | This is the track's point |

M-01 to M-04 depend on nothing and can run in any order, alongside the trial. M-05 follows M-03 and M-04.

"Specimen" here means that a reader can learn the method from the repository's own history, and can check every figure. It does not mean the repository claims the method works: `docs/evidence.md` holds what was measured.

### Track 3: the website

The specification is [`../site-spec.md`](../site-spec.md). It is not cut into cards by hand. It is planned with `/workdeck:plan docs/site-spec.md`, which the maintainer types, and each row becomes a card when `/workdeck:next-card` starts it.

That is deliberate. Hand-written cards for a site that does not exist would name files nobody has created, which is the fault 0.2 was built to remove. And it puts a third specification through the planner, written for people and not for it.

The site's cards are outside the trial. P-23 records them in a table of their own and does not count them toward its ten, unless the maintainer decides otherwise when reading the record.

The site is built on the main branch while the trial runs, and goes live only at the release (`site-spec.md`, "Launch").

## Order

1. Merge this plan.
2. The maintainer answers P-22's question: the second trial repository and its specification.
3. In parallel, in any order: P-22; M-01 to M-04; `/workdeck:plan docs/site-spec.md`.
4. The trial: `/workdeck:plan docs/design-0.3.md` here and the plan run in the second repository, then their cards, until ten are merged. Only the first six items of the 0.3 design's build order may merge before the tag (its section 21). The site's cards and M-05 run alongside.
5. P-23, the record. The maintainer reads it and decides whether to tag.
6. P-24, the release, through M-01's workflow.
7. The site's launch card, and the settings below.

The 0.3 design allows parallel sessions only once it is built. Until then "in parallel" means one session at a time in one working tree, in whatever order the maintainer likes, or separate clones.

## What only the maintainer can do

- Answer P-22's `Blocked` question.
- Type the skills: a session cannot run `/workdeck:plan`, `/workdeck:next-card` or `/workdeck:handoff` for itself.
- Merge every pull request. Approve each outline and each card when asked.
- Decide whether to tag, after reading P-23's record.
- Repository settings, none of which a card can change: a rule on the main branch that requires the CI checks and a pull request; Discussions on, if questions should not be issues; Pages on, with the workflow as its source; the homepage set to the site; a social preview image, which the site's cards draw; the description and topics checked against the README.
- The first run of the release workflow and of the Pages workflow, watched by hand.

## Not decided

1. **The second trial repository** (P-22). The release cannot be reached without it.
2. **Whether the site's cards count toward the trial's ten.** This plan says no.
3. **A custom domain for the site.** The specification keeps links relative so that either answer works.
4. **Whether 0.2.0 waits for the site.** This plan says the release does not wait: the site launches straight after it. If the maintainer wants them on the same day, P-24 gains a dependency on the last site card but one.
5. **Whether 0.2.0 waits for all of track 2.** This plan says yes, and P-24 depends on M-01 to M-05. M-05 is the one that could follow the release without harm.

## Risks

- The trial takes as long as ten cards take. Nothing here shortens it, and the two other tracks should not be allowed to stand in for it: a polished repository with no trial record is not a release.
- The site duplicates the documentation. The specification's answer is generated regions and a test that fails when they are stale; if that proves heavier than the pages it protects, the reference section is cut back to links before the stale check is weakened.
- The site's look cannot be checked by a script. Its first card settles it on two pages and the maintainer approves it before the rest.
- Three tracks in one working tree touch `README.md` and `test/cases/02-plugin.sh` again and again. Cards will conflict; 0.3's conflict report does not exist yet. Merge one before starting the next where two cards list the same file.
- The website's specification was written by an agent that knew it would be planned (the bias `scope-0.2.md` names in risk 9).
