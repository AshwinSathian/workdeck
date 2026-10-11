# Scope of WorkDeck 0.3

Date: 2026-10-11
Status: draft, written for card T-01. Not approved. The design is not started until the maintainer approves this note, and the six questions at the end are the maintainer's to decide.

## What 0.3 is

WorkDeck 0.1 and 0.2 are built for one person running one session at a time. Their formats allow more, and nothing implements it. The state of a card comes from branches, and a card is `active` once its branch exists, but nothing makes that branch visible to anyone else before handoff pushes it, and next-card needs the base branch checked out in the one working tree. 0.3 removes both limits. Starting a card claims it where everyone can see it, a session can start a card from a git worktree, and several sessions can each run a card at the same time without taking the same one.

## Who it is for

Two groups, in this order. One person who runs two or three sessions at once on one clone, each in its own worktree: the maintainer on this repository is the first. Then a team of two to five people on one GitHub repository, each with Claude Code and the plugin. A session still runs one card and a person still merges.

## In 0.3

- **A claim.** Starting a card pushes its branch before any work, so the card is `active` for everyone who fetches. The claim is the branch: no file, no commit on the base branch, and deleting the branch releases it, as now. The start fails for the second of two people who start the same card.
- **Who holds a card, and since when.** `card list` and `card next` say it for a card that is `active`, `blocked` or `review`, from what git already records for the branch. Today the hint for an abandoned branch names nobody and gives no age.
- **A start from a worktree.** next-card and quick work in a linked worktree, where the base branch cannot be checked out because the main working tree has it: the card's branch is cut from the fetched base branch instead. A card written from a row is written there too. The run is under risk 5.
- **Parallel sessions.** Two sessions on one clone do not pick the same card: a local branch already holds it, since worktrees share their refs (risk 5). Session markers, the log's numbering and the id of a quick card hold when two sessions run in the same minute.
- **A warning for cards that touch the same file.** When a card is started while another is in progress, and a file is under `Touch` in both, the start says so and asks. It is a warning, not an ordering of the deck.
- **The documentation** for running sessions in parallel: which Claude Code command starts a session in a worktree, and what init adds for it.

## Out of 0.3

- A session that launches other sessions, or implements several cards through subagents in worktrees. The user starts each session.
- Assigning a card to a person, and priorities. A person claims a card by starting it.
- A lock, a server or a state file. State stays derived from branches and pull requests.
- Merging, rebasing a card branch after another card merged, and resolving the conflict between two cards. The warning comes before; the rest is git and the person merging.
- A script that orders cards by the files they touch. Finding 6 of the first 0.2 review stands: a glob cannot be ordered, and where it can the deck becomes a chain. 0.2 left this script to 0.3, so leaving it out is question 6.
- Hosts other than GitHub, and harnesses other than Claude Code.
- A changed tests gate, new default budgets, and everything else in `later.md`.

## Compatibility

The formats stay at `version = 1`: no configuration key, no front matter key, and no new file in the cards or log directory, so a CI workflow pinned to `card` 0.1.3 or 0.2.0 keeps passing. A repository with no remote behaves as in 0.2, since there is nowhere to claim. A repository with a remote gains one push at the start of a card, which the permission entries of 0.1 already allow.

A new install takes the plugin from the main branch as it is (design-0.2, section 18, last row), and a user who has it already receives what that branch holds when its version changes (section 19, row 18). The design has to give a build order in which no skill sends a user to a command that is not there yet: the `card` changes first, the skills last.

## How we know it works

Hand runs before the release, each recorded in the evidence page: two clones that start the same card within seconds of each other; two sessions in two worktrees of one clone, each through next-card and handoff; a start from a worktree for a row and for a quick card. Then the maintainer runs a deck in parallel and the record gives, per card, whether a second session was offered a card that was taken, whether the warning fired and whether the merge then conflicted.

## Open risks

1. **A push does not decide a race by itself.** Run on 2026-10-11 with git 2.54 against a scratch remote: two clones that each cut `card/X-1-s` from the same commit both pushed it, the second with "Everything up-to-date" and exit 0, and `--force-with-lease=<branch>:` did not change that. With one commit of its own on each side the second push was rejected. So the claim needs a commit, and a card with a file has none at the start today; only a card written from a row has its approval commit. And the commit has to differ between the two: the reviewer at handoff made the same empty commit in two clones, with one identity, one parent and one second, got one hash, and the second push was accepted. One person with two clones is the first audience.
2. **The claim comes before the work, and an abandoned one holds the card.** A session that stops after its first step leaves a branch on the remote, and the permission entries deny deleting branches. Who holds it and since when is the whole response: a person deletes the branch.
3. **Text from a branch is chosen by whoever pushed it.** A name read from a commit reaches the session's context through `card next`. It is filtered as a card title is, or `card status` leaves it out as it leaves out the name of every branch but the current one.
4. **The warning reads `Touch` from a branch the session is not on.** From another card's branch 0.1 reads one thing, whether the card has a `## Blocked` section. A row has no `Touch` until its card is written, so two rows started together are warned only when the second card is written.
5. **Claude Code's worktrees are not ours.** `claude --worktree <name>` creates `<repo>/.claude/worktrees/<name>` on a new branch named `worktree-<name>`, and the page says to add `.claude/worktrees/` to `.gitignore` (`cli-reference`, `worktrees`; read 2026-10-11 through Context7). So a session starts there on a branch that is not `card/*`, and a repository that has not added the line has a dirty main working tree, which stops next-card. Unverified: whether plugin hooks run there with the worktree as the working directory. Run on 2026-10-11 with git 2.54, in a worktree made with `git worktree add .claude/worktrees/w1`: `git checkout main` failed with "'main' is already used by worktree", the card branches of the main working tree were listed there, and the main working tree showed `?? .claude/`.
6. **A start with no network.** A claim that cannot be pushed is not a claim. The start either stops or goes on with a warning; question 3.
7. **The trial of 0.2 plans this design.** It is written by an agent that knows that (scope-0.2, risk 9), and no card that adds a command or skill of 0.3 which a user can reach merges before 0.2.0 is tagged, unless its feature is complete (design-0.2, section 22, decision 1).

## Questions for the maintainer

1. **Is the claim a push at the start, for every repository with a remote?** Recommended: yes, with no key to turn it off. The other way is a new configuration key, which `card` 0.1.3 exits 2 on.
2. **What is the commit that decides the race?** Recommended: for a card with a file, an empty commit `<id>: started`; for a row, the approval commit that 0.2 already makes. The stop hook leaves both out of its count. The design has to make the first differ between two clones of one person (risk 1).
3. **Offline, or a push that fails for another reason: stop, or start with a warning?** Recommended: start with a warning. The card is `active` locally and the push is made at handoff, as today.
4. **Two people planning at once.** 0.2 left it to 0.3. Recommended: out. Two plan runs for one specification already conflict in the second pull request, and nothing was lost when that was the only answer.
5. **The same-file warning: in, as above, or out?** Recommended: in, as a warning that asks. It is the one part that reads card content from other branches, so it is also the part to cut if the design finds it costs more than it tells.
6. **The script check that orders cards touching the same file.** 0.2 left it to 0.3 (design-0.2, section 2). Recommended: out, for the reason under "Out of 0.3", with the warning of question 5 in its place.
