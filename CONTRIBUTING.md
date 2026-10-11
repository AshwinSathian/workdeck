# Contributing

A question goes where [`SUPPORT.md`](SUPPORT.md) says, and a security problem where [`SECURITY.md`](SECURITY.md) says. [`docs/README.md`](docs/README.md) is a map of the documentation. This page is for a change you want to make.

## Run the tests

```
make check         # lint, test and links: run this before a pull request
make test          # the whole suite, about a minute
make lint          # shellcheck
make links         # every relative link and anchor in the markdown files
/bin/bash test/run.sh lint tokens     # only the cases whose name contains a word
```

You need bash, git, awk, sed, grep, sort (with `-V`) and the usual POSIX tools. `make lint` needs [shellcheck](https://www.shellcheck.net/); CI uses 0.11.0. On macOS the suite runs under `/bin/bash`, which is 3.2, so a bash 4 feature fails there.

There is no test framework. `test/run.sh` runs every function named `test_*` in `test/cases/*.sh`, each in its own bash process. `test/lib.sh` gives each case a temporary git repository, a stub `gh`, and a few assertions. A case never touches the network or your real `~/.claude`.

Case files are numbered by area:

| Files | Area |
|---|---|
| `00` to `02` | the harness itself, portability, the plugin's files |
| `10` to `14` | reading: config, cards, lint, list |
| `20` to `23` | state: base branch, branches, `--fetch`, status |
| `30` to `34` | writing and the gates: new, done, touched, tests, logs |
| `40`, `41` | token measurement and stats |
| `50` to `53` | the four hooks |
| `60` | the skills' mechanics |

Write the test first and watch it fail.

## Rules the code keeps

These are checked in review; the full list is in [`cards/REVIEW.md`](cards/REVIEW.md).

- `bin/card` stays one file and runs on bash 3.2: no associative arrays, `mapfile`, `${var,,}` or `local -n`.
- awk code must work in mawk, gawk and the awk on macOS: no interval expressions, no POSIX classes, no `gensub`.
- No `sed -i`, no `grep -P`, no jq, python or node.
- Nothing from `workdeck.conf` or a card file is ever sourced or evaluated.
- A hook exits 0 at once without `workdeck.conf`, and exits 0 on any internal error.

## How this repository is worked on

WorkDeck is developed with itself. Work is a card in `cards/`, done on a branch named `card/<id>-<slug>`, and handed off with a session log in `log/`. `card list` shows the deck. If you would rather send a plain pull request, that is fine: say what it changes and how you tested it.

Design notes are in `docs/`. [`docs/releasing.md`](docs/releasing.md) is the checklist for a release. [`docs/development/findings.md`](docs/development/findings.md) records what went wrong while building and what was decided about it.

## A first change, step by step

This walks a small change through the project's own loop, with the commands as typed. For anything larger than a fix, open an issue first: a card is cheap to write and a rejected pull request is not.

1. **Fork and clone.**

   ```
   gh repo fork AshwinSathian/workdeck --clone
   cd workdeck
   make check
   ```

   `make check` should pass before you change anything. If it does not, that is a bug report.

2. **Start Claude Code with the plugin loaded from your checkout**, so that the skills and hooks you run are the ones you are changing:

   ```
   claude --plugin-dir .
   ```

   If you have WorkDeck installed from the marketplace, the checkout takes its place for this session.

3. **Start the change.** For a fix, a rename or a small addition, type:

   ```
   /workdeck:quick "card lint: say which line has the tab"
   ```

   It writes a card of size XS with the files it will touch and the tests it will add, shows it to you, and waits for your yes.

   For work that needs thought, write the card yourself, in a shell. The plugin puts `card` on the PATH only of the commands Claude runs, so here it is `bin/card`:

   ```
   bin/card new LINT-01 "card lint: say which line has the tab" --size S
   ```

   Fill in its five sections as [`README.md`](README.md#a-card) describes, run `bin/card lint`, then commit the card on your main branch and push it, as next-card starts from a clean tree and from the base branch. Then type `/workdeck:next-card LINT-01`.

   Either way the session writes the tests first, watches them fail, and then makes them pass.

4. **Hand it off.** When the session says the card is ready, type:

   ```
   /workdeck:handoff
   ```

   It runs the check and then three gates, and stops at the first that fails: `card lint` (every card and log file is well formed), `card touched <id>` (no file changed that the card's `Touch` does not list) and `card tests <id>` (every test the card names exists). Then an agent that did not write the change reviews it against the card and [`cards/REVIEW.md`](cards/REVIEW.md). Then it writes the session log, commits, pushes the branch to your fork and opens the pull request against this repository. Handoff has not been run from a fork here: if `gh` asks which repository the pull request is for, choose this one, and if it opens it against your fork, that is a bug report.

5. **The pull request.** Its body holds the card, what changed, the tests, the review findings that were left open with the reason for each, and how far the session's context grew against the card's budget, as the session log measured it.

What is looked at, and by whom:

- **The reviewer** is an agent, run by handoff before the commit. It checks each `Acceptance` item and each test against the diff, each rule in `cards/REVIEW.md`, and anything changed outside the card. It finds; it does not approve.
- **CI** runs `make lint`, `make test`, `card lint`, the link check and the manifest validation, on macOS with bash 3.2 and on Ubuntu, and the suite again under mawk and gawk.
- **The maintainer** reads the card before the diff: is this the change the card says, and is the card the right change? Then the findings left open, then the tests, then the code. A file added to `Touch` during the work is not a fault. It is visible, and the question is whether the reason holds.

### Without Claude Code

Everything a skill does can be done by hand, and `card` needs only bash and git:

- `bin/card new Q-<yymmddHHMM> "<title>" --size XS` writes a card. Fill it in, and work on a branch named `card/<id>-<slug>`.
- `bin/card lint`, `bin/card touched <id>` and `bin/card tests <id>` are the gates. `bin/card done <id>` and `bin/card log-new <id> done` close the card; the log's token fields say `unknown`, which is the truth.
- Or skip the card: send a plain pull request that says what it changes and how you tested it. The maintainer may write the card for it.

What you cannot do without Claude Code is test a skill, a hook or an agent as a session runs it. Say so in the pull request, and say what you ran instead.

## How decisions are made

One person merges: the maintainer, [@AshwinSathian](https://github.com/AshwinSathian). The rule is that a change reaches the main branch through a pull request that the maintainer merges, and the merge is the approval. The history has earlier commits made straight on the main branch, and no branch rule enforces the rule yet. No skill merges, and the permission entries that `/workdeck:init` offers deny `gh pr merge`; they are not a sandbox, as [`SECURITY.md`](SECURITY.md) says.

Most of the code and the documents here are written by a coding agent, on the maintainer's instruction. So a decision is not trusted because of who made it. It is tested by an **adversarial review**: a second agent, which did not write the work and is told to assume it is wrong, attacks it, runs what can be run, and reports findings with their evidence. The writer answers each finding with a change or with a reason, in the open. For a scope or a design this happens before any code. For a card it is the reviewer in handoff. Some decisions the maintainer takes, and some are delegated to the session after such a review; the record says which.

Where a decision is recorded:

- **The rules for code**: [`cards/REVIEW.md`](cards/REVIEW.md). A change to a rule is a pull request like any other.
- **A design decision**: the design it belongs to, in `docs/`, with the reviews that tested it in `docs/development/` (`review-0.2.md`, `review-0.3.md`), finding by finding.
- **Something that went wrong, and what was decided about it**: [`docs/development/findings.md`](docs/development/findings.md).
- **Something left out on purpose**: [`docs/development/later.md`](docs/development/later.md).
- **A decision about one change**: the card, under `Notes`, and the pull request.

To argue against a decision, open an issue that names the record and says what it got wrong. A record is not edited to read better, but it is amended when it is shown to be wrong, and the amendment says so.
