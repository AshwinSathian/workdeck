# Evidence

What has been measured, where the numbers come from, and what has not been shown. Each item can be checked.

## Tests

`make test` runs more than 300 cases in about a minute. They cover every `card` command, every lint rule, every card state (with a local bare repository as the remote and a stub `gh`), the token parser against fixture transcripts, and each hook with fixture input. `make lint` is shellcheck with no findings. On macOS the suite runs under bash 3.2. CI repeats it on Ubuntu with `awk` as mawk and as gawk.

One case, `test_runner_reports_failure`, checks that the test runner itself reports a failing case and a case file that does not parse, so a broken assertion helper cannot make everything pass.

## A card through the whole loop, against the hosted repository

Card DOC-02 (add the license, size XS) was run by the maintainer with the plugin loaded: `/workdeck:next-card DOC-02`, then `/workdeck:handoff`. The result is [pull request 1](https://github.com/AshwinSathian/workdeck/pull/1) and the log `log/2026-10-06-DOC-02-1.md`.

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 53,055 |
| Largest context in the session (peak) | 79,037 |
| Growth | 25,982 |
| Budget for an XS card | 35,000 |

The session did not compact. What this run showed that no shell test can:

- Handoff ran the check, the three gates and the reviewer, wrote the log with figures taken from the transcript, committed, pushed the branch and opened the pull request with the card, the changes, the tests, the review and the token figures in its body.
- CI ran on the pull request and passed on macOS and Ubuntu before the merge.
- The scope gate failed on real work: the card needed `README.md` and `bin/card`, which it did not list, and both were added to its `Touch` list in the same pull request.
- The reviewer found nothing that had to be fixed and left five small notes, which are in the pull request body.

The baseline is 16,138 tokens higher than in the scratch run below, because this session had the maintainer's other plugins loaded as well. That difference is why a budget limits growth and not total size. The growth also includes a first attempt in the same session that the permission mode refused, so 25,982 overstates what the card alone needed. It is still three quarters of the XS budget for a card that adds a license file, which suggests the XS default is on the tight side once a session carries other plugins.

## Context growth with only this plugin loaded

Before that, the card in `examples/hello-deck/` was run through `/workdeck:next-card` and `/workdeck:handoff` in a scratch repository with only this plugin loaded:

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 36,917 |
| Largest context in the session (peak) | 40,334 |
| Growth | 3,417 |
| Budget for an XS card | 35,000 |

The session did not compact. This run is also what showed that the reviewer agent launches under its plugin name, and that the session-start hook passes the transcript path to later commands ([`development/findings.md`](development/findings.md), finding 10).

## A quick card in a new repository, installed from the marketplace

On 2026-10-06 the maintainer installed 0.1.1 with `/plugin marketplace add AshwinSathian/workdeck` in a new private repository holding one shell function and a `test.sh`. `/workdeck:init`, `/workdeck:quick` and `/workdeck:handoff` followed, in that order. The repository is private, so the figures below are from its session log and cannot be checked from outside.

| | Tokens |
|---|---|
| Context at the first turn (baseline) | 53,350 |
| Largest context in the session (peak) | 68,465 |
| Growth | 15,115 |
| Budget for an XS card | 35,000 |

The session did not compact. Its baseline is within 300 tokens of the DOC-02 session's, which had the maintainer's other plugins loaded. What the run showed:

- Init wrote `workdeck.conf`, `cards/REVIEW.md`, the pull request template, the permission entries, the project settings that turn the plugin on, and the CI workflow. The workflow downloaded `card` at `v0.1.1` and its `lint` job passed on the pull request.
- Handoff ran the check, the gates and the reviewer, and opened the pull request. With it open, `card list --fetch` printed `review` for the card. After the maintainer merged it and pulled, `card list` printed `done`.
- The reviewer left one nit and nothing to fix.

Two things went wrong, and both are in the card's log under Deviations. Quick wrote the `Touch` entries as bare lines, which are not items, so the scope gate did not match them until they were rewritten with `- ` ([`development/findings.md`](development/findings.md), finding 16). The `Tests` line also had to be reworded to match the name the test ended up with.

## Hand runs of the planner in a scratch repository

On 2026-10-11 the maintainer ran `/workdeck:init`, `/workdeck:plan` and `/workdeck:next-card` with `/workdeck:handoff`, each typed by hand in its own session, and `/workdeck:plan` a second time on the maintainer's default model, in a private scratch repository: `examples/hello-deck/` with a specification of four sections for its code, the permission entries and the protocol section as 0.1.3 wrote them, a lockfile, three `.snap` files and two files marked `linguist-generated`. Every session was started with `claude --plugin-dir <a checkout of the main branch> --setting-sources project`, so the plugin was the unreleased one and no user-level allow rule and no other plugin applied. The first four sessions were on `claude-sonnet-5-5`, with `--model sonnet`; the fifth was on `claude-opus-5-5`, the maintainer's default. The maintainer's rules file and two account connectors were still loaded, and are in every baseline. The repository is private, so the figures below are from its transcripts and cannot be checked from outside. Claude Code was 2.1.296.

One thing limits what these runs show: no prompt is recorded as such. A command below is said to have waited when the pasted terminal shows its prompt, or when the transcript has more than a second between the call and its result; one is said to have run at once when the result came within a second. A wait is a prompt for a local command. For `git pull`, `git push` and `gh` it may be the network.

### Init, on a repository that already had `workdeck.conf`

| | Tokens |
|---|---|
| Baseline | 33,239 |
| Peak | 45,318 |
| Growth | 12,079 |

This session was started without `--permission-mode` and ran in auto mode, so it raised no prompt. What each of the four steps offered:

- Permission entries: the six the settings file lacked, two `plan/*` entries under `allow` and four under `deny`. After the yes the file was the same as the template with the check command filled in.
- `touch_ignore`: `package-lock.json`, `*.snap` for the three snapshots and `gen/*` for the two generated files, one of which has a name git prints in quotes. All three were added and `card conf touch_ignore` printed them.
- Review rules: to copy `REVIEW.md`, which the repository did not have, and one rule taken from `CLAUDE.md`.
- The protocol section: the two lines 0.2 adds. The section had a code block with a line starting with `# ` in it; the block and the section after it were left as they were.

### Plan, under the permission entries init had just written

| | Tokens |
|---|---|
| Baseline | 34,203 |
| Peak | 48,631 |
| Growth | 14,428 |

The session was started with `--permission-mode default`. The maintainer left it once at the question of step 8 and resumed it with `claude --resume`; the answer was then a yes. The pull request body gives a growth of 12,821, taken before the session ended.

- It delegated the search to Explore, in the background, and waited for the answer. It launched `workdeck:plan-reviewer` and waited. The first run had four `should-fix` findings and two nits, and the session edited the outline for the four. It launched the reviewer a second time because the outline had changed. Neither run had a `must-fix`. The second run was on a changed outline, so the two do not show whether the reviewer agrees with itself.
- The specification's sections sit at heading level 3. The session proposed level 3 and `card plan new docs/spec.md GRT --level 3` took it. The outline has three rows, the second depending on the first, and one heading under `Not planned`.
- Waited: `git checkout main && git pull --ff-only; gh pr list --author @me --state open --json number,headRefName`; `git checkout -b plan/2610110046 && cat docs/spec.md && card list`; from Explore, a line of `ls` and `cat`; `cat >> cards/plan/grt.md <<'EOF'` with the rows; from the first reviewer, `ls -la bin 2>&1; cat cards/GREET-02*.md | head -40; git hash-object docs/spec.md`; a `python3` command that edited the outline; and after the yes, `git add`, `git commit` and `git push -u origin plan/2610110046 2>&1 | tail -3` as one command, then the body file, `gh pr create`, `rm -f` and `git status --porcelain` as one command.
- Ran at once: `git status --porcelain; card conf base; card conf cards_dir; git remote -v`; `git ls-files`, `card plan` and `ls` chained with `echo`; `date +%y%m%d%H%M`; `card plan new` chained with three `card conf`; and `git status --porcelain; git log --format=%B -n 3; card tokens`.
- From the `python3` command to the question of step 8 the session was in auto mode: the maintainer chose it at a prompt, most likely that command's. The second reviewer ran in that mode and could raise no prompt, so the run was not under the permission entries alone from start to end.
- The push was not refused, with a redirect and a pipe after the branch name.

### Plan again, on the maintainer's default model

| | Tokens |
|---|---|
| Baseline | 35,235 |
| Peak | 59,795 |
| Growth | 24,560 |

A second specification of four sections at heading level 2, planned on `claude-opus-5-5` with `--permission-mode default`. The session stayed in default mode from start to end and was not left before its pull request was open. The body gives a growth of 20,378.

- It delegated the search to Explore, in the background, and waited. The first reviewer run had one `must-fix`, three `should-fix` findings and five nits. The `must-fix` and two others turned on a reading of the specification, and the session asked the maintainer three questions before it revised the outline. The second run had no `must-fix`, two `should-fix` findings and two nits; none was fixed, and all four went to the maintainer in step 8 and into the body.
- Both launches of the reviewer were given more than the outline's path and the base branch: the first the choices made while writing, the second what had changed and what the maintainer had decided.
- Waited: `git checkout main && git pull --ff-only`; `gh pr list --author @me --state open --json number,headRefName`; `git ls-files`, `card plan` and `card conf cards_dir` chained with `ls "$(card conf cards_dir)/plan/"` and a `grep`; `git checkout -b plan/2610110136`; `cat >> cards/plan/list.md <<'EOF'` with the rows; `head`, `cp`, `rm` and `cat >>` as one command that rewrote them; `git add`, `git commit`, `git log -1` and `git push -u origin plan/2610110136 2>&1 | tail -3` as one command; the body file, `gh pr create`, `rm -f` and `git status --porcelain` as one command; and one line of `cat` from each of Explore and the two reviewer runs.
- Ran at once: `git status --porcelain` chained with `card conf base` and `git remote`; `date +%y%m%d%H%M`; `card list`; `card plan new` chained with `cat` and three `card conf`; and `git status --porcelain && card tokens && git log -8`.
- The push was not refused.

### Next-card and handoff, for two rows

GRT-01 has no dependency. GRT-02 depends on it, and was started after the pull request of GRT-01 was merged.

GRT-01:

| | Tokens |
|---|---|
| Baseline | 32,479 |
| Peak | 51,287 |
| Growth | 18,808 |

GRT-02:

| | Tokens |
|---|---|
| Baseline | 32,512 |
| Peak | 52,024 |
| Growth | 19,512 |

The session logs give 13,463 and 14,974: `card log-new` runs in step 6 of handoff, before the commit, the push and the pull request.

- In both sessions the card was written from the row, checked with `card lint` and `card plan check`, shown, and committed alone as `<id>: card as approved` after the yes. No code was written before it. In the first, `/workdeck:handoff` was typed before the yes, and the session refused and asked again. In the second, the maintainer asked for one more test before the yes; the session edited the card, ran both checks and asked again.
- The stop hook ran at the end of every turn, six in the first session and five in the second, and blocked none, the turn after the approval commit included.
- Both pull request bodies have the part "Changes to the card since it was approved", and in both it held `None`. No card was changed after its approval, so a part with a difference in it was not seen.
- The reviewer had no finding on either card, and neither report has a line that leaves a requirement out as met on the base branch.
- Waited in the first session: the update of the base branch, chained with `card list` and `card show GRT-01`; the Write of the card; `card lint; echo "--- exit $?"; card plan check GRT-01; echo "--- exit $?"`; `git checkout -b`, `git add` and `git commit` of the approval, as one command with a `cat` of `reference/implement.md`; the Write of the tests and of the code; `sh tests/greet.sh; echo "exit $?"`; the tests, the check and the two gates as one command; handoff's check and gates as one command ending in `ls .github`; the Edit of the log; and `card lint`, `git add -A`, `git commit` and the two commands that find the approval commit as one command.
- Waited in the second session: the update of the base branch chained with `card show GRT-02`; a `python3` command that filled in the card, chained with both checks; the Edit of the card; both checks chained with `sed -n`; the approval's `git checkout -b`, `git add` and `git commit`; a `python3` command that wrote the tests; `cat >> src/greet.sh` chained with the tests, the check and `card touched`; handoff's check and gates as one command; the log, `card lint`, `git add -A` and `git commit` as one command; `sed -i` on the log chained with an amend; and from the reviewer, `card show GRT-02; card conf cards_dir; git diff $(git merge-base HEAD main); git status --porcelain`.
- Ran at once in both: `gh pr list` chained with `git status --porcelain` and `card conf base`; `card plan start` chained with `echo ---` and `ls`; lines of `cat`; and `card done <id> && card log-new <id> done`.
- The push. In the first session it was written `git push -u origin card/GRT-01-name-check 2>&1 | tail -3 && cat > "$TMPDIR/pr-body.md" <<'EOF'`, followed by the body, `gh pr create`, `rm -f`, `git status --porcelain` and `card next`, as one command. It was denied with no prompt. Written alone, with the same redirect and pipe, it ran. In the second session the push came at the end of a command that began with `python3`, followed by `; ls .github 2>&1`, and ran. So a redirect and a pipe after the branch name do not make a deny rule match, and a push that leads a longer command can be denied. Which rule matched is not known: `git push -u origin card/* *`, `git push * -f *` on the `rm -f` further along, or `git push *:*` on a colon in the body.
- In the second session handoff amended its own commit before the push, to correct a sentence in the log.

### Faults found

None is fixed here. Each becomes a card or a quick card.

- `templates/settings-permissions.json`: Claude Code prints at every start that the deny rule `Bash(git push *:*)` mixes `*` with the `:*` prefix form and is matched as a literal prefix. By that message the rule refuses no push with a refspec. No session pushed with one, so that was not tried. Version 0.1.3 has the rule too.
- `skills/handoff/SKILL.md`, step 7, and `skills/plan/SKILL.md`, step 9: neither says that the push is its own command. A session chains it with what follows, and one such command was denied.
- `skills/plan/SKILL.md`, step 7: in both plan runs the second launch of the reviewer was given a summary of the first run's findings and what was done about them, and in the second run the first launch was given the session's own choices. The step says to launch it with the outline's path and the base branch.
- `skills/plan/SKILL.md`, step 9: the body of the first plan run does not hold every finding. It gives five findings of the first run as fixed, one of them half of another, and leaves out that run's nit on where the tests live.
- `skills/init/SKILL.md`, "A repository that is already set up": the four steps were asked as one question with four parts, not one after another. The closing message named `/workdeck:next-card` and `/workdeck:quick` and not `/workdeck:plan`, which step 10 asks for.
- `skills/init/SKILL.md`, the fourth of those steps: the section ends at the next line that starts with `# `, and the session took a `# ` line inside a code block for that end. Its question said that replacing the section would drop the block and leave its fence open, and offered "add the two bullets only" first, which the maintainer chose. The step says a yes replaces the whole section.
- `skills/handoff/SKILL.md`, steps 6 and 7: the growth in the session log and in the pull request body leaves out the commit, the push and the pull request, about 5,000 tokens in each of the two sessions.
- `skills/next-card/SKILL.md`, `skills/plan/SKILL.md`, `skills/handoff/SKILL.md` and `reference/implement.md`: nothing tells a session to run a `card` command alone or to edit with the Edit tool. Sessions chained `card` commands with `echo "... $?"` and `sed`, and wrote the outline, a card, tests, code and the log with `python3` and `cat >>`. Each of those waited. A chain of `card` commands with a plain `echo ---`, `ls` or `cat` did not.

### Not run

A second reviewer run on the same outline. A no in step 8 of plan, a pull request resumed in step 2, a revision that adds a row for new code, and a refusal by `card plan new`. Init on a repository that is up to date, on a new one, and after the check command changed. A card changed after its approval.

## What the repository's own logs do not show

WorkDeck 0.1 was built card by card: each card on its own branch, through `card lint`, `card touched` and `card tests`, with a session log. All the cards before DOC-02, and E-01 after it, were driven by hand inside one long agent session without the plugin loaded. Their logs record `unknown` for the token fields. One session's growth does not describe any single card, and writing it into each log would have been false. `card stats` says so itself: it prints how many sessions have no measurement.

Logs from sessions that run a card through the plugin carry real figures. DOC-02 is the first.

## Cost of the hooks

`make bench` measures the post-tool-use hook, which runs after every tool call. On an Apple silicon Mac, 50 runs per path:

| Path | Median | 95th percentile |
|---|---|---|
| Not a WorkDeck project | 2 ms | 2 ms |
| WorkDeck project, not on a card branch | 2 ms | 2 ms |
| Card branch, warning already given | 4 ms | 5 ms |
| Card branch, under budget, 2 MB transcript | 45 ms | 51 ms |
| Card branch, under budget, 20 MB transcript | 127 ms | 151 ms |

A project that does not use WorkDeck pays 2 ms per tool call for having the plugin enabled.

## What the gates catch, and what they miss

[`examples/hello-deck/README.md`](../examples/hello-deck/README.md) shows both gates failing on a real change and what resolves each.

The tests gate checks only that a name is present. Tried on sixteen test declarations in Go, Python, TypeScript and Rust, it was right on seven. It gave seven false failures: a name split across a `describe` block, a class, a module or a line break, or reworded by one small word. It passed two it should not have: a one-word line, and a name that appeared only in a comment. The table is in `development/findings.md`, finding 1, and each row is a test in `test/cases/33-tests.sh`.

## Not yet shown

- `/workdeck:init` in someone else's repository. The run above was the maintainer's.
- The `review` state for a card that is on the base branch. It was seen for a card that exists only on its branch: with [pull request 2](https://github.com/AshwinSathian/workdeck/pull/2) open, `card list --fetch` printed `review   E-01`.
- A handoff with every prompt recorded. The hand runs above were under exactly the permission entries init writes, with no user-level allow rule, but which commands prompted is taken from a pasted terminal and from waits in the transcripts.
- A card started from a row on the maintainer's default model. The two that were started were on Sonnet.
- A pull request body whose part "Changes to the card since it was approved" holds a difference.
- Any session that compacted.
