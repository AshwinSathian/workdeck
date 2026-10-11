# WorkDeck 0.3 design

This is the design for release 0.3. It adds to [`design.md`](design.md), the design of 0.1, and to [`design-0.2.md`](design-0.2.md), the design of 0.2; where this file is silent, those two hold. Section 20 lists every sentence of theirs that this one makes false. The scope it follows is [`development/scope-0.3.md`](development/scope-0.3.md).

Date: 2026-10-11
Status: draft, written on 2026-10-11 by the session of card T-01b. Not reviewed and not approved. Section 22 lists what the writer could not settle and where it left the scope note.
Scope: release 0.3 (a claim at the start of a card, a card run in a worktree, parallel sessions).

## 1. What 0.3 adds

0.1 and 0.2 are built for one person running one session at a time. A card is `active` once its branch exists, but the branch is seen by nobody else until handoff pushes it, and next-card needs the base branch checked out in the one working tree.

0.3 adds one command, `card claim <id>`. It cuts the card's branch from the remote base branch, makes one empty commit on it and pushes it. It works the same in the main working tree and in a linked worktree, and it is the only way a skill starts a card. Two sessions that claim one card get one winner: on one clone because a branch can be created once, between clones because the second push is rejected.

Around that command: `card list` and `card next` say since when a claimed card is held and where its branch is; handoff reports whether the branch would conflict with the base branch; and every step that compared against the local base branch reads the base ref that `card` uses.

## 2. Goals and non-goals

Goals for 0.3:

1. Two sessions that start at the same moment, in two worktrees of one clone or in two clones, do not hold the same card or the same row.
2. next-card, quick, handoff and the reviewer work in a linked worktree, where the base branch cannot be checked out and the local one may be behind.
3. What decides a race is a script, not a sequence of instructions in a skill, so a shell test can run the race (goal 4 of 0.1).
4. A repository that makes no claim sees no change: the same output from `card list`, `card next` and `card status`, byte for byte, and a CI workflow pinned to `card` 0.1.3 or 0.2.0 keeps passing.
5. A conflict between two cards run in parallel is known at handoff, before a person finds it in the pull request.

Not in 0.3: everything under "Out of 0.3" in the scope note. This design adds nothing to that list and takes nothing from it.

## 3. Decisions already made

The first six rows are the six decisions of the scope note, in its order. The rest are this design's.

| Decision | Choice | Reason |
|---|---|---|
| 1. The claim | A push at the start, for every repository with a remote, to `origin` only. No configuration key | `card` 0.1.3 exits 2 on a key it does not know. |
| 2. The commit that decides a race | One empty commit `<id>: started` for every card, made by `card`, with a line no other session has. For a row: `card plan start`, the claim, then the card | Two identical commits are one hash, and the second push of one hash is accepted. |
| 3. A claim that cannot be pushed | The remote is asked for a branch of the id. One there: the race is lost. None, or no answer: warn and go on | A rejected push and a refused branch both exit 1. |
| 4. Two people planning at once | Out | Nothing to claim at the start of a plan run. |
| 5. A warning when two cards list one file | Out. A conflict report at handoff in its place | The warning would fire at nine starts in ten. |
| 6. A script that orders such cards | Out, and dropped | It would make the deck one chain. |
| Who runs the claim | `card claim` does all of it: the fetch, the lookup, the branch, the commit, the push and the question to the remote | A skill would need five commands and three branches of prose, none of which a test can run. `git ls-remote` is not among the permission entries, and `card` is. |
| Where a branch is cut from | The base ref: `origin/<base>` when it exists, otherwise the local base branch. In every working tree, the main one included | One path to test and to run by hand. The local base branch is no longer checked out or pulled by a skill. |
| How a skill gets a fresh tree | `git checkout --detach <base ref>` before a row's card or a quick card is written | A linked worktree cannot check out the base branch (section 19, row 9). A detached HEAD needs no branch. |
| Since when, and where | Printed only for a card whose branch has a claim commit | A branch made by 0.2, or by hand, prints what it prints today (goal 4). |
| Unfinished commands on the main branch | `card claim` refuses to run until the card that changes next-card removes one line (section 21) | A new install takes the main branch as it is. |

## 4. Repository layout

Nothing is added to the plugin's layout or to a project's.

Changed:

