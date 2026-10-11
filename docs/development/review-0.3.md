# Reviews of the 0.3 scope and design

"The scope" is [`scope-0.3.md`](scope-0.3.md) and "the design" is [`../design-0.3.md`](../design-0.3.md). The first pass is on the scope note, before the design was written. The second and third are on the design, and on the scope where the design left it.

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

## Second pass, 2026-10-11: the design, as a draft

Card T-01b wrote the design and was split at handoff after that first output, with the draft not approved and eight open points for the maintainer in its section 22. Pull request 41 was opened for the draft. The maintainer then told the session to have the pull request attacked by an agent that did not write it, to take the eight decisions and every other one, and to carry them out in the same pull request. So no decision below is the maintainer's, and merging the pull request is the approval of the design as decided. The split was undone: T-01b holds all three outputs again.

Two agents read the draft. Both were general-purpose agents: the plugin was not loaded in the session. Runs were made with git 2.54.0 in scratch repositories with a bare remote. Claude Code pages were read through Context7.

### The handoff review

Before the pull request. Four must-fix findings, seven should-fix and five nits.

| Found | Decided |
|---|---|
| The test's check of the section numbers never failed: awk's `exit` still runs `END`, so a design with a section renamed or removed passed | Rewritten, and six mutations of a copy of the design each fail it |
| The design named the tool the pages were read through, which `cards/REVIEW.md` allows only in three other places | The design points here for it |
| Quick went on with a new id after a refused claim, where the scope says a refused session stops, and section 22 did not list it | Quick stopped. The second review below overturned that with a reason, and the scope is amended |
| "A hook that asks git for the top level gets the worktree" was stated for `claude --worktree`, which nobody ran | Said for a worktree made with git only; the other is row 6, unverified |
| Two claims about Claude Code had no row: that a rule for `card` covers the push inside it, and that `git checkout -b` raised a prompt | Row 21, unverified. The second is now "is not among the permission entries" |
| `git merge-tree` with no shared history exits 128, which row 13 did not have | In row 13: any exit but 0 and 1 is "cannot tell" |
| A `held` line printed a branch name other than the current one, against a rule the design said it kept | An eighth open point; decided below |
| The build order put commands and a changed handoff on the main branch before 0.2.0 on the writer's reading of "complete" | In the fifth open point; decided below |
| Section 20 left out seven sentences of the skills | Added |
| The table check passed a row with no page marked read, and a status that only began with a right word | Tightened: a numbered row in order, a page, one of three words, and no page means unverified |
| The test did not hold the status line or that section 22 exists | It holds the status line |
| Five nits: row 20 cited another design as its page; "until the last of them" read as the wrong card; a figure cited to the scope that is in this file; two sentences elsewhere that say the design is not written; `git grep` does not see an untracked file | The first three corrected. The two sentences are corrected in this pass. The last stands |

### The second review

Told to assume the scope and the design are both wrong, to read the design against `bin/card`, the hooks, the skills, the permission template and the two earlier designs, to give a verdict on each open point, and to run what a run can decide. Four must-fix findings, twelve should-fix and eight nits, and eight verdicts.

| Open point | Verdict and evidence | Decided |
|---|---|---|
| 1. `card claim` pushes | Keep. Only a script can be raced in a test. But the skills' own `allowed-tools` allow `card`, so a user who declined the permission entries gets a push with no prompt | Kept, and said in sections 8, 16 and 18 |
| 2. A quick card is claimed after the yes | Keep the timing; change the loss. Stopping throws away a card the user approved, over an id that means nothing | A new id, and claim again |
| 3. Every start detaches at `origin/<base>` | Change. The draft detached only for a row or a quick card, so the pick read another branch's tree: on a branch holding a new card X-9, `card next` offered X-9, and the branch cut for it had no file | The third review settled it: next-card and quick detach before the pick |
| 4. The mark only for a claimed branch | Keep. A place printed for any active card would differ from 0.1.3 in every case `test/cases/70-compat.sh` compares | Kept |
| 5. What merges before 0.2.0 | Change. The handoff item is not complete alone: "do not pull" is wrong advice in 0.2.0 | Handoff waits with the other skills. The third review hid all four commands |
| 6. The line as a hash of seven values | Keep the hash, but its reason is wrong: `date +%s` and `hostname` are no more portable than `/dev/urandom` | 40 digits from `/dev/urandom` |
| 7. No minimum git version | Change. `%cs` is a second floor nobody listed | `--date=short`. 2.38 for the conflict report only, in the README |
| 8. A branch name in a `held` line | Change. The form has no length limit, hyphenated words read as instructions, and for `held mine` the name comes from the remote under an email anyone can write | No name is printed. `card claim --resume <id>` does the checkout |

