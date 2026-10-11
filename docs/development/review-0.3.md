# Reviews of the 0.3 scope and design

"The scope" is [`scope-0.3.md`](scope-0.3.md). The design is not written yet; card T-01b writes it and adds its reviews here.

## First pass, 2026-10-11: the scope note and the split of T-01

T-01 was split at handoff after the first of its four outputs, the scope note, which was a draft that ended with six questions for the maintainer. Three agents that did not write it reviewed it: the handoff reviewer before pull request 40 was opened; a second, told to break the pull request and to attack the recommendation under each question, after; and a third, told to attack the fixes. All were general-purpose agents: the plugin was not loaded in the session, which followed the skill files by hand. The maintainer told the session to take the six decisions and every other one the pull request left open. So no decision below is the maintainer's. Merging the pull request is the approval of the note as decided.

Runs were made with git 2.54.0 in scratch repositories with a bare remote. Claude Code pages were read through Context7.

### The handoff review

Two must-fix findings, five should-fix and six nits. All were fixed before the pull request.

| Found | Decided |
|---|---|
| "0.2 serves the plugin to a new install from the main branch as it is" cited design-0.2 section 19, row 18, which is about a user who has the plugin already | Two citations: section 18, last row, for a new install, and section 19, row 18, for the rest |
| Two git claims had no run beside them: a linked worktree cannot check out the base branch, and worktrees share their refs | The run is under the risk on worktrees |
| The branch name `worktree-<name>` and the `.gitignore` line were marked unverified, and both are on the `worktrees` page | Cited |
| `?? .claude/` in the main working tree was given with no place, date or git version; a worktree outside the repository leaves the tree clean | The command, the date and the version are given |
| An empty commit `<id>: started` does not decide a race when both sides make the same one: one identity, one parent and one second give one hash, and the second push was accepted | In risk 1, and then in decision 2 |
| The script that orders cards touching the same file was put out with no question, though 0.2 left it to 0.3 | A sixth question |
| T-01's `Out of scope` forbade a change to a card of the 0.2 deck, and the split changes P-22's `depends` | The exception is written in the card |
| Six nits: "assume one person" overstated; decision 1 of design-0.2 section 22 quoted without "unless its feature is complete"; "0.1 reads one thing there" true only of another card's branch; `card status` prints the current branch; the index row did not say the note was a draft; T-01b named step 7 of next-card for a checkout that only step 4 makes | Each corrected |

### The second review

It read the note against `bin/card`, the hooks, the skills and the permission template, and ran what a run could decide. Four must-fix findings, thirteen should-fix and eight nits.

| Found | Decided | Why |
|---|---|---|
| The note named two first audiences: one person with worktrees on one clone, and "one person with two clones". On one clone the push decides nothing: the second `git checkout -b card/A-1-thing-1 origin/main` in a sibling worktree failed with "a branch named ... already exists" | One audience first, and the claim on one clone is the branch | |
| For a row the claim came after the card was written and approved (next-card writes it on the base branch, and the branch is step 7), so two sessions started together would both write the card of one row | The claim is made after the pick, before the card is written | Decision 2. A no to the card then leaves a branch, which is a risk in the note. |
| After the merge `card next` offers T-01b, and nothing holds the design until the note is approved | The note is decided in this pull request, and its merge is the approval | The other way was a `## Blocked` section on T-01b. |
| The delegation of the six decisions made five places false, the status line among them, and nothing recorded it | Recorded in the note's status, in this file, in both cards and the log. The body and the title of the pull request were written again after the push | |
| "From what git already records for the branch": a 0.2 card with a file has no commit of its own until handoff, so the tip's date is that of the last merge | The date is that of the claim commit | |
| Only the start was covered for a worktree. A worktree session cannot update the local base branch: with it behind, `git merge-base HEAD main`, as the reviewer agent runs it, gave the old commit and the diff listed another card's merged file, and `git log main..HEAD`, the form handoff uses, listed that card's commit. `card touched` was right | "In 0.3" names handoff and the reviewer, and every step that names the base | The plan skill and init are put out for a worktree. |
| A quick card in progress in another worktree is invisible: its file is untracked until handoff | Out, as a known limit | |
| An un-ignored `.claude/worktrees/` breaks more than next-card: the stop hook exits 0 where it should exit 2, `card touched` fails on the directory, and `git add -A` stages it as an embedded repository | Init offers the line and a start says where it is missing | A requirement, not a paragraph of documentation. |
| Claude Code facts missing: a new worktree is cut from the remote's default branch unless `worktree.baseRef` is `head`; after a worktree is entered in the middle of a session `${CLAUDE_PROJECT_DIR}` stays and the hook input's `cwd` moves, and the hooks read neither; there are three ways into a worktree and the note named one; on exit Claude Code may delete "the worktree directory and its branch" | The first is in risk 6. Two ways in are supported and the others are out. The last is in risk 6 as not checked | |
| The note did not say what the loser of a race does. The rejection prints git's hint to pull, the loser keeps a local branch the permission entries deny deleting, and next-card later offers to resume it | In "In 0.3" | |
| next-card's rule "a local branch is listed, the card was started here" is false on a shared clone: the branch was listed with `+` and its checkout failed | In "In 0.3" | |
| "Nothing was lost when that was the only answer" had no evidence, and two people planning was not under "Out" | Decision 4 gives the loss, and the item is under "Out" | |
| The warning as drafted fires on most starts: 236 of the 300 pairs of P cards share a literal `Touch` entry | Decision 5 | Recounted by the session: 236 of 300. The third review replaced the measure. |
| "Gains one push" understated: also a commit in the base branch's history where pull requests land as merge commits, and a workflow run where CI runs on a push to any branch | In "Compatibility" | Neither this repository's workflow nor the template runs on such a push. |
| T-01b forbade a change to a card of the 0.2 deck and told a split to change P-22 | The exception is in T-01b | |
| The test passed on a note of one byte, and on a row with any character for the dots | It holds the status line and six numbered decisions, and the row is matched as a fixed string | The third review found it still weak. |
| The claim is one branch name and state is read from the prefix: `card/X-6-one` and `card/X-6-two` were both pushed | Risk 5 | |
| Eight nits: the index said "how 0.2 was planned"; T-01's title still named the design and the review; "the stop hook leaves both out" had no run; session markers were listed as work and are already per worktree; printing a holder's name needs a rule of `cards/REVIEW.md` changed; "deleting the branch releases it, as now" is now up to three things to delete; "one page" at 1,628 words; "0.2.0" is not a tag yet | The first four and the last corrected. No name is printed, so the rule stands. What has to be deleted is in risk 2, after the third review. The note is as long as the 0.2 one, which is called one page | |

