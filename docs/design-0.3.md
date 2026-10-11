# WorkDeck 0.3 design

This is the design for release 0.3. It adds to [`design.md`](design.md), the design of 0.1, and to [`design-0.2.md`](design-0.2.md), the design of 0.2; where this file is silent, those two hold. Section 20 lists every sentence of theirs that this one makes false. The scope it follows is [`development/scope-0.3.md`](development/scope-0.3.md).

Date: 2026-10-11
Status: decided on 2026-10-11 by the session that wrote it, and approved by the maintainer's merge of pull request 41. The draft ended with eight open points. The maintainer told the session to have the pull request attacked by agents that did not write it, to take every decision and to carry them out. Section 22 has the eight decisions and what else the reviews changed; the reviews are in [`development/review-0.3.md`](development/review-0.3.md). Four rows of section 19 are unverified: item 6 of section 21 is the run that settles three of them before any skill changes, and the fourth hand run of section 14 the other.
Scope: release 0.3 (a claim at the start of a card, a card run in a worktree, parallel sessions).

## 1. What 0.3 adds

0.1 and 0.2 are built for one person running one session at a time. A card is `active` once its branch exists, but the branch is seen by nobody else until handoff pushes it, and next-card needs the base branch checked out in the one working tree.

0.3 adds one command, `card claim <id>`. It makes one empty commit on top of the base branch, pushes it as the branch `card/<id>`, and only then creates that branch here and checks it out. It works the same in the main working tree and in a linked worktree, and it is the only way a skill starts a card. Two sessions that claim one card get one winner: between clones because the second push is rejected, on one clone because a branch can be created once.

Around that command: `card list` and `card next` say since when a claimed card is held and where its branch is; handoff reports whether the branch would conflict with the base branch; and the steps that compared against the local base branch read the commit where the card's branch left it.

## 2. Goals and non-goals

Goals for 0.3:

1. Two sessions that start at the same moment, in two worktrees of one clone or in two clones, do not hold the same card or the same row.
2. next-card, quick, handoff and the reviewer work in a linked worktree, where the base branch cannot be checked out and the local one may be behind.
3. What decides a race is a script, not a sequence of instructions in a skill, so a shell test can run the race (goal 4 of 0.1).
4. A repository that makes no claim sees no change: the same output from `card list`, `card next` and `card status`, byte for byte, and a CI workflow pinned to `card` 0.1.3 or 0.2.0 keeps passing.
5. A conflict between two cards run in parallel is known at handoff, before a person finds it in the pull request.
6. The session that loses a race is left with nothing to clean up.

Not in 0.3: everything under "Out of 0.3" in the scope note. This design adds nothing to that list and takes nothing from it.

## 3. Decisions already made

The first six rows are the six decisions of the scope note, in its order. The rest are this design's; those marked (n) are the decisions on the open points of the draft (section 22).

| Decision | Choice | Reason |
|---|---|---|
| 1. The claim | A push at the start, for every repository with a remote, to `origin` only. No configuration key | `card` 0.1.3 exits 2 on a key it does not know. |
| 2. The commit that decides a race | One empty commit `<id>: started` for every card, made by `card`, with a line no other session has. For a row the order is now the claim, `card plan start`, then the card: amended, see the row on the branch's name | Two identical commits are one hash, and the second push of one hash is accepted. |
| 3. A claim that cannot be pushed | The remote is asked for a branch of the id. One there: the race is lost. None, or no answer: warn and go on | A rejected push and a refused branch both exit 1. |
| 4. Two people planning at once | Out | Nothing to claim at the start of a plan run. |
| 5. A warning when two cards list one file | Out. A conflict report at handoff in its place | The warning would fire at nine starts in ten. |
| 6. A script that orders such cards | Out, and dropped | It would make the deck one chain. |
| Who runs the claim (1) | `card claim` does all of it: the fetch, the lookup, the commit, the push, the question to the remote and the branch | Only a script can be raced in a test. `git ls-remote` and `git checkout -b` are not among the permission entries, and `card` is. |
| The branch's name | `card/<id>` for every card that 0.3 claims, with no slug | With a slug, two names for one id were both accepted by the remote, a row's name was not known before its file was written, and a name from the remote had to be printed. With the id alone the remote refuses the second claim of an id whatever the file is called, the claim comes before `card plan start`, and no name is printed. State has read the prefix `card/<id>` since 0.1, so a branch with a slug is still seen. |
| How the commit is made | `git commit-tree`, not `git commit`, and it is pushed before any local branch exists | A project's commit hook that wants another subject refused `<id>: started`, and no card could start there. A loser that never made a local branch has none to delete (goal 6). |
| Where a branch is cut from (3) | The later of the two base refs: the local base branch when it contains `origin/<base>`, otherwise `origin/<base>` when that contains the local one. Refused when neither contains the other | A local base branch that is ahead starts a card in 0.2, and `card` already measures from the later of the two (`fork_point`). Refusing it would be new. |
| The tree at a start (3) | next-card and quick no longer check out or pull the base branch. After a fetch they run `git checkout --detach` at the start of the row above, and return with `git checkout -` when they stop before a claim | A linked worktree cannot check out the base branch. The tree has to be fresh before the pick: `card` reads an outline, and a card's front matter, from the working tree's copy when there is one, so on the last card's branch a row added since was not offered (the third pass of the review record). |
| Since when, and where (4) | Printed only for a card whose branch has a claim commit | A branch made by 0.2, or by hand, prints what it prints today (goal 4). |
| A quick card's claim (2) | After the user's yes. A refused claim takes a new id and claims again | The claim guards an id, not work. Claimed early, a no would leave a branch. |
| Unfinished commands on the main branch (5) | Each of the four new commands is an unknown command until the card that changes the skill which uses it (section 21) | A new install takes the main branch as it is, and design-0.2 lets nothing of an unfinished feature be reached before 0.2.0 is tagged. |
| The line that differs (6) | 40 hexadecimal digits read from `/dev/urandom` | One read. The draft's hash of seven values needed `date +%s` and `hostname`, which are no more portable. |
| Git versions (7) | No floor for the claim. The conflict report needs git 2.38 and says so where it cannot run | One report is not worth refusing a start. |
| Branch names in a session's context (8) | None is printed. `card claim --resume <id>` does the checkout | The rule of `cards/REVIEW.md` stays as written. |