| Found | Decided | Why |
|---|---|---|
| A project's commit-msg hook refused `<id>: started`: exit 1, and the branch left behind held the card `active` | The commit is made with `git commit-tree` | Ran under the same hook, and with `commit.gpgsign` set and no signing program: exit 0. The commit is unsigned, which the README says. |
| A row that was claimed and never approved, when resumed, had no card file: `card plan start` wrote one on the base and the checkout of the branch refused to overwrite it | After a resume, a card whose `card show` starts with `row:` gets `card plan start` on its branch | With the claim before `card plan start` there is one path for both. |
| Quick detached at a ref nobody had fetched: its state is read without `--fetch`, and the pull it lost was its fetch | `card base-ref --fetch` | |
| A card file tracked on the current branch and on no base ref passed, and the checkout dropped it | Refused | The remainder of a split, before it merges. |
| A slug kept three problems alive: two names for one id were both pushed, a row's name waited for its file, and nothing said how `card` knows a quick card | Every claim is `card/<id>` | `card_branches` and the stop hook already accept the bare name. This amends decision 2 in the order for a row. |
| The loser between clones kept a local branch that a session may not delete | The commit is pushed first, and the branch is made after | From two clones: exit 0 and exit 1 "(fetch first)", with no card branch in the second. |
| "As next-card's pull refuses today" was false: a local base branch that is only ahead starts a card in 0.2 | The start is the later of the two refs. Only two that have diverged are refused | `git pull --ff-only` printed "Already up to date" there. |
| "Do not pull" is wrong when the remote branch has a commit added to the user's own branch | Handoff says both cases and does not pull | Telling them apart by the claim commit was left out: a branch of 0.2 has none. |
| Since when moved with a rebase: the committer date | The author date | |
| Two commands in `card help` fail a test until `docs/reference.md` has them, and the reference was last in the order | The card that makes a command known adds its row | |
| No row for a team with both versions | A row in section 8 | |
| The `git branch -D` printed after a no fails: the tree is on that branch | A detach is printed first | |
| "After the title" does not fit `card next`, whose list has no title, and its two lines on releasing a card become incomplete | The exact line is given, and the two lines stay byte for byte, with a row in section 20 | |
| A race lost at the checkout has two messages, and one exits 128 | After a failed checkout the branches are looked up again | |
| A branch of 0.2 cut from a local base that was ahead got `origin/<base>` in the reviewer's prompt, so that base's commits read as the card's | `card fork-point`, the commit `card touched` measures from | |
| Eight nits: an email set in the environment never matched `user.email`; `review` cannot be computed without `gh`; the first command a 0.2 `card` rejects is not `claim`; "writes nothing to a ref" while it fetches, and a detached HEAD is no obstacle to `merge-tree`; the plan skill still pulls; "one line" against three; exit 2 for "cannot tell" against the rule of `cards/REVIEW.md`; the budget warning can now come while a card is written; section 20 lacked the reviewer's line | All corrected: `git var GIT_AUTHOR_IDENT`; `review` is left to the lookup; exit 1 with a `card:` line; an unknown command, not a new exit; the warning is in section 10.1 | |

## Third pass, 2026-10-11: the decisions

A third agent, told to assume each decision and each fix of the second pass is wrong. One must-fix finding, eight should-fix and seven nits, and a list of the sentences of the scope that the design as decided had made false. All were taken.