- `bin/card`: the commands `claim`, `base-ref` and `conflicts`; since when and where in `list` and `next`.
- `skills/next-card/SKILL.md`, `skills/quick/SKILL.md`, `skills/handoff/SKILL.md`, `skills/init/SKILL.md` and `reference/implement.md` (section 10).
- `templates/claude-md-section.md`: one line, that a card is started with `card claim` and that a claim is released by deleting its branch.
- `README.md`, `docs/reference.md`, `docs/evidence.md`, `CHANGELOG.md`, `.claude-plugin/plugin.json`.

Not changed: the hooks (section 13), `agents/reviewer.md` and `agents/plan-reviewer.md` (section 12), `skills/plan/SKILL.md`, `templates/settings-permissions.json` and `templates/workdeck.yml`.

## 5. The claim

### 5.1 The branch

A card's branch is `card/` followed by its file name without `.md`, as in 0.1. `card claim` takes the name from the file and no skill computes it. A quick card is the exception: its branch is `card/<id>` alone, with no slug. Two quick cards made in the same minute have the same id, so they have the same branch, and the second is refused. With a slug both were accepted (the third review of the scope).

The card file is looked for in the working tree, and then on the base ref, so a card with a file is claimed from a tree that is behind.

### 5.2 The claim commit

The commit is empty. Its subject is `<id>: started`. Its body is one line, `Claim: ` and 40 hexadecimal digits: what `git hash-object --stdin` prints for the time in seconds, the process id, two values of `$RANDOM`, the host name, the absolute path of the git directory and `$WORKDECK_SESSION`. None of those is printed; only the hash is in the commit. Its purpose is that two sessions never make the same commit: one person, one identity, one second and one parent gave one hash without it.

The commit is the first on the branch. For a row it comes before the approval commit `<id>: card as approved`, which stays what it is in 0.2.

What already holds for an empty commit, from the reviews of the scope: the stop hook does not count it, `card touched` passes on it, and handoff's search for the approval commit does not match it.

### 5.3 What `card claim <id>` does

In order. Any step that fails ends the command; what it prints is in section 9.

1. Check the id. With a remote, run `git fetch --prune origin` with prompts disabled. If the fetch fails, warn on stderr and go on with the refs as they are.
2. Compute the card's state as `card list` does. `done`, `review` and `waiting` are refused. `ready` goes on. `active` and `blocked` have a branch: go to step 3.
3. Look up the branches of the id, local and remote, with the exact match `card` already uses: the id, then `-` or the end. `card/AUTH-1` does not match `card/AUTH-12-x`. If there is one, the card is held, and the command says where and exits 1 (section 6).
4. Refuse if the local base branch has a commit that `origin/<base>` lacks. Such a card may depend on a merge that is not on the remote, and the branch is cut from the remote. The message says to push those commits or to land them through a pull request, as next-card's step 4 says today.
5. Refuse a card with no file: a row, for which `card plan start <id>` has to run first.
6. Run `git checkout --no-track -b <branch> <base ref>`. Git refuses when the branch exists, which is the claim on one clone, and when a file in the tree would be overwritten. `--no-track` is needed: without it the new branch's upstream was `origin/main` (section 19, row 10).
7. Make the claim commit.
8. With no remote, the card is claimed. Otherwise run `git push -u origin <branch>`, with prompts disabled.
9. If the push fails, run `git ls-remote --exit-code origin refs/heads/card/<id> 'refs/heads/card/<id>-*'`. Exit 0: someone holds the card, and the race is lost. Exit 2, or any other: the claim stands unpushed, and a warning says so.
10. If the main working tree has a `.claude/worktrees` directory that git does not ignore, say so in one line on stderr, with the line for `.gitignore`.

The tree is not required to be clean. Git decides in step 6, and the skills check the tree before, as they do now. An untracked card file is carried onto the new branch (section 19, row 11).

### 5.4 A lost race

On one clone the loser's `git checkout -b` fails, or step 3 finds the branch first. Nothing is left behind.

Between clones the loser has a local branch with a claim commit that was never pushed. `card claim` prints `lost <branch>`, and under it the two commands that remove it: `git checkout --detach <base ref>` and `git branch -D <branch>`. The permission entries deny a session the second, so the user runs it. The skill stops, and does not pull.

### 5.5 Releasing a claim

A claim is released by deleting its branch: here with `git branch -D`, on the remote with `git push origin --delete`, and in any clone that lost a race for it. A session can run none of the three. next-card prints them when the user says no to a row's card, and when a row cannot be done as cut; until they are run the card is `active` for everyone.

### 5.6 What a claim does not cover