## 4. Repository layout

Nothing is added to the plugin's layout or to a project's.

Changed:

- `bin/card`: the commands `claim`, `base-ref`, `fork-point` and `conflicts`; since when and where in `list` and `next`.
- `skills/next-card/SKILL.md`, `skills/quick/SKILL.md`, `skills/handoff/SKILL.md`, `skills/init/SKILL.md` and `reference/implement.md` (section 10).
- `templates/claude-md-section.md`: one line, that a card is started with `card claim` and that a claim is released by deleting its branch, and its line on the branch's name, which says `card/<id>-<slug>`.
- `README.md`, where the branch is also written with a slug, `docs/reference.md`, `docs/evidence.md`, `CHANGELOG.md`, `.claude-plugin/plugin.json`.

Not changed: the hooks (section 13), `agents/reviewer.md` and `agents/plan-reviewer.md` (section 12), `templates/settings-permissions.json` and `templates/workdeck.yml`, and `skills/plan/SKILL.md`, which still checks out and pulls the base branch and is run in the main working tree.

## 5. The claim

### 5.1 The branch

The branch of a card that 0.3 claims is `card/<id>`: a card with a file, a row and a quick card alike. `card claim` builds the name from the id, which it has checked, and no skill computes it.

A branch that 0.1 or 0.2 made is `card/<id>-<slug>`. It still counts: state is read from the prefix, with the exact match `card` already uses, the id and then `-` or the end, so `card/AUTH-1` does not match `card/AUTH-12-x`. The remote is asked for both forms (section 5.3, step 6).

### 5.2 The claim commit

The commit is empty: its tree is the tree of its parent, the commit the branch is cut from. Its subject is `<id>: started`. Its body is one line, `Claim: ` and 40 hexadecimal digits from `/dev/urandom`. Their only purpose is that two sessions never make the same commit: one person, one identity, one second and one parent gave one hash without them.

It is made with `git commit-tree`, which runs no hook of the project and does not sign. Where the project wants signed commits, the claim commit is unsigned, and the README says so.

The commit is the first on the branch. For a row the approval commit `<id>: card as approved` comes after it and stays what it is in 0.2.

What already holds for an empty commit, from the reviews: the stop hook does not count it, `card touched` passes on it, and handoff's search for the approval commit does not match it.

### 5.3 What `card claim <id>` does

In order. What it prints is in section 9.

1. Check the id. With a remote, run `git fetch --prune origin` with prompts disabled. If the fetch fails, warn on stderr and go on with the refs as they are.
2. Find the card. It is a card file on a base ref, a row, or a card file in the working tree that git does not track, which is a quick card. A card file that is tracked on the current branch and on no base ref belongs to that branch, as the remainder of a split does before it merges: refuse. A card that is done on a base ref is refused here, before its branch is looked for: the branch of a merged card is usually still there.
3. Look up the branches of the id, local and remote. If there is one, the card is held: say where (section 6) and exit 1. Otherwise a card that waits for a dependency is refused with the dependency.
4. Choose the start: the later of the two base refs (section 7). Refuse when neither contains the other. When the start is the local base branch and it has commits that `origin/<base>` lacks, say on stderr how many: the push of step 6 publishes them with the claim.
5. Make the claim commit on the start, with `git commit-tree`. No ref points at it yet. With no identity for git to use, this fails with git's message and nothing was pushed.
6. With a remote, run `git push --no-verify origin <commit>:refs/heads/card/<id>`, with prompts disabled. `--no-verify` skips the project's pre-push hook, for the reason the commit skips its commit hooks: a hook that runs the tests would run at every start, and one that fails would leave every claim unpushed. If the push fails, run `git ls-remote --exit-code origin refs/heads/card/<id> 'refs/heads/card/<id>-*'`. Exit 0: someone holds the card. Print `lost` and exit 1; nothing was created here. Any other exit: warn that the claim is not on the remote, and go on.
7. Run `git checkout --no-track -b card/<id> <commit>`. The branch has no upstream until handoff's `git push -u` sets it. If the checkout fails, look up the branches again: when another worktree made the branch in the meantime, print `held worktree`; otherwise print git's message. Either way exit 1.
8. If the main working tree has a `.claude/worktrees` directory that git does not ignore, say so in one line on stderr, with the line for `.gitignore`.

The tree is not required to be clean. Git decides in step 7 and refuses when a file would be overwritten; the skills check the tree before, as they do now. An untracked card file is carried onto the new branch.

With no remote there is no step 6, and step 7 decides the race.

### 5.4 A lost race

Between clones, the loser's push is rejected in step 6, before any branch exists in its clone. It prints `lost`, and there is nothing to delete.

On one clone with a remote, two worktrees push two different commits and one is rejected in the same way. With no remote, the second `git checkout -b` fails and step 7 prints `held worktree`.

