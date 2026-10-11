# planned-deck: from a specification to cards

A tiny project in the middle of being built from a specification. The planner's parts can be read here without running an agent: the specification, the outline cut from it, a card written from a row and finished, a card that was split, and two rows that are still rows.

Copy the directory somewhere, run `git init -b main` and commit, and every command below gives the output shown. The branch has to be `main`, because `workdeck.conf` names it as the base. [`hello-deck`](../hello-deck/) comes first if you have not seen a card: it shows the loop and the gates without a planner.

**This example was written by hand, to show the format.** No plan run produced the outline and no session wrote the cards, so the two session logs say `unknown` for every measured field. Real runs are recorded in [`docs/evidence.md`](../../docs/evidence.md): hand runs of the planner in a scratch repository today, and the trial, which is still to come.

```
workdeck.conf                           check = sh test.sh, base = main
specs/notes.md                          the specification: six headings
cards/plan/note.md                      the outline: four rows, two headings not planned
cards/NOTE-01-store-a-note.md           a planned card, done
cards/NOTE-03-list-and-filter-notes.md  a planned card, done as far as it got: it was split
cards/NOTE-03b-filter-the-list-by-a-word.md   the remainder of the split, ready
log/2026-10-11-NOTE-01-1.md  log/2026-10-11-NOTE-03-1.md
src/notes.sh  tests/notes.sh  test.sh
```

NOTE-02 and NOTE-04 have no file. They are rows of the outline, and that is the point.

## The specification

[`specs/notes.md`](specs/notes.md) asks for a small shell library that keeps notes in a text file. It is written for people: it has an overview, four sections that each ask for something, and a list of non-goals. Nothing in it says how the work should be cut.

## The outline

[`cards/plan/note.md`](cards/plan/note.md) is what `/workdeck:plan specs/notes.md` leaves behind: one row for each card that will exist, and a list of the headings that ask for no card.

```
$ card plan
```

`card plan` prints nothing when every outline holds: each row has a size and a `does` line, each dependency is a row or a card, and every heading of the specification is cited by a row or listed under `Not planned`. Why each row is cut as it is:

- **NOTE-01 Store a note**, from `Storage`. It comes first because every other function reads the file it writes. Its `not` line says where printing went, so that nobody builds it here.
- **NOTE-02 Remove a note**, from `Removal`. It needs the file format and nothing else, so it depends on NOTE-01 only. It changes the same two files as the listing, so the two are not for sessions that run at the same time.
- **NOTE-03 List and filter notes**, from `Listing`. One heading, one row, size S: the heading asks for two behaviors and the planner guessed they fit one session. They did not, as the split below shows. A guess that is wrong costs a split, not a new plan.
- **NOTE-04 Export the notes as markdown**, from `Export`. The specification says it prints the same notes as the listing with a word, so it depends on NOTE-03. This is the dependency that matters in this example.
- **Not planned**: `Overview` and `Non-goals`. They ask for no work: the overview says why the library exists, and every requirement, the file's name among them, is under a heading that a row cites. A heading goes here only when it asks for nothing at all. They are listed so that `card plan` can tell a heading that was left out on purpose from one that was forgotten.

`spec_blob` in the outline's front matter is the hash of the specification when the outline was accepted. When the specification changes, `card plan` says that it differs, and `/workdeck:plan specs/notes.md` proposes the rows the change calls for.

## What `/workdeck:plan` did to produce it

In a real run, the session creates a branch `plan/<digits>`, reads the specification, has a subagent look at the code, and asks you to confirm the prefix and the heading level. It runs `card plan new specs/notes.md NOTE`, writes the rows, and runs `card plan` until it is silent. Then an agent that did not write the outline, the plan reviewer, attacks it. The session shows you the outline as a table with the findings it did not fix, and asks for a yes, an edit or a no. After a yes it commits the outline alone and opens a pull request that changes nothing else.

None of that is in these files. See "What this example cannot show" below.

## The deck

```
$ card list
done     NOTE-01      XS  Store a note
ready    NOTE-02      XS  Remove a note [row]
done     NOTE-03      S   List and filter notes
ready    NOTE-03b     XS  Filter the list by a word
waiting  NOTE-04      XS  Export the notes as markdown [row]

$ card next
NOTE-02 XS Remove a note [row]
```

`[row]` marks a card that has no file yet. Three things to notice:

- NOTE-02 is ready, because NOTE-01 is done.
- NOTE-03 is done and NOTE-04 depends on it, yet NOTE-04 is waiting. NOTE-03 was split, and its unfinished part is NOTE-03b. A row waits for the card it depends on **and for every remainder of that card**, so NOTE-04 cannot start on a filter that is not written.
- NOTE-03b is a card with a file, written in a session, and it follows the older rule: it depends on NOTE-03 and is ready.

## A row

