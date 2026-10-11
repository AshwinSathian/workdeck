# Scope of WorkDeck 0.3

Date: 2026-10-11
Status: decided on 2026-10-11 by the session that wrote it, and approved by the maintainer's merge of pull request 40. The first draft ended with six questions for the maintainer. The maintainer told the session to have the pull request attacked by agents that did not write it and to take the six decisions itself. They are at the end: two of the six recommendations were overturned and a third amended. The reviews are in [`review-0.3.md`](review-0.3.md). The design is card T-01b's and is not started.

## What 0.3 is

WorkDeck 0.1 and 0.2 are built for one person running one session at a time. Their formats allow more, and nothing implements it. The state of a card comes from branches, and a card is `active` once its branch exists, but nothing makes that branch visible to anyone else before handoff pushes it, and next-card needs the base branch checked out in the one working tree. 0.3 removes both limits. Starting a card claims it, a session can run a card in a git worktree, and several sessions can each run a card at the same time without taking the same one.

## Who it is for

First, one person who runs two or three sessions at once on one clone, each in its own worktree: the maintainer on this repository. Then a team of two to five people on one GitHub repository, each with a clone, Claude Code and the plugin. A session still runs one card and a person still merges.

## In 0.3

- **A claim, made before any other work.** Straight after a card is picked the session creates the card's branch, makes one commit on it and pushes it. For a row, `card plan start` runs first, because the branch is named after the file it creates; the claim follows, and the card is read for and filled in after it. On one clone the claim is the branch itself: worktrees share their refs, and creating a branch that exists fails. Between clones it is the push, which is rejected for the second of two people. The claim is the branch and nothing else: no file and no commit on the base branch.
- **Since when a card is held, and where.** `card list` and `card next` say it for a card in progress: the date of its claim, and whether its branch is here, in another worktree of this clone or only on the remote. No name and no path is printed.
- **A card run in a worktree.** next-card, quick, handoff and the reviewer work in a linked worktree, where the base branch cannot be checked out and the local one may be behind: the start fetches and cuts the branch from the remote base branch, and every later step that names the base reads that ref. If the fetch fails the start warns and uses the ref as it is.
- **Parallel sessions.** Two sessions do not hold the same card, a row included. A quick card's branch is named by its id alone, so the second of two made in the same minute is refused. A card whose branch is checked out in another worktree is not offered for resuming. One whose branch is only on the remote, with a claim commit by the user's own email, is.
- **The losing side of a race.** A session whose claim is refused stops, does not pull, and tells the user which local branch to delete.
- **A conflict report at handoff.** After its fetch, handoff says whether the branch would conflict with the remote base branch and names the files. It reads and changes nothing.
- **`.claude/worktrees/` is ignored.** Init offers the line for `.gitignore`, and a start says so where it is missing.
- **The documentation** for running sessions in parallel, with what the user does when handoff reports a conflict, and a record of each parallel pair of cards: whether the second merge conflicted, and in which files.

## Out of 0.3

- A warning or a question at the start when two cards list the same file, and a script that orders such cards. Decisions 5 and 6.
- Two people planning at once. Decision 4.
- A session that launches other sessions, or implements several cards through subagents in worktrees. The user starts each session.
- The plan skill and init in a linked worktree. They are run in the main working tree.
- A worktree entered in the middle of a session, and a background session that moves itself into one. Supported: a session started with `claude --worktree`, or in a worktree made with `git worktree add`.
- The name of whoever holds a card, in anything `card` prints. `git log` on the branch shows it.
- A quick card in progress seen from another worktree. Its file is in no commit until handoff.
- Assigning a card to a person, priorities, a lock, a server or a state file.
- Merging, rebasing a card branch after another card merged, and resolving a conflict between two cards.
- Hosts other than GitHub, harnesses other than Claude Code, a changed tests gate, new default budgets, and everything else in `later.md`.

## Compatibility

The formats stay at `version = 1`: no configuration key, no front matter key and no new file in the cards or log directory, so a CI workflow pinned to `card` 0.1.3, or to 0.2.0 once it is tagged, keeps passing. A repository with no remote gains the claim commit, the conflict report and what a worktree needs. One with a remote also gains a push at the start of a card, which the permission entries of 0.1 already allow, and with it a run wherever CI or a preview is built on a push to any branch. Where pull requests land as merge commits, the claim commit is in the base branch's history.

The claim commit amends one row of `docs/design.md`, section 3: state is still derived from branches and not stored, but "no commit is needed to claim a card" stops being true.

A new install takes the plugin from the main branch as it is (design-0.2, section 18, last row), and a user who has it already receives what that branch holds when its version changes (section 19, row 18). The design has to give a build order in which no skill sends a user to a command that is not there yet: the `card` changes first, the skills last.

## How we know it works

Hand runs before the release, each in the evidence page: two clones that start the same card within seconds; two sessions in two worktrees of one clone that start the same card and the same row; a card and a quick card through next-card and handoff in a worktree whose local base branch is behind. Then the maintainer runs a deck in parallel, and the record gives per card whether a session was offered a card that was taken, and per pair what the last item of "In 0.3" names.

## Open risks