| Found | Decided | Why |
|---|---|---|
| "next-card needs no fresh tree: `card` reads the deck from the base refs" is false. An outline is read from the working tree's copy when there is one, so on the last card's branch a row added since was not offered: `card next` printed "no card is ready", and detached at `origin/main` it printed the row | next-card detaches at `card base-ref --fetch` before the pick, as quick does, and both return with `git checkout -` where they stop early | The second review's verdict on point 3, which the writer had cut down. |
| "What it can push is one empty commit" is false when the start is a local base branch that is ahead: the claim published its unpushed commit too | Said in sections 8, 16 and 18, and `card claim` gives the count | 0.2 publishes them at handoff. |
| The push runs the project's pre-push hook, which the choice of `commit-tree` was meant to avoid; one that fails left every claim unpushed with a warning | `git push --no-verify` | Not run with the option. |
| `git branch --set-upstream-to` failed in a clone made with `--depth 1`, after the push and the checkout had succeeded | The call is gone; handoff's `git push -u` sets the upstream. Section 5.6 says what such a clone does not see | |
| The branch was looked for before the card's state, so a merged card whose branch is still there printed `held here` | A done card is refused first | Every merged card has such a branch locally. |
| Three commands were in `card help` before 0.2.0 as parts of features that end later; "a whole command" is not the rule design-0.2 wrote | All four commands are unknown until the skill that uses them | Design-0.2's rule and risk 8 of the scope stand as written. |
| next-card's steps mixed two numberings, and its last step names a step that was gone | Eight steps, with the three sentences that name step 7 | |
| A no to a quick card left the main working tree detached, where 0.2 left it on the base branch | `git checkout -` | |
| The early hand run could not settle row 21: with the variable typed before it, the command is not one a rule for `card` matches | The variable is exported in the shell that starts `claude` | |
| Seven nits: no row for a machine with no git identity; a hand commit with the subject got the mark; `held worktree` for a worktree removed by hand gives no way out; "three rows unverified" against four; the passes named in section 22 did not exist; the template and the README write the branch with a slug; the reviewer's file says "a base branch" | A row in section 15; the mark needs the `Claim:` line; `git worktree prune`; four; these two passes; named in section 4; said in section 12, with the prompt in 10.2 | |

The scope was amended in fifteen sentences, each from the third agent's list: its status line, the items of "In 0.3" on the claim, since when, a worktree, parallel sessions, the losing side and the conflict report, "Compatibility", "How we know it works", risks 2 and 5, and decision 2. Risk 8 is unchanged.

### The eight decisions

| Point | In the draft | Decided |
|---|---|---|
| 1. Who pushes | `card claim` | Kept |
| 2. A quick card's claim | After the yes; a refused claim stops | After the yes; a refused claim takes a new id |
| 3. The base branch at a start | Every start detaches at `origin/<base>` | next-card and quick detach at the later of the two base refs, after a fetch |
| 4. The mark | Only for a branch with a claim commit | Kept |
| 5. What merges before 0.2.0 | A variable for `card claim`; items 1 to 7 | The variable hides all four commands; items 1 to 6 |
| 6. The line that differs | A hash of seven values | 40 digits from `/dev/urandom` |
| 7. Git versions | None stated | None for the claim; 2.38 for the conflict report |
| 8. A branch name in a `held` line | Printed in a fixed form | Not printed; `card claim --resume` |

Beyond the eight: every branch is `card/<id>`; the claim comes before `card plan start`; the commit is made with `git commit-tree` and pushed before the branch exists; handoff and the reviewer read `card fork-point`.

Nobody reviewed the fixes that followed the third pass. A pass by the writing session on its own fixes would be weaker evidence, and none was made.

Held when run by the second reviewer: `card plan start` on a detached HEAD in a linked worktree; `git fetch --prune origin` there; the stop hook on a detached HEAD, with only the claim commit, and after the approval commit; `card touched` with the claim commit; handoff's `--grep`, which matched only the approval commit; `card status`, unchanged; the cross-references of the design to the two earlier ones. By the third: `card show`, `list`, `status`, `plan start`, `plan check`, `lint` and `touched`, and the stop and post-tool-use hooks, on a branch `card/<id>` that holds only a claim, in the main tree and in a linked worktree; a checkout refused by an untracked file, which left no branch.

Not run by anyone: anything in Claude Code (a `claude --worktree` session, the permission rules against a `card` that pushes, the hooks inside a session); anything on GitHub; `git push --no-verify` with a commit and a ref; two claims at the same instant; a git older than 2.54; `/dev/urandom` through `od` on Linux; the suite of this repository in a linked worktree. Rows 5, 6, 19 and 21 of the design's section 19 are unverified.