- Two branches of one id with different names are both accepted by the remote. A card file renamed between two fetches gives this. Step 3 looks after the fetch, which leaves the seconds between the fetch and the push (risk 5 of the scope).
- Offline, or where the host refuses the branch, two people can hold one card. They meet at handoff's push, which is rejected. Handoff then stops and says not to pull: a pull would merge two cards' work.
- A quick card is claimed after the user's yes (section 10.3), so it is invisible until then.

## 6. State, since when and where

The state table of design.md, section 6, is unchanged. A claim makes a card `active` earlier and for everyone; it adds no state.

For a card that is `active` or `blocked` and whose branch has a claim commit, `card list` and `card next` print a mark after the title, as they print `[row]`:

```
active   AUTH-03      M   Token refresh [since 2026-10-11, in another worktree]
```

- **Since** is the committer date of the earliest commit on the branch, and not on a base ref, whose subject is `<id>: started`, as `git log --format=%cs` prints it. A date in that form is the only text that comes from the commit.
- **Where** is one of three. `here`: a local branch of this clone that no other worktree has checked out. `in another worktree`: a local branch that `git worktree list --porcelain` shows in a worktree other than the current one. `on the remote`: no local branch.

No name, no email, no path and no branch name is printed. A branch with no claim commit gets no mark. `card status` is unchanged: it is what the session-start hook prints, and the mark costs one `git log` per card in progress.

`card claim` on a held card prints one line and exits 1:

| Line | When | What next-card does |
|---|---|---|
| `held here <branch>` | a local branch, in no other worktree | asks whether to resume, then checks the branch out |
| `held worktree` | a local branch that another worktree has checked out | stops |
| `held mine <branch>` | only on the remote, and the author email of its claim commit is this clone's `user.email` | asks whether to resume, then `git checkout <branch>`, which makes the local branch (section 19, row 12) |
| `held remote` | only on the remote, otherwise | stops |

A branch name is printed only when it is `card/`, the id, and then nothing or `-` and lowercase letters, digits and hyphens. A name of another form is printed as `held remote` or `held worktree`, without the name. The email is compared and never printed. A branch with no claim commit, made by 0.2, is `held here` when local and `held remote` otherwise: without the commit nothing says whose it is.

## 7. Worktrees and the base ref

The base ref is `origin/<base>` when that ref exists and the local base branch otherwise. It is what `card` has read state from since 0.1 (`base_ref`). `card base-ref` prints it, and the skills use it wherever they named the base branch in a git command:

- the fresh tree at a start: `git checkout --detach <base ref>`;
- the reviewer's prompt, so that its `git merge-base HEAD <base>` is taken against the remote base branch (the second review of the scope found the local one gave another card's files in a worktree);
- handoff's `git log ... <base ref>..HEAD`.

`gh pr create --base` keeps the branch's name.

A skill no longer checks out the base branch or pulls it. The local base branch stays where the user left it, and may fall behind; `card` reads both refs, and done on either counts, as before.

Supported: a session started with `claude --worktree`, and one started in a worktree made with `git worktree add`. In the second the session's first directory is the worktree, and a hook that asks git for the top level got the worktree (the second review of the scope). For the first that is expected and was not run (section 19, row 6); the hand run of section 21, item 7, comes before any skill is changed for it. Not supported: a worktree entered in the middle of a session. There `${CLAUDE_PROJECT_DIR}` stays at the first directory and only the `cwd` field of the hook input moves (section 19, row 3); the hooks read neither.

A worktree that Claude Code makes starts on a branch `worktree-<name>` (row 1). `card claim` leaves that branch and nothing uses it again. When the session ends Claude Code may remove the worktree "and its branch" (row 4). Which branch that is after `card claim` has switched to `card/*` is not known (row 5). If it is the card's, the local branch is gone and the claim is on the remote alone, which is what `held mine` is for.

`.claude/worktrees/` has to be ignored (row 2). Init offers the line for `.gitignore`, and `card claim` says where it is missing (section 5.3, step 10).

## 8. Configuration and compatibility

No key is added to `workdeck.conf`, no front matter key to a card, and no file to the cards or log directory. `version` stays 1.

| Situation | What happens |
|---|---|
| A 0.2 repository, plugin updated to 0.3 | A start now runs `card claim`. With a remote it pushes at the start of a card, which `git push -u origin card/*` already allowed a session to do. `card list` shows a mark on a claimed card |
| A repository with no remote | The claim is the branch and the empty commit. No push, no question |
| CI pinned to `card` 0.1.3 or 0.2.0 | `card lint` passes: no format changed |
| CI or a preview that runs on a push to any branch | It runs at the start of each card, on a branch that holds an empty commit |
| Pull requests that land as merge commits | The claim commit is in the base branch's history |
| A branch made by 0.2, with no claim commit | `active` as before, with no mark. `card claim` reports it as held |
| A 0.3 skill with a 0.2 `card` first on the PATH | `card claim` prints `unknown command 'claim'` and exits 2. next-card stops and says to update `card` |
| Git older than 2.38 | `card conflicts` says it cannot tell, and handoff goes on (section 11) |
| A local base branch with unpushed commits | `card claim` refuses, as next-card's pull refuses today |

