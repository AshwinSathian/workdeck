# This repository, read as a worked example

WorkDeck was built with itself, and the records were kept. This page is for a reader who wants to run a project this way and would rather see one than be told: for each practice it names one or two real files, cards, logs or pull requests here, and says what to notice in them.

It shows the work and lets you judge it. It makes no claim about how well the method works. What has been measured is in [`evidence.md`](evidence.md), and what has not been measured is said there and at the end of this page.

## How it was built, in order

A coding agent built it under supervision, from a written design. The order was: a [design](design.md), an adversarial review of it, a [plan](development/plan-0.1.md), then the code, test first. Once `card` could run cards, the rest of the work became cards in [`cards/`](../cards/), each done on its own branch, through the gates, with a log in [`log/`](../log/). 0.2 began with a scope note, then a design, reviews, a spike and a deck. 0.3 has a scope note, a design and reviews so far, and no deck: it is not built.

The cards of 0.1 were driven by hand in one long session, without the plugin loaded, so their logs say `unknown` for the token fields. One card, the license, was run by the maintainer through `/workdeck:next-card` and `/workdeck:handoff`, and merged as [pull request 1](https://github.com/AshwinSathian/workdeck/pull/1). Of the 24 session logs for 0.1, its log is the only one with measured figures. What went wrong along the way is in [`development/findings.md`](development/findings.md), which also holds three independent reviews and what they overturned.

## A scope note before a design

[`development/scope-0.2.md`](development/scope-0.2.md) is one page: what 0.2 is, who it is for, what is out, and the open risks. Its status line says the maintainer approved it after one adversarial review, and [`design-0.2.md`](design-0.2.md) is written to it. The two files arrived in one commit, so for 0.2 the order rests on that status line. For 0.3 the history shows it: [`development/scope-0.3.md`](development/scope-0.3.md) merged as [pull request 40](https://github.com/AshwinSathian/workdeck/pull/40), and the design followed as [pull request 41](https://github.com/AshwinSathian/workdeck/pull/41).

What to notice: the scope note says what is out, and gives risks as things that may prove the plan wrong. The design that follows can be checked against it, and where the design left it, the note was amended and says so.

## A design that says how each claim is known

Section 19 of [`design-0.2.md`](design-0.2.md#19-claude-code-behavior-this-design-relies-on) is a table of every behavior of Claude Code the design relies on: the claim, the page of the documentation it comes from, and a status. The status says how the claim is known: read on a date, or seen in a run, with the run named.

What to notice: a claim that was only read is not written as if it were seen. [`design-0.3.md`](design-0.3.md) has the same table, and four of its rows say `unverified`.

## An adversarial review

[`development/review-0.2.md`](development/review-0.2.md), under "Second review, 2026-10-09: scope, design and PLAN-01", is a review of the 0.2 scope, the design and the card that wrote the deck, by an agent that did not write them. It read them against the code, and each finding has its evidence and what was decided.

What to notice: its last two parts, "What the reviewer looked for and did not find" and "Not reviewed". A review that lists only faults does not say how far it looked. Under "Not reviewed" is the deck itself. The fourth pass covers the deck, and says of itself that it is "by the agent that wrote the deck, with no second agent, so it is the weakest evidence in this record". The same file then holds a pass for the reviews of each card from P-03 to P-21 and F-01 to F-05, so the review of a card is a record and not a comment that scrolls away.

## A decision overturned by a review

[`development/review-0.3.md`](development/review-0.3.md), under "The six decisions", is a table of six questions about 0.3: what the draft recommended, and what was decided after other agents attacked it. Two rows say "Overturned".

One is which commit claims a row for a session. The draft said the commit of the approved card. The second review read the steps of next-card and found that this commit comes after the card is written, so two sessions started together would both write the card of one row. The claim was moved before the card is written. The other is a warning when two cards list the same file. The draft had it in, and it is out, with a report of conflicts at handoff in its place.

What to notice: the recommendation that lost is still in the table, beside what replaced it and why.

## A card that was split

[`cards/T-01-scope-design-and-review-for-0-3.md`](../cards/T-01-scope-design-and-review-for-0-3.md) asked for four outputs. Its session stopped after the first, and [`log/2026-10-11-T-01-1.md`](../log/2026-10-11-T-01-1.md) has the outcome `split`: the design could not start until the maintainer had approved the scope note. The rest became [`cards/T-01b-design-and-review-for-0-3.md`](../cards/T-01b-design-and-review-for-0-3.md).

[`cards/P-02b-card-plan-ids-and-sizes.md`](../cards/P-02b-card-plan-ids-and-sizes.md) is the other card with a remainder id, and it was cut before any work: its Notes say the review of the deck found 21 tests in one card, twice the largest card of 0.1.

What to notice: the first card is marked done for what it did, and its log says what it did not do. T-01b's `Acceptance` also changed in the open, and says so: "The maintainer did not approve the three outputs one by one."

## A card whose `Touch` grew

[`cards/P-11-stop-hook-leave-out-commits-that-change.md`](../cards/P-11-stop-hook-leave-out-commits-that-change.md) was written to change one hook and its test. Its `Touch` list ends with two entries that came from the second review of the card, each with a note beside it: the design, "after the second review: what is given up", and the review record, "the fourteenth pass". [Pull request 24](https://github.com/AshwinSathian/workdeck/pull/24) shows the card file changing with the code.

What to notice: the scope gate did not stop the session from changing another file. It made the session write down which file, where the reader of the pull request sees it.

## A session log with measured tokens, and one without

[`log/2026-10-06-DOC-02-1.md`](../log/2026-10-06-DOC-02-1.md) has three numbers that `card log-new` took from the session's transcript: the context when the session began, its peak, and the growth between them. Beside them is the budget for the card's size, which comes from the configuration. [`log/2026-10-11-T-01b-1.md`](../log/2026-10-11-T-01b-1.md) has the budget, and says `unknown` for the three numbers and for whether the session compacted.

What to notice: the second log puts no number where none was measured. Its Deviations section says the plugin was not installed in that session, and without the plugin's hooks nothing records where the transcript is. There is a third kind between the two, and the section on what went wrong says what it is.

## A finding that changed the design

Finding 15 of [`development/findings.md`](development/findings.md): a card that lived only on its branch showed as `done` before its pull request merged. The design's section 6 had said such a card takes `done` from the working tree, and had not considered that handoff writes `done: true` on that branch. It was found by the first pull request the build agent opened, [pull request 2](https://github.com/AshwinSathian/workdeck/pull/2), and fixed there.

What to notice: the finding starts with its status and its evidence, and here the evidence is a pull request anyone can open. Not every finding is like that: two of the sixteen have no status line, and the evidence of some is a run in a private repository.

## A hand run, with what was not run

[`evidence.md`](evidence.md#hand-runs-of-the-planner-in-a-scratch-repository), under "Hand runs of the planner in a scratch repository", records init, the plan skill, next-card and handoff, each typed by the maintainer in a session of its own, and the plan skill a second time. It ends with "Faults found", each with the file it is in, and "Not run": a list of the paths through the skills that nobody took.

What to notice: the second list. A run that passed says nothing about the branches it did not reach, and the page names them.

## A test that holds form and says so

The suite may use bash, git and the usual tools, and nothing that parses YAML or JSON. So `test_issue_forms_ask_for_what_a_bug_needs` in `test/cases/02-plugin.sh` cannot tell whether an issue form parses. Its comment says what it holds in place of that: each question is there, under the key and at the indent the schema gives it, "form, not a parse".

What to notice: the test does not claim more than it checks, and [pull request 45](https://github.com/AshwinSathian/workdeck/pull/45), which added the forms, says nobody had yet seen them on the host.

## Something left out on purpose

[`development/later.md`](development/later.md) lists what was thought of and not built. One line: a tests gate that matches the words of a `Tests` line within a window of lines, for nested test names. "Rejected for 0.1: it trades false failures for false passes."

What to notice: the reason is kept with the idea, so the next person who has it can see what it costs.

## What went wrong, and what is still wrong

Each of these has a record to open, as the practices above do.

- **Most logs have no measurement, and most that have one were measured by hand.** More than half of the session logs say `unknown` for the token fields; the table below has both counts. Of the logs with figures, three say whether the session compacted, which only the plugin's hooks record. The rest say `unknown` there: [`log/2026-10-09-P-02-1.md`](../log/2026-10-09-P-02-1.md) says under Deviations that its session ran without the plugin and that the transcript was passed to `card log-new` by hand. No budget warning could appear in those sessions: [`log/2026-10-10-P-11-1.md`](../log/2026-10-10-P-11-1.md) records a session that ended 791 tokens over its budget and was never warned.
- **The measured growth is short.** [`evidence.md`](evidence.md) says, under "Faults found", that the figure in a log is taken before the commit, the push and the pull request, and was short by about 5,000 tokens in each card session of the hand runs.
- **Fixes that nobody reviewed.** [`development/review-0.3.md`](development/review-0.3.md) says it twice: "Nobody reviewed the fixes that followed the third review", and of the design, "Nobody reviewed the fixes that followed the third pass". A review finds faults; the fixes are new work by the session that made the faults. Pull requests [43](https://github.com/AshwinSathian/workdeck/pull/43), [44](https://github.com/AshwinSathian/workdeck/pull/44), [45](https://github.com/AshwinSathian/workdeck/pull/45) and [46](https://github.com/AshwinSathian/workdeck/pull/46) say the same of themselves.
- **A deck reviewed by its writer.** The fourth pass of [`development/review-0.2.md`](development/review-0.2.md), on the deck of 0.2, calls itself the weakest evidence in that record, for that reason.
- **Claims marked unverified.** Section 19 of [`design-0.3.md`](design-0.3.md) relies on four behaviors that nobody has seen: among them, what a hook's working directory is in a session started in a worktree. For some of them the design names the step of the build that will settle it.
- **A test that passed on a file of one byte.** The first test for the 0.3 scope note passed on a note of one byte. A review found it and the test was changed. The next review found that the changed test had the same fault: it passed on a review record of one byte. Both are in [`development/review-0.3.md`](development/review-0.3.md). A named test that exists is what the tests gate checks, and that is all it checks.
- **Decisions the maintainer did not take.** For 0.3 the maintainer told the session to have its own pull request attacked and to take every open decision. [`cards/T-01b-design-and-review-for-0-3.md`](../cards/T-01b-design-and-review-for-0-3.md) says so in its `Acceptance`, and says that the merge is the approval. Whether that is enough is for the reader to judge.
- **The reviewer could not run its commands.** In the first full run, finding 10 of [`development/findings.md`](development/findings.md), four of the reviewer's commands were denied by the permission entries the project itself writes. It still returned findings, from what it could read.
- **The trial has not been run.** How cards written from a planner's rows hold up has not been measured. [`development/plan-0.2.0.md`](development/plan-0.2.0.md) says what the trial is and that a release waits for it.

## The figures

The figures are those of commit `85b5081292399de1fbbf1f6dbafa5dd7b43bc06e`, the merge of [pull request 41](https://github.com/AshwinSathian/workdeck/pull/41) on 2026-10-11. Every one is printed by `scripts/specimen-stats.sh` with that commit as its argument, and a test fails when this table and the script disagree. The script's header says how each is counted.

They are pinned to a commit so that the table is true of something a reader can check out, and does not go stale with every merge. Nothing moves the pin: the work since that commit, this page among it, is not counted. Run the script with no argument for the figures of today, and move the pin and the table together, at a release for one.

| Figure | Value |
|---|---|
| cards | 59 |
| cards by prefix | DOC 2, E 1, F 5, HOOK 4, P 25, PLAN 1, PLUG 2, Q 3, R 4, S 4, SKILL 4, T 2, TOK 2 |
| cards by size | XS 12, S 29, M 18 |
| cards with a remainder id | 2 (P-02b, T-01b) |
| session logs | 56 |
| session logs with measured tokens | 23 |
| session logs that end in a split | 1 |
| pull requests merged from card/ branches | 34 |
| pull requests merged from plan/ branches | 0 |
| pull requests merged from other branches | 6 |
| squash merges, branch not recorded | 0 |
| review passes recorded | 32 |
| tests in the suite | 561 |

How to read them:

- A pull request is counted from the subject of its merge commit, which names the branch. A squash merge has another subject, which ends with the number in parentheses and does not name the branch, so it is counted on its own line; a commit that ends with the number of an issue in that form is counted there too. A rebase merge leaves nothing to count.
- Fewer pull requests than cards: 22 card branches, most of them of 0.1, were merged with the subject "Merge card/..." and no pull request. They are in the history and in no line of the table.
- No pull request has merged from a plan branch. The planner's outlines have been written in hand runs and in the spike, and none has landed in this repository.
- A review pass is a second-level heading in a review record. Passes differ a great deal in size.
- The count of tests is of test functions. It says nothing of what they assert.

These figures say how much was done and recorded. They do not say that it worked: for that, [`evidence.md`](evidence.md) has what was measured, on how many sessions, and what has not been measured.