The one thing a failed start can leave: step 6 succeeded and step 7 failed for a reason other than a race, a file in the tree that the checkout would overwrite. The claim is then on the remote with no branch here. `card claim --resume <id>` takes it up once the file is out of the way, and the message says so.

### 5.5 Releasing a claim

A claim is released by deleting its branch: on the remote with `git push origin --delete card/<id>`, and here with `git checkout --detach <base ref>` followed by `git branch -D card/<id>`. The first of the local two is needed because git does not delete the branch a worktree is on. A session can run neither delete, so next-card prints the three commands when the user says no to a row's card and when a row cannot be done as cut. Until they are run the card is `active` for everyone.

### 5.6 What a claim does not cover

- Offline, or where the host refuses the branch, two people can hold one card. They meet at handoff's push (section 10.2).
- A team where one person still runs 0.2: that person's start pushes nothing, and a 0.3 session can claim the same card. A team updates together (section 8).
- One person with two clones is offered `held mine` in the second for a card that is live in the first. The email says whose the claim is, not which clone's.
- A quick card is claimed after the user's yes, so it is invisible until then.
- A branch of 0.2 with a slug, pushed between this session's fetch and its push, is a second branch of the id. The claim's own name can no longer be doubled.
- A clone that fetches one branch only, as every clone made with `--depth` does, has no remote-tracking ref for a card's branch. It sees no claim of anyone else in `card list`, and learns of one only when its own push is rejected: `lost`.

## 6. State, since when and where

The state table of design.md, section 6, is unchanged. A claim makes a card `active` earlier and for everyone; it adds no state.

For a card that is `active` or `blocked` and whose branch has a claim commit, `card list` prints a mark after the title, as it prints `[row]`:

```
active   AUTH-03      M   Token refresh [since 2026-10-11, in another worktree]
```

`card next` prints the same mark after the state, in the list it gives when no card is ready: `  AUTH-03 active [since 2026-10-11, in another worktree]`. The two lines under that list, on deleting a branch to release a card, stay byte for byte.

- **Since** is the author date of the earliest commit on the branch, and not on a base ref, whose subject is `<id>: started` and whose body has the line `Claim: ` and 40 hexadecimal digits, so a commit made by hand with that subject is not a claim, as `git log --format=%ad --date=short` prints it. The author date does not move when the branch is rebased. A date in that form is the only text that comes from the commit.
- **Where** is one of three. `here`: a local branch of this clone that no other worktree has checked out. `in another worktree`: a local branch that `git worktree list --porcelain` shows in a worktree other than the current one. `on the remote`: no local branch.

No name, no email, no path and no branch name is printed. A branch with no claim commit gets no mark. `card status` is unchanged: it is what the session-start hook prints, and the mark costs one `git log` per card in progress.

`card claim` on a held card prints one line and exits 1:

| Line | When | What next-card does |
|---|---|---|
| `held here` | a local branch that no other worktree has checked out | asks whether to resume, then runs `card claim --resume <id>` |
| `held worktree` | a local branch that another worktree has checked out | stops, and says that `git worktree prune` frees a branch whose worktree was removed by hand |
| `held mine` | only on the remote, and the author email of its claim commit is the one git would use here | asks whether to resume, then runs `card claim --resume <id>` |
| `held remote` | only on the remote, otherwise | stops |

`card claim --resume <id>` checks out the branch of the id, for the first and the third line only, and prints `resumed`. For `held mine` the local branch is made from the remote one and tracks it. The email is the one in `git var GIT_AUTHOR_IDENT`, so an identity set in the environment counts; it is compared and never printed. A remote branch with no claim commit, made by 0.2, is `held remote`: without the commit nothing says whose it is.

## 7. Worktrees and the base refs

`card` has read state from two base refs since 0.1: `origin/<base>` and the local base branch. 0.3 uses them in three places.

- **The start of a branch** is the later of the two: the one that contains the other. Usually that is `origin/<base>`, and in a linked worktree whose local base branch is behind it always is. A local base branch with commits that are not pushed is the start when it contains `origin/<base>`, as in 0.2. `card base-ref` prints it, and `card base-ref --fetch` fetches first.
- **The fork point** of a card's branch is the commit where it left the base branch, as `card touched` has computed it since 0.1. `card fork-point` prints it. Handoff gives it to the reviewer in place of the base branch's name, and uses it in `git log <fork point>..HEAD`. In a worktree whose local base branch was behind, `git merge-base HEAD <base>` gave an older commit and the diff listed another card's files (the second review of the scope).
- **The conflict report** compares with `origin/<base>` after a fetch, or with the local base branch where there is no remote.

`gh pr create --base` keeps the branch's name.

next-card and quick detach at the start, and no skill but plan checks out the base branch or pulls it. The local base branch stays where the user left it and may fall behind; done on either ref counts, as before.

Supported: a session started with `claude --worktree`, and one started in a worktree made with `git worktree add`. In the second the session's first directory is the worktree, and a hook that asks git for the top level got the worktree (the second review of the scope). For the first that is expected and was not run (section 19, row 6); item 6 of section 21 runs it before any skill is changed. Not supported: a worktree entered in the middle of a session. There `${CLAUDE_PROJECT_DIR}` stays at the first directory and only the `cwd` field of the hook input moves (row 3); the hooks read neither.

A worktree that Claude Code makes starts on a branch `worktree-<name>` (row 1). `card claim` leaves that branch and nothing uses it again. When the session ends Claude Code may remove the worktree "and its branch" (row 4). Which branch that is after `card claim` has switched to `card/<id>` is not known (row 5). If it is the card's, the local branch is gone and the claim is on the remote alone, which is what `held mine` is for.

`.claude/worktrees/` has to be ignored (row 2). Init offers the line for `.gitignore`, and `card claim` says where it is missing.