## 9. The `card` command

| Command | Behavior |
|---|---|
| `card claim <id>` | Section 5.3. Stdout is one line: `claimed <branch>` (exit 0); `held ...` (exit 1, section 6); `lost <branch>` and the two commands of section 5.4 (exit 1). A refusal is a `card:` message on stderr with exit 1; a card with no file names `card plan start`. A claim that could not be pushed is `claimed <branch>` with a warning on stderr and exit 0 |
| `card base-ref` | Prints the base ref in its short form, `origin/main` or `main`. Exit 2 when there is no base branch |
| `card conflicts` | Section 11. Exit 0 and `no conflict with <base ref>`; exit 1 and one file per line; exit 2 when it cannot tell |
| `card list`, `card next` | The mark of section 6. Unchanged for a card with no claim commit |

`card claim` and `card conflicts` fetch. Until now `--fetch` was the only network access in `card`. Neither is run by a hook.

Exit codes and message conventions are those of 0.1.

## 10. Skills

### 10.1 `/workdeck:next-card [id]`

Steps 1 to 3 are unchanged. Steps 4, 5 and 7 change, and step 6 changes its order.

4. **Base ref.** Run `card base-ref`. The base branch is not checked out and not pulled.
5. **Pick the card** and read its state from `card list`, as now. `waiting` and `review` stop, as now. For `active` and `blocked`, and for `ready`, the answer comes from `card claim` in step 6; the skill no longer runs `git branch --list`.
6. **Claim.**
   - A card with a file: run `card claim <id>`.
   - A row: run `git checkout --detach <base ref>`, so that the outline and the code are those of the base branch, then `card plan start <id>`, then `card claim <id>`. If the claim does not print `claimed`, delete the card file that `card plan start` wrote.
   - `claimed`: go on. `held here` and `held mine`: ask the user whether to resume, check the branch out, and go on. `held worktree`, `held remote` and `lost`: say what the line means, print the commands of a `lost` line, and stop.
7. **Read the card,** as step 6 does now. For a row, sub-steps 2 to 6 follow on the card's branch. A no to the card, and a row that cannot be done as cut, delete the card file and print the three commands of section 5.5: the branch exists and the card is held until they are run. The approval commit is made after the yes, as now, on the branch that already exists.

Steps 8 and 9 are unchanged.

### 10.2 `/workdeck:handoff`

- `<base ref>` is the output of `card base-ref`. Step 3 gives it to the reviewer as the base branch. Step 7's search for the approval commit uses `<base ref>..HEAD`.
- Step 7, straight after the commit: run `card conflicts`. The pull request body gains a line, `Conflicts with <base> at handoff:` and `none`, the files, or `not checked` with the reason. It is a report and not a gate: handoff goes on, and tells the user in step 8 what to do about a conflict, which is theirs to resolve after the other card merges.
- Step 7, a push that is rejected: stop, and tell the user not to pull. Someone else holds a branch of that name (section 5.6).

### 10.3 `/workdeck:quick`

Step 2 becomes `card base-ref` and `git checkout --detach <base ref>`. Step 6 becomes `card claim <id>`, after the user's yes, so a no still leaves nothing behind. On `held` or `lost` the id is taken by another quick card made in the same minute: delete the card file, print the commands of a `lost` line, say so and stop, as every session whose claim is refused does. The user types the skill again.

### 10.4 `/workdeck:init`

One more step for both kinds of repository, asked like the others: if `.claude/worktrees/` is not ignored, offer the line for `.gitignore`.

### 10.5 `reference/implement.md`

Step 6 says that the claim commit is already on the branch, and for a planned card the approval commit after it, and that nothing else is committed before handoff.

## 11. Mechanical checks

`card conflicts` is the one new check. It fetches the base branch from `origin` where there is a remote, then runs `git merge-tree --write-tree --name-only --no-messages <base ref> HEAD` and prints the files that conflict. It reads commits, so it runs after handoff's commit. It writes nothing to the working tree, the index or a ref (section 19, row 13).

It cannot tell, and exits 2 with one line, when git is older than 2.38, when HEAD is detached, and when the branch shares no history with the base ref. A fetch that fails is a warning, and the answer is for the ref as it is.