```
$ card show NOTE-02
row: no card file yet
## NOTE-02 Remove a note
- size: XS
- depends: NOTE-01
- spec: Removal
- does: `note_remove <number>` deletes that line and leaves every other line as it was
- does: A number that no note has is refused with exit 1 and the file is not changed
```

A row says what will be true and names no file. It was written before NOTE-01 existed, when nobody could know which files the work would touch.

## What `/workdeck:next-card` does with a row

It writes the card, in the session that will do the work, against the code as it is now. The first step is a command, and you can run it:

```
$ card plan start NOTE-02
cards/NOTE-02-remove-a-note.md
```

The file has the row's title, size and dependency, one `Read` item, the `does` lines under `Acceptance`, and nothing under `Touch` and `Tests`. So it is not a card yet, and the checks say so:

```
$ card plan check NOTE-02
card: cards/NOTE-02-remove-a-note.md: Out of scope has no item

(exit 1)

$ card lint
card: cards/NOTE-02-remove-a-note.md: ## Touch has no items (an item is a line that starts with "- ")
card: cards/NOTE-02-remove-a-note.md: ## Tests has no items (an item is a line that starts with "- ")

(exit 1)
```

The session reads the specification's heading and the code, fills in `Touch` with real paths and `Tests` with the names the tests will have, and adds what is out of scope: this row has no `not` line, so it has to think of one. Then it runs both checks again, shows you the card, and waits. It writes no code before your yes. Delete `cards/NOTE-02-remove-a-note.md` to put the example back as it was.

## A planned card

[`cards/NOTE-01-store-a-note.md`](cards/NOTE-01-store-a-note.md) is what that step ends in. It is an ordinary card, with no key that a card of 0.1 lacks. Two things show where it came from:

- Its first `Read` item is `specs/notes.md (row NOTE-01: Storage)`, exactly as `card plan start` wrote it. The reviewer at handoff reads that heading and lists every requirement under it that the card neither covers nor excludes. So the session that wrote the card does not get to choose what it is checked against.
- Its `Acceptance` starts with the row's four `does` lines. The fifth, about `test.sh`, is the session's: the row names no test runner, and the check command needs one. A card may add to its row, and you approve the card, not the row.

`card plan check` holds only at the moment the card is written. Run it on a card that is done and it fails, as it should:

```
$ card plan check NOTE-01
card: cards/NOTE-01-store-a-note.md: Touch: src/notes.sh is marked (new) and exists
card: cards/NOTE-01-store-a-note.md: Touch: tests/notes.sh is marked (new) and exists
card: cards/NOTE-01-store-a-note.md: Touch: test.sh is marked (new) and exists

(exit 1)
```

That is why it runs once, before you are asked, and is not a gate at handoff or a step in CI.

## The approval commit

When you say yes to a card written from a row, next-card creates the branch and commits the card file alone, as `NOTE-01: card as approved`, before it writes any code. That commit is the card you approved. Nothing else is committed until handoff.

## What handoff adds to the pull request

For a planned card the pull request body gains a last part, "Changes to the card since it was approved": the diff of the card file from the approval commit to the handoff commit. A file added to `Touch` during the work, or a `Tests` line reworded to match the name the test got, shows there. "None" is a good answer.

## A card that was split

[`cards/NOTE-03-list-and-filter-notes.md`](cards/NOTE-03-list-and-filter-notes.md) kept two of its row's three `does` lines. The session ran into its budget warning before the filter was written, and you typed `/workdeck:handoff split`. Handoff created NOTE-03b with `card new`, moved the unfinished `Acceptance` and `Tests` items into it, and marked NOTE-03 done for what it did. [`log/2026-10-11-NOTE-03-1.md`](log/2026-10-11-NOTE-03-1.md) has the outcome `split`.

`card plan check` works on any card. No skill runs it for a card that already has a file, as a remainder does, so it is worth running by hand before the remainder is started. Here it prints nothing: every path the card names is there.

```
$ card plan check NOTE-03b
```

The outline was not edited. Once a row's card exists, the deck uses the card's fields and ignores the row's. The row stays as the record of what was planned, and `card plan` still checks it.

## What this example cannot show

- **The plan reviewer's findings**, and the question the plan skill asks you. They happen in a session and end up in the body of the plan's pull request.
- **The commits and the pull requests**: the plan branch, the approval commit, the diff of a card since it was approved. This directory sits inside another repository and has no branches of its own.
- **The states that need a branch.** `active`, `review` and `blocked` come from a `card/<id>` branch and its pull request, so every card here is `done`, `ready` or `waiting`. Nothing is faked to show the others.
- **Measured tokens.** The logs here say `unknown`.

For all four, the place to look is the trial's pull requests, linked from [`docs/evidence.md`](../../docs/evidence.md). They are to come: the trial has not been run. Until it has, the same page has [hand runs of the planner in a scratch repository](../../docs/evidence.md#hand-runs-of-the-planner-in-a-scratch-repository): the plan skill with its reviewer's findings, and next-card and handoff for two rows.