## 8. Configuration and compatibility

No key is added to `workdeck.conf`, no front matter key to a card, and no file to the cards or log directory. `version` stays 1.

| Situation | What happens |
|---|---|
| A 0.2 repository, plugin updated to 0.3 | A start now runs `card claim`. With a remote it pushes at the start of a card. `card list` shows a mark on a claimed card |
| A user who did not take init's permission entries | The skills' own `allowed-tools` allow `card`, so the push at a start raises no prompt, where 0.2's push at handoff did. The README says so |
| A repository with no remote | The claim is the branch and the empty commit. No push, no question |
| CI pinned to `card` 0.1.3 or 0.2.0 | `card lint` passes: no format changed |
| CI or a preview that runs on a push to any branch | It runs at the start of each card, on a branch that holds an empty commit |
| Pull requests that land as merge commits | The claim commit is in the base branch's history |
| A project that requires signed commits, or has a commit or pre-push hook | The claim commit is unsigned, and neither it nor its push runs a hook |
| A local base branch with commits that are not pushed | A card starts from it, as in 0.2, and the claim's push publishes those commits on the card's branch at the start, where 0.2 published them at handoff. `card claim` says how many |
| A clone made with `--depth`, or of one branch | It claims, and sees nobody else's claim until its push is rejected (section 5.6) |
| A branch made by 0.2, with a slug and no claim commit | `active` as before, with no mark. `card claim` reports it as held, and `--resume` takes it up when it is local |
| A team with both versions | The 0.2 member's start is not pushed, so a 0.3 member can claim the same card, and the 0.2 handoff's push is then rejected. A team updates together; the README says so |
| A 0.3 skill with a 0.2 `card` first on the PATH | The first new command a skill runs, `card base-ref`, prints `unknown command` and exits 2. The skill stops and says to update `card` |
| Git older than 2.38 | `card conflicts` says it cannot tell, and handoff goes on (section 11) |
| The two base refs have each a commit the other lacks | `card claim` refuses, as next-card's fast-forward pull refuses today |

## 9. The `card` command

| Command | Behavior |
|---|---|
| `card claim <id>` | Section 5.3. Stdout is one line: `claimed` (exit 0), `held here`, `held worktree`, `held mine`, `held remote` or `lost` (exit 1). A refusal is a `card:` message on stderr with exit 1. A claim that could not be pushed is `claimed` with a warning on stderr and exit 0 |
| `card claim --resume <id>` | Checks out the branch of the id when it is `held here` or `held mine`, and prints `resumed`. Exit 1 otherwise, with the line `card claim` would print |
| `card base-ref [--fetch]` | Prints the start of section 7 in its short form, `origin/main` or `main`. Exit 2 when there is no base branch, exit 1 when neither ref contains the other |
| `card fork-point` | Prints the commit where the current branch left the base branch. Exit 2 when they share no history, as `card touched` |
| `card conflicts` | Section 11. Exit 0 and `no conflict with <ref>`; exit 1 and one file per line on stdout; exit 1 and a `card:` message on stderr when it cannot tell |
| `card list`, `card next` | The mark of section 6. Unchanged for a card with no claim commit |

`card claim`, `card conflicts` and `card base-ref --fetch` use the network. Until now `--fetch` was the only network access in `card`. None is run by a hook.

Exit codes and message conventions are those of 0.1: 2 is a usage or configuration error only.

## 10. Skills

### 10.1 `/workdeck:next-card [id]`

The skill has eight steps, as now. Steps 1 to 3 are unchanged: the state, review fixes, a clean tree.

4. **A fresh tree.** Run `card base-ref --fetch` and `git checkout --detach <that ref>`. The base branch is not checked out and not pulled.
5. **Pick the card** and read its state from `card list`, as now. `waiting` and `review` stop, as now. The skill no longer runs `git branch --list`.
6. **Claim.** Run `card claim <id>`, for a card with a file and for a row alike.
   - `claimed`: go on.
   - `held here`, `held mine`: ask the user whether to resume. After a yes run `card claim --resume <id>` and go on.
   - `held worktree`, `held remote`, `lost`: say what the line means and stop.
7. **Read the card** with `card show <id>`, on the card's branch. If the output starts with `row:`, run `card plan start <id>` and then the sub-steps 2 to 6 of today's step 6. That holds for a new claim and for a resumed one alike: a row that was claimed and never approved has no card file on its branch. A no to the card, and a row that cannot be done as cut, delete the card file and print the three commands of section 5.5. After the yes the approval commit is made here, where today's step 7 made it. The rest of today's step 7, which created the branch, is gone.
8. **Implement,** and stop at handoff: today's steps 8 and 9 as one.

Where step 5 or 6 stops, the skill runs `git checkout -`, so the tree is back on the branch it started from and not left detached. Three sentences of the skill name "step 7" for the approval commit, in steps 5, 6 and 9; they name step 7 of this list.

A budget warning can now come while a row's card is being written, because that happens on a `card/*` branch. The warning says to ask for `/workdeck:handoff split`; before the card is approved the session instead tells the user and stops.

### 10.2 `/workdeck:handoff`

- Run `card fork-point`. Step 3 gives the reviewer that commit where it gave the base branch's name: the prompt is `Card <id>, changes since <commit>.` Step 7's search for the approval commit uses `<fork point>..HEAD`.
- Step 7, straight after the commit: run `card conflicts`. The pull request body gains a line, `Conflicts with <base> at handoff:` and `none`, the files, or `not checked` with the reason. It is a report and not a gate: handoff goes on, and tells the user in step 8 what to do about a conflict, which is theirs to resolve after the other card merges.
- Step 7, a push that is rejected: stop and show git's message. If the user, a reviewer or the host added a commit to this branch on the remote, a pull is right. If not, someone else holds a branch of this name, and a pull would merge two cards' work. The skill says both and does not pull.