It is not a gate. Parallel cards will conflict (risk 6 of the scope: 25 of 39 pairs in this repository's history), and the branch that is handed off first is not the one that has to change.

Known limits:

- The answer is true when it runs. A card that merges a minute later changes it.
- It compares with the base branch and not with other open branches, so of two cards open at once the second to merge is the one that learns of the conflict, and only if it is handed off after the first merged.

## 12. Agents

No agent file changes. The reviewer receives the base ref where it received the base branch's name, and its `git merge-base HEAD <base>` and `git diff` run as written; `git merge-base *` is among the permission entries. The plan reviewer is not run in a worktree: the plan skill is out of 0.3 there.

## 13. Hooks

No hook changes.

- **Stop.** An empty commit is not counted, so a claim does not trip the log guard. It reads both base refs already.
- **Post-tool-use.** It reads `.git` as a file in a linked worktree and keeps its marker in that worktree's git directory.
- **Session-start.** It prints `card status`, which is unchanged.
- **Pre-compact.** Its marker is per worktree.

The second review of the scope ran the stop and post-tool-use hooks in a worktree made with `git worktree add`. In a session that Claude Code started with `--worktree`, none was run (section 19, row 6).

## 14. Hand runs, the record and release

Before the release, each in `docs/evidence.md`:

1. Two clones start one card within seconds. One prints `claimed`, the other `lost`.
2. Two sessions in two worktrees of one clone start one card, and then one row.
3. A card and a quick card through next-card and handoff in a worktree made by `claude --worktree`, with the local base branch behind. This run settles rows 5 and 6 of section 19: what the hooks print there, and which branch is gone after the session ends.
4. On GitHub: a pull request from a branch whose first commit is empty, merged by squash and by rebase, and a claim on a repository that protects `card/*`.

Then the maintainer runs a deck in parallel. Nothing new is stored. The evidence page records, per card, whether `card claim` printed `held` or `lost` for a card that `card next` had offered, and per pair of cards open at the same time, the `Conflicts with` line of the second one's pull request and whether its merge conflicted, with the files.

The version in `plugin.json` changes last, as in 0.2 (design-0.2, section 21, item 11).

## 15. Errors

| Situation | Behavior |
|---|---|
| `card claim` for a card that is done, in review or waiting | Exit 1 with the state, and for `waiting` the dependency |
| `card claim` for a row with no card file | Exit 1; the message names `card plan start <id>` |
| `card claim` for an id with no card and no row | Exit 1 with the ids of the same prefix, as `card show` |
| The fetch fails | A warning. The claim goes on with the refs as they are |
| The branch exists, here or on the remote | `held ...`, exit 1 |
| A file in the tree would be overwritten by the checkout | Git's message, exit 1. No branch is made |
| The local base branch has commits the remote lacks | Exit 1, before any branch is made |
| The push fails and the remote has a branch of the id | `lost <branch>` and the two commands, exit 1 |
| The push fails and the remote has none, or cannot be asked | `claimed <branch>`, a warning, exit 0 |
| The commit fails (no identity, a hook of the project) | Git's message, exit 1. The branch exists with no commit of its own; `card claim` names it and the command that deletes it |
| The user says no to a row's card | The card file is deleted. The branch is left, here and on the remote, and next-card prints the commands that delete it |
| A row cannot be done as cut | The same, and next-card names the plan skill |
| Handoff's push is rejected | Handoff stops and says not to pull |
| `card conflicts` with git older than 2.38, a detached HEAD or no shared history | One line, exit 2. Handoff writes `not checked` |
| `.claude/worktrees/` is not ignored | One line on stderr from `card claim`. Until it is ignored the stop hook does not block, `card touched` fails on the directory and `git add -A` stages it |

## 16. Trust and input handling

- A branch on the remote is named by whoever pushed it. `card claim` prints a branch name only in the form given in section 6, and `card list`, `card next` and `card status` still print none. The rule of `cards/REVIEW.md` on text that reaches an agent's context names `card status` and hook output, and says "no branch name other than the current one". Those two are unchanged, but a `held` line is such a name in a session's context, so the rule is either amended for it or read as not covering it (section 22, point 8).
- From a claim commit `card` takes a date, in the form git prints, and compares an email. A commit's author is whatever its maker wrote. Someone who can push to the repository can make a branch that another user's session offers to resume as `held mine`. What that session then reads is a teammate's branch, which a pull request shows it anyway; the user is asked before the checkout.
- The id is checked before it reaches a branch name, a ref pattern or a commit message. The push names one branch and has no refspec with a colon, no `--force` and no `--delete`.
- `card claim` creates a branch, commits and pushes with no prompt, if a rule that allows `card` covers the git commands it runs (section 19, row 21, unverified). A session's own `git checkout -b` is not among the permission entries. What it can push is a new branch `card/<id>...` that holds one empty commit.
- The line of the claim commit is a hash. The host name and the path that go into it cannot be read from it.

## 17. Testing

- Shell tests as before, with a local bare repository as the remote. `card claim`: each line of section 9 and each row of section 15; two clones that claim one card, where exactly one prints `claimed`; two worktrees of one clone; a quick card's branch; a branch name that is not printed; `held mine` by email. Two claims in one second by one identity give two commits.
- `card list` and `card next` with a mark in each of the three places, and with none for a branch that has no claim commit.
- `card conflicts`: none, one file, a detached HEAD, and a stub `git` that reports a version before 2.38.
- The byte-for-byte case of 0.2 (design-0.2, section 17) still passes: no test of 0.1 makes a claim.
- The skills cannot be unit tested. Shell tests check their mechanics as before: that every `card` command a skill names exists, and that next-card runs `card plan start` before `card claim`. The hand runs of section 14 are the rest.

## 18. Risks

| Risk | Response in 0.3 |
|---|---|
| A no to a row's card leaves a branch that holds the row for everyone | next-card prints the commands. `card list` shows since when it is held |
| An abandoned claim holds a card, now on the remote too | Since when is the whole response. A person deletes the branch |
| Parallel cards conflict, and 0.3 only reports it | `card conflicts` at handoff, and the record of each pair |
| The claim window: two names for one id, and the seconds between the fetch and the push | Not closed (section 5.6) |
| Claude Code deletes the card's branch when a worktree session ends | Not known. The third hand run. `held mine` recovers the claim |
| The hooks in a `claude --worktree` session | Run only in a worktree made with git. The third hand run |
| A skill no longer updates the local base branch, so it falls behind | `card` reads both refs. A user who works on the base branch by hand pulls it by hand |
| A detached HEAD after a start that stops early | The session says where the tree is. `git checkout <base>` returns to the branch |
| `card` now pushes | One fixed command, to `origin`, of a branch that holds an empty commit (section 16) |
| A push at every start runs CI where it is built on any push | In the README. No key turns the push off (decision 1) |
| The trial of 0.2 plans this design, and merges some of its cards before 0.2.0 is tagged | Section 21: `card claim` refuses to run until its last card |

## 19. Claude Code and git behavior this design relies on

Claude Code pages are under `https://code.claude.com/docs/en/` and were read on 2026-10-11, by the means [`development/review-0.3.md`](development/review-0.3.md) names. Git pages are the manual pages of git 2.54.0, and "run" means run that day with that version in a scratch repository with a bare remote. A row marked unverified was neither read nor run.

| # | Claim | Page | Status |
|---|---|---|---|
| 1 | `claude --worktree <name>` creates `.claude/worktrees/<name>/` at the repository root, on a new branch `worktree-<name>`, cut from the remote's default branch unless `worktree.baseRef` is `head` | `worktrees` ("Start Claude in a worktree") | read |
| 2 | The page says to add `.claude/worktrees/` to `.gitignore` | `worktrees` | read |
| 3 | After a worktree is entered in the middle of a session, `${CLAUDE_PROJECT_DIR}` stays where the session started and the `cwd` field of the hook input is the worktree root | `worktrees` ("Ask Claude to create a worktree") | read |
| 4 | When an interactive worktree session ends, Claude Code removes a clean worktree and its branch, at once for an unnamed session and after a question for a named one, and asks when the worktree has changed files or new commits | `worktrees` ("Clean up worktrees") | read |
| 5 | Which branch "its branch" is after the session has switched the worktree to another one | none | unverified. The third hand run of section 14 |
| 6 | In a session started with `--worktree`, a plugin hook's working directory is the worktree | none | unverified. The hooks were run in a worktree made with `git worktree add` only |
| 7 | Permission entries and project plugins are shared between a worktree and the main checkout | `worktrees` | read by the third reviewer of the scope, not again |
| 8 | Linked worktrees share the refs of the repository, and a branch that exists cannot be created again | `git-worktree`, `git-checkout` | run: `fatal: a branch named 'card/A-1-thing' already exists` |
| 9 | A linked worktree cannot check out a branch that another worktree has, and can detach at any commit | `git-worktree`, `git-checkout` | run: `'main' is already used by worktree`; `git checkout --detach origin/main` gave `HEAD (no branch)` |
| 10 | `git checkout -b <new> origin/<base>` sets the new branch's upstream to the base branch unless `--no-track` is given | `git-checkout`, `git-config` (`branch.autoSetupMerge`) | run both ways: without the option, `set up to track 'origin/main'`; with it, `no upstream configured` |
| 11 | An untracked file is carried over by `git checkout -b` when the new commit has no file at its path | `git-checkout` | run |
| 12 | `git checkout <name>`, where no local branch of that name exists and one remote has it, creates the local branch and tracks the remote one | `git-checkout` | run in a second clone |
| 13 | `git merge-tree --write-tree --name-only --no-messages <a> <b>` prints a tree and then the conflicted files, exits 1 on a conflict, and touches neither the working tree nor the index. It exists from git 2.38 | `git-merge-tree` | run: one file, exit 1, `git status` unchanged. With no shared history it printed `fatal: refusing to merge unrelated histories` and exited 128 (the handoff reviewer of T-01b), so any exit but 0 and 1 is "cannot tell". The version is from the scope's third review and was not read again |
| 14 | `git ls-remote --exit-code origin <patterns>` exits 0 when a ref matches, 2 when none does and 128 when the remote cannot be reached | `git-ls-remote` | run for 0 and 2. 128 is the third reviewer's run |
| 15 | A push of a commit that differs from the remote's is rejected with exit 1; of the same commit it prints "Everything up-to-date" and exits 0 | `git-push` | run by the reviewers of the scope, not again |
| 16 | `git worktree list --porcelain` prints one `worktree` line and one `branch` line for each worktree that is on a branch | `git-worktree` | run |
| 17 | `git log --format=%cs` prints the committer date as `YYYY-MM-DD` | `git-log` ("PRETTY FORMATS") | run |
| 18 | `git hash-object --stdin` prints 40 hexadecimal digits for any input in a SHA-1 repository | `git-hash-object` | run. In a SHA-256 repository it prints 64, which the line holds as well |
| 19 | GitHub accepts a pull request from a branch whose first commit is empty, and merges it by squash and by rebase | none | unverified. The fourth hand run |
| 20 | A user who has the plugin receives what the main branch holds when `version` changes; a new install takes the branch as it is | `plugins/host-marketplace` ("Release a new version"), `plugins/loading` ("Versions and updates") | read on 2026-10-09 for design-0.2 (section 19, row 18, and section 18, last row), not again |
| 21 | A Bash rule matches the command as written, so a session that may run `card *` is not asked again for the `git checkout -b`, `git commit` and `git push` that `card claim` runs inside it | `permissions` | unverified for this design. Design-0.2, section 19, row 12, read the page for the matching of a command as written. Nobody ran a `card` that pushes under the permission entries; item 7 of section 21 does |

## 20. What this design amends

Sentences of the two earlier designs, and of the shipped skills, that 0.3 makes false. The earlier design files are not edited; the skills and the reference are changed by their cards.

| Where | Says | In 0.3 |
|---|---|---|
| design.md, section 2, goal 5 | Card and log files never produce merge conflicts | They did, three times each for two cards (the third review of the scope, in `development/review-0.3.md`). Not fixed in 0.3; `card conflicts` reports it |
| design.md, section 3, "In-progress state" | No commit is needed to claim a card | One empty commit is. State is still derived from branches and not stored |
| design.md, section 6 | Deleting the branch releases the card | Up to three deletes (section 5.5) |
| design.md, section 6 | `card` makes no network call unless given `--fetch` | `card claim` and `card conflicts` fetch |
| design.md, sections 10.2 and 10.4 | A fast-forward pull of the base branch; the branch is created by the skill | Sections 10.1 and 10.3 |
| design.md, section 10.2, step 5 | A card whose branch is local was started here | Section 6: `held here`, `held worktree` |
| design.md, section 15 | With no network, state uses local branches | Still true, and a claim that cannot be pushed stands with a warning |
| design-0.2, sections 10.2 and 15 | The card is written on the base branch; a no leaves no branch; "Nothing was committed and no branch exists" | The claim comes first. A no leaves a branch and a pushed empty commit |
| design-0.2, section 2 | A script that orders cards touching the same file is left to 0.3 | Dropped (decision 6) |
| next-card, its description and step 4 | "Updates the base branch"; the base branch is checked out and pulled | `card base-ref`; nothing is checked out or pulled. A linked worktree refuses the checkout |
| next-card, step 5 | `git branch --list "card/<id>*"` decides whether a card was started here | `card claim` decides, with an exact match |
| next-card, steps 6 and 7 | A row's card is written "on the base branch"; `git checkout -b <branch>` | On the card's branch, after the claim; `card claim` makes the branch |
| quick, steps 2 and 6 | The base branch is checked out and pulled; `git checkout -b <branch>`, named after the file | Detached at the base ref; `card claim`, and the branch is the id alone |
| handoff, steps 3 and 7 | `<base>` in the reviewer's prompt and in `<base>..HEAD` | `<base ref>` |
| next-card, step 6 | "nothing was committed and no branch exists"; "a no leaves nothing behind" | False for a row |
| quick, step 5 | "an untracked card left on the base branch" | The tree is detached at the base ref |
| `reference/implement.md`, step 6 | The approved card is the only commit before handoff | The claim commit is before it |

## 21. Build order

A new install takes the main branch as it is, and a user who has the plugin receives it when the version changes (section 19, row 20). So no card may leave a command on the main branch that does half its work, or a skill that names a command that is not there.

The rule: `card base-ref` and `card conflicts` are each whole in one card and change nothing for a user who does not type them. `card claim` is more than one card, and no skill uses it before item 8, so until item 8 it refuses to run: `card: claim is not released`, exit 2, unless `WORKDECK_UNRELEASED` is set in the environment, which the tests do. It is not in `card help` until then. The card that changes next-card removes the refusal. Each skill changes whole in one card.

1. `card base-ref`.
2. `card claim` on one clone: the lookup, the branch, the commit, the `held` lines. Refusing to run.
3. `card claim` with a remote: the fetch, the push, the question to the remote, `lost`. Still refusing.
4. The mark in `card list` and `card next`.
5. `card conflicts`.
6. Handoff and `reference/implement.md`: the base ref, the conflict line, the rejected push. Nothing here needs a claim.
7. The third hand run of section 14, as far as it can be made before next-card changes: the hooks and the branch in a `claude --worktree` session, with `card claim` run by hand. If Claude Code deletes the card's branch, this design is amended before item 8.
8. next-card, and the refusal removed.
9. Quick, init and the protocol line.
10. The README, the reference and the changelog.
11. The hand runs, the parallel deck and the evidence page.
12. The version, as the last commit before the tag.

Items 1 to 7 can merge before 0.2.0 is tagged: none adds a command a user can reach that is unfinished (design-0.2, section 22, decision 1). Items 8 and 9 are the reachable half of the claim, and wait for the tag or land together.

## 22. Open points

For the review, and for the maintainer. None was decided by the scope note.

1. **`card` pushes.** The scope says the session creates the branch, commits and pushes. Here `card claim` does all three. The six decisions do not say who pushes; decision 2 gives `card` the commit and decision 3 gives it the question to the remote. The scope's first item under "In 0.3" would be amended to name the command.
2. **A quick card is claimed after the yes,** not straight after its id is made. The scope says a claim is made "before any other work" and that the second quick card of a minute "is refused"; it does not say when. Claimed early, a no to a quick card would leave a branch.
3. **The local base branch is never updated by a skill.** The scope says the start "fetches and cuts the branch from the remote base branch" for a worktree. This design does it in the main working tree too, and leaves the tree detached where a start stops early.
4. **The mark is printed only for a claimed card.** The scope says `card list` and `card next` say "the date of its claim, and whether its branch is here": a branch with no claim has no date, and this design prints no place for it either, to keep the output of a repository with no claim unchanged.
5. **What may merge before 0.2.0 is tagged.** `WORKDECK_UNRELEASED` is one line in `bin/card`, removed by a card; the other way is to cut `card claim` as one card, which the planner may not do. Section 21 also lets `card base-ref`, `card conflicts` and the changed handoff merge before the tag, reading each as a feature that is complete by itself. Design-0.2, section 22, decision 1, says "unless the feature it belongs to is complete", and if the feature is 0.3 as a whole, none of items 1 to 7 may merge before the tag. The maintainer decides which reading holds.
6. **The differing line.** A hash of seven values. `/dev/urandom` would be shorter and is not POSIX.
7. **No minimum git version is stated** by 0.1 or 0.2. This design needs 2.38 for one report and degrades without it.
8. **A `held` line prints a branch name** other than the current one, and for `held mine` one that came from the remote. `cards/REVIEW.md` forbids that in text that reaches an agent's context, and names `card status` and hook output. Either the rule gains an exception for a name in the form of section 6, or the skill is given no name and `card claim` gains a way to check the branch out itself.