### The third review

It read the working tree after the fixes above, before they were pushed, and attacked the six decisions. Three must-fix findings, ten should-fix and eight nits. It let decisions 1, 4 and 6 stand and asked for 2, 3 and 5 to be amended; all three were.

| Found | Decided | Why |
|---|---|---|
| The body and the title of the pull request said the opposite of the tree: "Merging this does not approve the note", "as a draft", "Nobody reviewed the fixes" | Both written again with `gh pr edit` after the push | Handoff does not write a body twice. |
| Decision 3 could not be carried out: a lost race prints `! [rejected] (fetch first)` or `(non-fast-forward)` and exits 1, and a host that refuses the branch prints `! [remote rejected]` and exits 1; unreachable is `fatal:` and 128 | After a failed push the start asks the remote for any branch of the id | `git ls-remote --exit-code origin` with the two patterns of the id exited 0 when held, 2 when not and 128 when unreachable. It is not among the permission entries, so it belongs in `card`. |
| "The id of a quick card holds in the same minute" had no mechanism: `card/Q-2610111200-fix-a-typo` and `card/Q-2610111200-rename-a-flag` were both accepted | A quick card's branch is the id alone | With `card/Q-2610111201` the second push was rejected. |
| A row's branch name is not known before its card file exists: the slug is computed when the file is written, and two sessions that guess can differ | `card plan start`, then the claim, then the card | With the branch made first and the card untracked, `card plan start`, `card lint`, `card plan check`, `card show`, `card status`, `card touched` and the stop hook behaved. |
| Risk 2 understated a no: the row stays `active` for everyone until two deletes are run by hand, the clone that lost the race keeps it `active` on its own stale branch after that, a row that cannot be done as cut leaves the same branch, and two sentences of next-card become false | In risk 2 | |
| "Deleting the branch releases it" was singular, and the second review's nit on it had no decision | Risk 2 names the three; the clause is gone from "In 0.3" | |
| A user can be locked out of their own card: once the local branch is gone, a removed worktree or a new clone, next-card says the work is on someone else's branch | A claim only on the remote, with the user's own email on its commit, is offered for resuming | The email is compared and not printed. |
| Decision 5's number was the wrong measure: 236 of 300 counts pairs that a dependency orders. Of the 119 with no dependency between them 110 share an entry. And "the one part that reads card content from other branches" was false: `has_blocked` reads a card on another branch | The measure is replaced and the clause is gone | |
| With the warning out 0.3 had nothing for a problem that can be measured today: of 39 adjacent merges of cards with no dependency between them, 25 would have conflicted had both been cut from one commit (`git merge-tree`), 7 of them in a `touch_ignore` file that no `Touch` list names | A conflict report at handoff, read-only, and risk 6 | The record of a pair names the files, since `Touch` overlap would have missed those 7. Resolving stays out. |
| The note contradicted `docs/design.md` and did not say so: section 3 gives "no commit is needed to claim a card" as a reason, and goal 5 says card files never conflict, which the history disproves three times each for P-21 and P-23 | "Compatibility" says which row is amended; goal 5 is in risk 6 | |
| The changed test repeated its fault: it passed on a `review-0.3.md` of one byte, on decision 3 removed and 2 written twice, and on a status line that went on "still a draft"; it failed a true heading with a word added | It holds a heading of the review record and the numbers 1 to 6 in order, and less of the status line and of the heading | Still strings and not sense. |
| "CI on the pull request" was true of the first commit only | Said below | |
| T-01's `Acceptance` item on this file did not hold: no part for the third review | This part | |
| Eight nits: "the dots are escaped" when the test matches a fixed string; "four starts in five"; a repository with no remote gains more than the commit; a fetch that fails at a start in a worktree was not decided; next-card's `git branch --list "card/<id>*"` also lists a longer id; a worktree's path has the user's name in it; the status line read oddly after the merge; one page at 1,866 words against 1,815 | The first three and the seventh corrected. A failed fetch warns and uses the ref as it is. No path is printed. The lookup is a note in T-01b. The length stands | |