### 10.3 `/workdeck:quick`

Step 2 becomes `card base-ref --fetch` and `git checkout --detach <that ref>`: the code is read, and the card written, on the base branch as it is now. Step 6 becomes `card claim <id>`, after the user's yes, so a no leaves no branch behind: the skill deletes the card file and runs `git checkout -`, which puts the tree back on the branch it was on. On `held` or `lost` the id was taken by another quick card of the same minute: run `date +%y%m%d%H%M` again, make the card again with `card new` under the new id, move the body into it, delete the first file and claim again. Nothing else was left behind.

### 10.4 `/workdeck:init`

One more step for both kinds of repository, asked like the others: if `.claude/worktrees/` is not ignored, offer the line for `.gitignore`.

### 10.5 `reference/implement.md`

Step 6 says that the claim commit is already on the branch, and for a planned card the approval commit after it, and that nothing else is committed before handoff.

## 11. Mechanical checks

`card conflicts` is the one new check. It fetches the base branch from `origin` where there is a remote, then runs `git merge-tree --write-tree --name-only --no-messages <ref> HEAD` and prints the files that conflict. It reads commits, so it runs after handoff's commit. Apart from the fetch it writes nothing: not to the working tree, the index or a branch.

It cannot tell when git is older than 2.38 and when the branch shares no history with the base ref: any exit of `git merge-tree` other than 0 and 1. A fetch that fails is a warning, and the answer is for the ref as it is.