Runs marked second or third review are in `review-0.3.md`. All used git 2.54 on 2026-10-11.

1. **A push decides a race only between two different commits.** Two clones that cut one branch from one commit both pushed it, the second with "Everything up-to-date" and exit 0, and `--force-with-lease=<branch>:` did not change that. So did two that each made the same empty commit in the same second with one identity: one hash. With a commit that differed the second push was rejected. The claim commit therefore carries a line no other session has, and `card` makes it, so that no skill has to invent one.
2. **A no to a row's card now leaves a branch,** and so does a row that cannot be done as cut. In 0.2 the card is written before any branch exists, and next-card says a no leaves nothing behind. In 0.3 the row stays `active` for everyone until the branch is deleted: here, on the remote, and in the clone of anyone who lost the race for it (third review). The permission entries deny a session all three, so it prints the commands and the user runs them.
3. **An abandoned claim holds the card,** and it is now on the remote as well. Since when it is held is the whole response: a person deletes the branch.
4. **Offline, two people can hold one card** (decision 3). They meet at handoff's push, which is rejected with git's hint to pull; following it merges two cards' work. Handoff says not to.
5. **State is read from the prefix `card/<id>`, and a push is refused only for one branch name.** `card/X-6-one` and `card/X-6-two` were both pushed (second review); a card file renamed between two fetches gives this. The start looks for any branch of the id after its fetch, which leaves the time between the fetch and the push.
6. **Parallel cards will conflict, and 0.3 only reports it.** By the third review's count on this repository's history, of 39 pairs of cards merged one after the other with no dependency between them, 25 would have conflicted had both been cut from the same commit. The files were `docs/development/review-0.2.md` 15 times, `docs/development/later.md` 7, two test files 4 each and `bin/card` 3. `later.md` is in `touch_ignore`, so no `Touch` list names it. Card files conflicted too, which goal 5 of `docs/design.md` says they never do.
7. **Claude Code's worktrees are not ours.** `claude --worktree <name>` creates `<repo>/.claude/worktrees/<name>` on a new branch `worktree-<name>`, cut from the remote's default branch and not from `base`, and the page says to add `.claude/worktrees/` to `.gitignore` (`cli-reference`, `worktrees`; read through Context7). In a worktree made with `git worktree add .claude/worktrees/w1`: `git checkout main` failed with "'main' is already used by worktree", and the main working tree showed `?? .claude/`. There, on a card branch with a code commit, the stop hook exited 0 where it exits 2 once the directory is ignored, `card touched` failed on the directory, and `git add -A` staged it as an embedded repository (second review). Both hooks ran in a linked worktree with markers of its own (second review). Not checked: a real `claude --worktree` session, and which branch Claude Code deletes when such a session ends after next-card has switched to `card/*`. If it is the card's, the claim is left on the remote alone, which is what resuming one's own claim is for.
8. **The trial of 0.2 plans the design that follows this note.** It is written by an agent that knows that (scope-0.2, risk 9), and no card that adds a command or skill of 0.3 which a user can reach merges before 0.2.0 is tagged, unless its feature is complete (design-0.2, section 22, decision 1).

## Decided on 2026-10-11

1. **The claim is a push at the start, for every repository with a remote.** No configuration key: `card` 0.1.3 exits 2 on one it does not know. The push goes to `origin` only, so a claim made on a fork is seen on the fork.
2. **One claim commit for every card, a row included.** An empty commit `<id>: started` that `card` makes, with a line that differs between sessions. For a row the order is `card plan start`, the claim, then the card. The stop hook leaves the commit out of its count, `card touched` passes on it and handoff's search for the approval commit does not match it (second review); with the branch made first, `card plan start`, `card plan check`, `card show`, `card status` and `card list` behaved (third review). The first recommendation, the approval commit for a row, was overturned: that commit comes after the card is written and approved, so two sessions would each write the card of one row and one would lose minutes later. The approval commit stays what it is in 0.2.
3. **A claim that cannot be pushed.** After a push that fails, the start asks the remote for any branch of the id. If there is one, the race is lost and the session stops. If there is none, or the remote cannot be asked, it warns and goes on, as 0.2 does for everyone today. The question is asked because what `git push` prints and exits with does not tell a lost race from a host that refuses the branch: both are a rejection and exit 1 (third review).
4. **Two people planning at once: out,** and not deferred again. A plan's prefix and outline are chosen inside the run, so there is nothing to claim at its start. What the second of two loses is one plan run, about 40,000 tokens (design-0.2, section 18).
5. **The same-file warning: out.** The recommendation was overturned. Of the 119 pairs of P cards in this repository with no dependency between them, 110 share a `Touch` entry (third review), so the question would be asked at nine starts in ten and answered without reading. It cannot see a row, a quick card, a line added to `Touch` during the work or a file in `touch_ignore`. In its place 0.3 has the conflict report at handoff, which reads the files and not the lists, and the record of each pair.
6. **The script that orders cards touching the same file: out, and dropped.** 0.2 left it to 0.3 (design-0.2, section 2). `bin/card` is under `Touch` in 21 of 59 cards and `test/cases/02-plugin.sh` in 26: an order would make the deck one chain.