### The six decisions

| Question | Recommended in the draft | Decided |
|---|---|---|
| 1. Is the claim a push at the start, for every repository with a remote? | Yes, with no configuration key | Yes. `card` at v0.1.3 with `claim = off` printed `card: workdeck.conf:3: unknown key` and exited 2. To `origin` only |
| 2. Which commit decides the race? | An empty `<id>: started` for a card with a file, the approval commit for a row | Overturned for a row: one empty commit for every card, made by `card`, with a line that differs between sessions; for a row after `card plan start` and before the card is written. Identical empty commits gave one hash and the second push printed "Everything up-to-date"; with a differing line in the same second it was rejected. `--force-with-lease=<branch>:` added nothing, and the permission template denies `--force` and a `src:dst` refspec |
| 3. A push that fails: stop, or warn? | Warn | Amended twice: after a failed push the remote is asked for a branch of the id; stop if there is one, warn and go on otherwise. Two people offline with work met at handoff's push, rejected "(fetch first)" |
| 4. Two people planning at once | Out | Out, and not deferred again |
| 5. The same-file warning | In, as a warning that asks | Overturned: out. In its place a conflict report at handoff and the record of each pair |
| 6. The script that orders cards | Out | Out, and dropped |

### Other decisions taken

1. The note is decided and no longer a draft, and the merge of pull request 40 approves it. T-01b's first `Acceptance` item says so, and T-01b has no `## Blocked` section.
2. T-01's title is "Scope note for 0.3". Its file and branch keep their names: only the `card/<id>` prefix matters.
3. This file is created here and not in T-01b. T-01's `Touch` gains it, and in T-01b it is no longer `(new)`.
4. The plan skill and init are not made to work in a linked worktree in 0.3.
5. No name of a holder in what `card` prints. The rule of `cards/REVIEW.md` on text that reaches an agent's context is unchanged.
6. The measured fields of the session log are `unknown` and stay so: `card log-new` found no transcript.
7. `card` makes the claim commit and its differing line. The design names the command.
8. What the design has to settle from these reviews is in T-01b's `Notes`.

Nobody reviewed the fixes that followed the third review. The amended test ran under BSD awk only; CI passed on the first commit, 9efb624, on macOS and Ubuntu, and had not run on the amended tree when this was written. The counts 110 of 119 and 25 of 39 are the third reviewer's and were not recounted.

Held when run or read by the second reviewer: the push races of risk 1; the git and page claims of risk 6; that the stop hook leaves out the empty commit, and that both hooks work in a linked worktree with markers of its own; `card touched`'s fork point when the local base branch is behind; the cross-references to design-0.2 and scope-0.2; `card lint`, `card touched T-01` and `card tests T-01`; `shellcheck` on the test file; CI on the pull request, on macOS and Ubuntu; that T-01b carries every item of the first T-01, and that P-22 waits on T-01b before and after the merge.

Held by the third: `test/run.sh`, 560 passed; the gates and `shellcheck` again; the counts of findings in the two parts above against their rows; the citations; that the page says approvals and project plugins are shared with the main checkout, so the permission entries reach a worktree session; and that nothing 0.2 left to 0.3 is missing without a decision.

Not run by anyone: mawk or gawk on the amended test before the push; anything on GitHub with a claim branch (a pull request from a branch that holds only an empty commit, a rebase merge of one, branch protection on `card/*`); a real `claude --worktree` session; overlap among cards that were ready at the same time, as opposed to all pairs.