It is not a gate. Parallel cards will conflict (risk 6 of the scope: 25 of 39 pairs in this repository's history), and the branch that is handed off first is not the one that has to change.

Known limits:

- The answer is true when it runs. A card that merges a minute later changes it.
- It compares with the base branch and not with other open branches, so of two cards open at once the second to merge is the one that learns of the conflict, and only if it is handed off after the first merged.

## 12. Agents

No agent file changes. The reviewer receives a commit where it received the base branch's name; its file still says "a base branch", and what it does with it is the same. Its `git merge-base HEAD <that commit>` prints the same commit, and its diff is then the one `card touched` measures. The plan reviewer is not run in a worktree: the plan skill is out of 0.3 there.

## 13. Hooks

No hook changes.

- **Stop.** An empty commit is not counted, so a claim does not trip the log guard. It exits 0 on a detached HEAD. It reads both base refs already.
- **Post-tool-use.** It reads `.git` as a file in a linked worktree and keeps its marker in that worktree's git directory. One effect is new: section 10.1, the warning while a card is written.
- **Session-start.** It prints `card status`, which is unchanged.
- **Pre-compact.** Its marker is per worktree.

The reviews ran the stop and post-tool-use hooks in a worktree made with `git worktree add`. In a session that Claude Code started with `--worktree`, none was run (section 19, row 6).

## 14. Hand runs, the record and release

Before the release, each in `docs/evidence.md`:

1. Two clones start one card within seconds. One prints `claimed`, the other `lost`, and the second has no card branch.
2. Two sessions in two worktrees of one clone start one card, and then one row.
3. A card and a quick card through next-card and handoff in a worktree made by `claude --worktree`, with the local base branch behind. Item 6 of section 21 makes the first part of this run early.
4. On GitHub: a pull request from a branch whose first commit is empty, merged by squash and by rebase, and a claim on a repository that protects `card/*`.

Then the maintainer runs a deck in parallel. Nothing new is stored. The evidence page records, per card, whether `card claim` printed `held` or `lost` for a card that `card next` had offered, and per pair of cards open at the same time, the `Conflicts with` line of the second one's pull request and whether its merge conflicted, with the files.

The version in `plugin.json` changes last, as in 0.2 (design-0.2, section 21, item 11).

## 15. Errors

| Situation | Behavior |
|---|---|
| `card claim` for a card that is done or waiting | Exit 1 with the state, and for `waiting` the dependency |
| `card claim` for an id with no card and no row | Exit 1 with the ids of the same prefix, as `card show` |
| `card claim` for a card file tracked on this branch and on no base ref | Exit 1: the card belongs to the branch that holds it |
| The fetch fails | A warning. The claim goes on with the refs as they are |
| A branch of the id exists, here or on the remote | `held ...`, exit 1 |
| Neither base ref contains the other | Exit 1, before any commit is made |
| Git has no identity to use | Exit 1 with git's message, before any push. In 0.2 a card could start there and fail at handoff's commit |
| The push fails and the remote has a branch of the id | `lost`, exit 1. Nothing was created here |
| The push fails and the remote has none, or cannot be asked | A warning, and the claim goes on: `claimed`, exit 0 |
| The checkout fails after the push | Exit 1. A branch made by another worktree in the meantime: `held worktree`. Otherwise git's message, and that `card claim --resume <id>` takes the claim up |
| The user says no to a row's card | The card file is deleted. The branch is left, here and on the remote, and next-card prints the three commands that delete it |
| A row cannot be done as cut | The same, and next-card names the plan skill |
| Handoff's push is rejected | Handoff stops and does not pull (section 10.2) |
| `card conflicts` with git older than 2.38, or no shared history | A `card:` line on stderr, exit 1. Handoff writes `not checked` |
| `.claude/worktrees/` is not ignored | One line on stderr from `card claim`. Until it is ignored the stop hook does not block, `card touched` fails on the directory and `git add -A` stages it |

## 16. Trust and input handling

- `card` prints no branch name it did not build from a checked id, and none at all from the remote. The rule of `cards/REVIEW.md` on text that reaches an agent's context is unchanged.
- From a claim commit `card` takes a date, in the form git prints, and compares an email. A commit's author is whatever its maker wrote. Someone who can push to the repository can make a branch that another user's session offers to resume as `held mine`. What that session then reads is a teammate's branch, which a pull request shows it anyway; the user is asked before the checkout.
- The id is checked before it reaches a branch name, a ref pattern or a commit message. The push names one commit and one ref, `refs/heads/card/<id>`, with no `--force` and no `--delete`.
- `card claim` creates a branch and pushes with no prompt, if a rule that allows `card` covers the git commands it runs (section 19, row 21, unverified). A session's own `git checkout -b` is not among the permission entries. What it can push is one new commit with the tree of its parent, to a branch named after a card of the deck, and with it whatever the local base branch holds that was not pushed, when that branch is the start. `card claim` gives the count.
- The line of the claim commit is random. Nothing of the machine is in it.

## 17. Testing

- Shell tests as before, with a local bare repository as the remote. `card claim`: each line of section 9 and each row of section 15; two clones that claim one card, where exactly one prints `claimed` and the other has no card branch afterwards; two worktrees of one clone, with and without a remote; a row; a quick card; a branch of 0.2 with a slug; `held mine` by email, from the configuration and from the environment; a commit hook that refuses the subject. `--resume` for each line.
- `card base-ref` with the local base branch behind, ahead and diverged. `card fork-point` against what `card touched` uses.
- `card list` and `card next` with a mark in each of the three places, with none for a branch that has no claim commit, and with the date unchanged after a rebase.
- `card conflicts`: none, one file, no shared history, and a stub `git` that reports a version before 2.38.
- The byte-for-byte case of 0.2 (design-0.2, section 17) still passes: no test of 0.1 makes a claim.
- The skills cannot be unit tested. Shell tests check their mechanics as before: that every `card` command a skill names exists, and that next-card runs `card claim` before `card plan start`. The hand runs of section 14 are the rest.

## 18. Risks

| Risk | Response in 0.3 |
|---|---|
| A no to a row's card leaves a branch that holds the row for everyone | next-card prints the commands. `card list` shows since when it is held |
| An abandoned claim holds a card, now on the remote too | Since when is the whole response. A person deletes the branch |
| Parallel cards conflict, and 0.3 only reports it | `card conflicts` at handoff, and the record of each pair |
| A branch named by an id alone says less in a list of branches | The pull request's title has the card's title. `card list` has both |
| Claude Code deletes the card's branch when a worktree session ends | Not known. Item 6 of section 21. `held mine` recovers the claim |
| The hooks in a `claude --worktree` session | Run only in a worktree made with git. Item 6 of section 21 |
| A rule that allows `card` may not cover the push inside it | Not known. Item 6 of section 21. If it is asked each time, the start still works, with one prompt |
| A skill no longer updates the local base branch, so it falls behind | `card` reads both refs. A user who works on the base branch by hand pulls it by hand |
| `card` now pushes, with no prompt | One fixed command, to `origin`, of one empty commit, and of the local base branch's unpushed commits when it is the start (section 16). In the README |
| A start that stops early leaves the tree detached | The skills run `git checkout -` where they stop. A session that dies in between leaves it detached; `git checkout <branch>` returns |
| A push at every start runs CI where it is built on any push | In the README. No key turns the push off (decision 1) |
| The claim commit is unsigned and skips the project's hooks | In the README. A host that refuses unsigned commits refuses the push; the claim then stands unpushed, with a warning |
| The trial of 0.2 plans this design, and merges some of its cards before 0.2.0 is tagged | Section 21: which items may, and `card claim` is unknown until its last card |

## 19. Claude Code and git behavior this design relies on

Claude Code pages are under `https://code.claude.com/docs/en/` and were read on 2026-10-11, by the means [`development/review-0.3.md`](development/review-0.3.md) names. Git pages are the manual pages of git 2.54.0, and "run" means run that day with that version in a scratch repository with a bare remote, by the writer or by a reviewer. A row marked unverified was neither read nor run.

| # | Claim | Page | Status |
|---|---|---|---|
| 1 | `claude --worktree <name>` creates `.claude/worktrees/<name>/` at the repository root, on a new branch `worktree-<name>`, cut from the remote's default branch unless `worktree.baseRef` is `head` | `worktrees` ("Start Claude in a worktree") | read |
| 2 | The page says to add `.claude/worktrees/` to `.gitignore` | `worktrees` | read |
| 3 | After a worktree is entered in the middle of a session, `${CLAUDE_PROJECT_DIR}` stays where the session started and the `cwd` field of the hook input is the worktree root | `worktrees` ("Ask Claude to create a worktree") | read |
| 4 | When an interactive worktree session ends, Claude Code removes a clean worktree and its branch, at once for an unnamed session and after a question for a named one, and asks when the worktree has changed files or new commits | `worktrees` ("Clean up worktrees") | read |
| 5 | Which branch "its branch" is after the session has switched the worktree to another one | none | unverified. Item 6 of section 21 |
| 6 | In a session started with `--worktree`, a plugin hook's working directory is the worktree | none | unverified. The hooks were run in a worktree made with `git worktree add` only |
| 7 | Permission entries and project plugins are shared between a worktree and the main checkout | `worktrees` | read by the third reviewer of the scope, not again |
| 8 | Linked worktrees share the refs of the repository, and a branch that exists cannot be created again | `git-worktree`, `git-checkout` | run: `fatal: a branch named ... already exists`; made at the same moment in two worktrees, `fatal: cannot lock ref ...: reference already exists`, exit 128 |
| 9 | A linked worktree cannot check out a branch that another worktree has, and can detach at any commit | `git-worktree`, `git-checkout` | run: `'main' is already used by worktree`; `git checkout --detach origin/main` gave `HEAD (no branch)` |
| 10 | `git checkout -b <new> origin/<base>` sets the new branch's upstream to the base branch unless `--no-track` is given | `git-checkout`, `git-config` (`branch.autoSetupMerge`) | run both ways: without the option, `set up to track 'origin/main'`; with it, `no upstream configured` |
| 11 | An untracked file is carried over by `git checkout -b` when the new commit has no file at its path | `git-checkout` | run |
| 12 | `git commit-tree -p <commit> '<commit>^{tree}'` makes a commit with the tree of its parent, runs no commit hook and does not sign unless given `-S` | `git-commit-tree` | run: exit 0 under a `commit-msg` hook that refused the same subject from `git commit`, and with `commit.gpgsign` set and no working signing program |
| 13 | `git merge-tree --write-tree --name-only --no-messages <a> <b>` prints a tree and then the conflicted files, exits 1 on a conflict, works on a detached HEAD, and touches neither the working tree nor the index. It exists from git 2.38 | `git-merge-tree` | run: one file, exit 1, `git status` unchanged. With no shared history it printed `fatal: refusing to merge unrelated histories` and exited 128. The version is from the scope's third review and was not read again |
| 14 | `git ls-remote --exit-code origin <patterns>` exits 0 when a ref matches, 2 when none does and 128 when the remote cannot be reached | `git-ls-remote` | run for 0 and 2. 128 is the third reviewer's run |
| 15 | `git push origin <commit>:refs/heads/<name>` creates the branch on the remote with no local branch, and the remote-tracking ref here unless the clone fetches one branch only. It runs the pre-push hook unless given `--no-verify`. A second clone that pushes another commit to that name is rejected with `(fetch first)` and exit 1, and has no local branch | `git-push`, `githooks` | run in two clones, in a clone made with `--depth 1`, and with a pre-push hook that fails. Not run with `--no-verify` |
| 16 | `git worktree list --porcelain` prints one `worktree` line and one `branch` line for each worktree that is on a branch | `git-worktree` | run |
| 17 | `git log --format=%ad --date=short` prints the author date as `YYYY-MM-DD`, and a rebase keeps the author date and changes the committer date | `git-log` | run: after `git rebase` the committer date of a claim commit moved and the author date did not |
| 18 | `od -An -N20 -tx1 /dev/urandom` gives 40 hexadecimal digits once spaces and newlines are removed | `od` (POSIX); `/dev/urandom` is not in POSIX and is on macOS and Linux | run on macOS. Not run on Linux |
| 19 | GitHub accepts a pull request from a branch whose first commit is empty, and merges it by squash and by rebase | none | unverified. The fourth hand run |
| 20 | A user who has the plugin receives what the main branch holds when `version` changes; a new install takes the branch as it is | `plugins/host-marketplace` ("Release a new version"), `plugins/loading` ("Versions and updates") | read on 2026-10-09 for design-0.2 (section 19, row 18, and section 18, last row), not again |
| 21 | A Bash rule matches the command as written, so a session that may run `card *` is not asked again for the `git push` and `git checkout -b` that `card claim` runs inside it | `permissions` | unverified for this design. Design-0.2, section 19, row 12, read the page for the matching of a command as written. Nobody ran a `card` that pushes under the permission entries; item 6 of section 21 does |
| 22 | `git var GIT_AUTHOR_IDENT` prints the identity a commit made now would have, from the environment before the configuration | `git-var` | run: an email set in the environment was printed, not the configured one |

## 20. What this design amends

Sentences of the two earlier designs, of `bin/card` and of the shipped skills, that 0.3 makes false. The earlier design files are not edited; the skills and the reference are changed by their cards.

| Where | Says | In 0.3 |
|---|---|---|
| design.md, section 2, goal 5 | Card and log files never produce merge conflicts | They did, three times each for two cards (the third review of the scope, in `development/review-0.3.md`). Not fixed in 0.3; `card conflicts` reports it |
| design.md, section 3, "In-progress state" | No commit is needed to claim a card | One empty commit is. State is still derived from branches and not stored |
| design.md, section 6 | A card's branch is `card/<id>-<slug>`, or `card/<id>` when the card has no slug | `card/<id>` for every claim. A branch with a slug is still read |
| design.md, section 6 | Deleting the branch releases the card | The branch is in two places (section 5.5) |
| design.md, section 6 | `card` makes no network call unless given `--fetch` | `card claim` and `card conflicts` do |
| design.md, sections 10.2 and 10.4 | A fast-forward pull of the base branch; the branch is created by the skill | Sections 10.1 and 10.3 |
| design.md, section 10.2, step 5 | A card whose branch is local was started here | Section 6: `held here`, `held worktree` |
| design.md, section 12 | The reviewer receives the card id and the base branch | The card id and the fork point |
| design.md, section 15 | With no network, state uses local branches | Still true, and a claim that cannot be pushed stands with a warning |
| design-0.2, sections 10.2 and 15 | The card is written on the base branch; a no leaves no branch; "Nothing was committed and no branch exists" | The claim comes first. A no leaves a branch and a pushed empty commit |
| design-0.2, section 2 | A script that orders cards touching the same file is left to 0.3 | Dropped (decision 6) |
| `bin/card`, `card next` | "deleting it releases the card", with a command that lists local and remote branches | Kept byte for byte (goal 4). It does not say that the remote branch has to be deleted too; the README does |
| next-card, its description and step 4 | "Updates the base branch"; the base branch is checked out and pulled | The tree is detached at the start of section 7 after a fetch. A linked worktree refuses the checkout of the base branch |
| next-card, step 5 | `git branch --list "card/<id>*"` decides whether a card was started here | `card claim` decides, with an exact match |
| next-card, steps 6 and 7 | A row's card is written "on the base branch"; "nothing was committed and no branch exists"; "a no leaves nothing behind"; the branch is named after the file and made with `git checkout -b` | On the card's branch, after the claim; a no leaves a branch; `card claim` makes the branch, named by the id |
| quick, steps 2, 5 and 6 | The base branch is checked out and pulled; "an untracked card left on the base branch"; `git checkout -b <branch>`, named after the file | Detached at the base ref; `card claim` |
| handoff, steps 3 and 7 | `<base>` in the reviewer's prompt and in `<base>..HEAD` | The fork point |
| `reference/implement.md`, step 6 | The approved card is the only commit before handoff | The claim commit is before it |

## 21. Build order

A new install takes the main branch as it is, and a user who has the plugin receives it when the version changes (section 19, row 20). So no card may leave a command on the main branch that does half its work, or a skill that names a command that is not there.

The rule: each of the four new commands is an unknown command, `card: unknown command 'claim'` and exit 2, and is not in `card help`, until the card that changes the first skill which uses it. Before that it runs only with `WORKDECK_UNRELEASED` set in the environment, which the tests do. `claim` and `base-ref` become known in item 7, `fork-point` and `conflicts` in item 8. Each skill changes whole in one card. The card that makes a command known adds its row to `docs/reference.md`, which a test requires of every command in `card help`.

1. `card base-ref` and `card fork-point`.
2. `card claim` with no remote: the lookup, the card, the start, the commit, the branch, the `held` lines and `--resume`. Unknown to a user.
3. `card claim` with a remote: the fetch, the push before the branch, the question to the remote, `lost`, `held mine`. Still unknown.
4. The mark in `card list` and `card next`.
5. `card conflicts`.
6. A hand run in a session started with `claude --worktree`, under the permission entries, with `card claim` run by hand. `WORKDECK_UNRELEASED` is exported in the shell that starts `claude`, so that the command the session types is `card claim <id>` and nothing before it. The run records: what the hooks print there, whether the push inside `card` raises a prompt, and which branch is gone after the session ends (rows 5, 6 and 21 of section 19). If one of them breaks this design, it is amended before item 7.
7. next-card and `reference/implement.md`, and `card claim` made known.
8. Handoff: the fork point, the conflict line, the rejected push.
9. Quick, init and the protocol line.
10. The README, the changelog and what is left of the reference.
11. The hand runs, the parallel deck and the evidence page.
12. The version, as the last commit before the tag.

Items 1 to 6 can merge before 0.2.0 is tagged: nothing they add can be reached by a user (design-0.2, section 22, decision 1). The mark of item 4 shows only on a branch with a claim commit, which nothing a user can reach makes. Items 7 to 9 change what a user's skills do and wait for the tag. Handoff is among them: its advice on a rejected push is about claims, and is wrong for a 0.2 user.

## 22. Decisions on the open points

The draft ended with eight points that its writer left to the maintainer. The maintainer told the session to have them attacked and to decide. The second and third passes of [`development/review-0.3.md`](development/review-0.3.md) have each attack and its evidence.

| Point | In the draft | Decided |
|---|---|---|
| 1. Who pushes | `card claim` | Kept. A user who did not take the permission entries now gets a push with no prompt: section 8 and the README say so |
| 2. When a quick card is claimed | After the yes; a refused claim stops | After the yes. A refused claim takes a new id and claims again |
| 3. The base branch at a start | Never checked out; every start detaches at `origin/<base>` | Never checked out by next-card, quick or handoff. next-card and quick detach after a fetch, and return with `git checkout -` where they stop early. The start is the later of the two base refs, so a local base branch that is ahead still starts a card |
| 4. The mark | Only for a branch with a claim commit | Kept |
| 5. What merges before 0.2.0 | `WORKDECK_UNRELEASED` for `card claim`; items 1 to 7, handoff among them | The variable hides all four commands, as unknown commands and not a new exit, so design-0.2's rule is kept as written. Items 1 to 6; handoff waits with the other skills |
| 6. The line that differs | A hash of seven values | 40 digits from `/dev/urandom` |
| 7. Git versions | None stated | None for the claim. 2.38 for the conflict report, in the README. The date is read with `--date=short`, which needs no recent git |
| 8. A branch name in a `held` line | Printed in a fixed form | Not printed. `card claim --resume <id>` does the checkout, and the rule of `cards/REVIEW.md` stays |

What else the reviews changed, each against the draft:

- The branch is `card/<id>` for every claim, not only for a quick card. This amends decision 2 of the scope in one thing, the order for a row: the claim now comes before `card plan start`, because the name no longer waits for the file. The scope note is amended with it.
- The commit is made with `git commit-tree` and pushed before the local branch exists. The scope said the loser "tells the user which local branch to delete"; there is none now.
- `card fork-point` is what handoff and the reviewer use, not a base ref: a branch of 0.2 cut from a local base branch that was ahead would have had that branch's commits read as its own.
- Since when is the author date, which a rebase keeps.
- A resumed row with no card file runs `card plan start` on its branch.
- A card file tracked only on the current branch is refused, and a done card before its branch is looked for.
- The push skips the project's pre-push hook, and sets no upstream.

Not decided here, because only a run can: rows 5, 6, 19 and 21 of section 19.
