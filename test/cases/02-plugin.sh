#!/usr/bin/env bash
# shellcheck disable=SC2154
# Structural checks on the plugin files, with grep: no JSON tool is assumed.

test_hooks_json_names_existing_executable_scripts() {
  local f="$ROOT/hooks/hooks.json" s n=0
  [ -f "$f" ] || fail 'hooks/hooks.json is missing'
  for s in $(grep -o 'hooks/[a-z-]*\.sh' "$f"); do
    [ -x "$ROOT/$s" ] || fail "$s is named in hooks.json but is not an executable file"
    n=$((n + 1))
  done
  assert_eq 4 "$n" 'hook commands'
  for s in SessionStart PostToolUse Stop PreCompact; do
    grep -q "\"$s\"" "$f" || fail "hooks.json does not register $s"
  done
  assert_eq 4 "$(grep -c '"timeout": 10' "$f")" 'ten second timeouts'
  # An unquoted variable breaks on a path with a space and fails validate --strict.
  assert_eq 4 "$(grep -c '\\"${CLAUDE_PLUGIN_ROOT}\\"/hooks/' "$f")" 'quoted plugin root'
  grep -q '^  "hooks": {' "$f" || fail 'hooks.json has no top-level hooks key'
}

test_plugin_manifest_has_name_version_description_and_author() {
  local f="$ROOT/.claude-plugin/plugin.json" k
  [ -f "$f" ] || fail 'plugin.json is missing'
  for k in name version description author; do
    grep -q "\"$k\":" "$f" || fail "plugin.json has no $k"
  done
  grep -q '"name": "workdeck"' "$f" || fail 'the plugin is not named workdeck'
  grep -q '"name": "workdeck"' "$ROOT/.claude-plugin/marketplace.json" || fail 'the marketplace is not named workdeck'
}

# Runs only where Claude Code is installed. HOME is the test's temp directory,
# so nothing in the real ~/.claude is read or written.
test_plugin_validates_strictly() {
  if ! command -v claude >/dev/null 2>&1; then
    [ -z "${CI-}" ] || fail 'claude is required in CI'
    echo 'skip: claude not installed'
    return 0
  fi
  run claude plugin validate --strict "$ROOT"
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed for the marketplace'
  run claude plugin validate --strict "$ROOT/.claude-plugin/plugin.json"
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed for the plugin manifest'
  # Agents and skills are validated as component directories.
  local d
  for d in agents skills; do
    [ -d "$ROOT/$d" ] || continue
    run claude plugin validate --strict "$ROOT/$d"
    [ "$RC" -eq 0 ] || fail "claude plugin validate --strict failed for $d/"
  done
  RC=0
  [ "$RC" -eq 0 ] || fail 'claude plugin validate --strict failed'
}

test_template_conf_parses() {
  new_repo
  sed 's|<check>|make check VAR=1|; s|<base>|trunk|' "$ROOT/templates/workdeck.conf" > workdeck.conf
  card conf check; assert_rc 0; assert_eq 'make check VAR=1' "$OUT" check
  card conf base; assert_eq trunk "$OUT" base
  card conf budget.M; assert_eq 100000 "$OUT" 'default budget'
  # Unfilled, it must fail loudly, not run a placeholder.
  cp "$ROOT/templates/workdeck.conf" workdeck.conf
  card conf base; assert_rc 2
}

test_claude_md_section_is_short() {
  local f="$ROOT/templates/claude-md-section.md" n
  n=$(awk 'END { print NR }' "$f")
  [ "$n" -le 25 ] || fail "the CLAUDE.md section is $n lines; the spec says about 20"
  grep -q '^## WorkDeck session protocol$' "$f" || fail 'section heading missing'
  grep -q '/workdeck:handoff' "$f" || fail 'the section does not point at handoff'
}

# Design 0.2, section 10.3, last paragraph: the two lines the section gains.
test_claude_md_section_names_plan_branches_and_the_card_for_a_row() {
  local f="$ROOT/templates/claude-md-section.md"
  # Each line whole, and where it stands: after the line for the card's branch.
  # The second names the approval commit, which the line "Do not commit" below it would forbid.
  assert_eq '- A `plan/*` branch changes only outlines, the files in `cards/plan/`. `/workdeck:plan` commits, pushes and opens its pull request itself.' "$(sed -n 7p "$f")" 'line 7'
  assert_eq "- For a row of an outline, \`/workdeck:next-card\` writes the card and waits for a yes before any code, then commits that card alone as \`<id>: card as approved\`: the one commit on a card's branch before handoff." "$(sed -n 8p "$f")" 'line 8'
  # The rest of the section is what it was in 0.1.
  assert_eq '442516408 1364' "$(sed 7,8d "$f" | cksum)" 'the section without the two lines'
}

test_reviewer_agent_is_read_only() {
  local f="$ROOT/agents/reviewer.md"
  assert_eq 'name: reviewer' "$(sed -n 2p "$f")" 'agent name'
  assert_eq 'tools: Read, Grep, Glob, Bash' "$(grep '^tools:' "$f")" tools
  grep -q 'must-fix' "$f" || fail 'no must-fix severity in the reviewer'
  # Plugin agents ignore these fields; listing one would suggest it works.
  grep -Eq '^(hooks|mcpServers|permissionMode):' "$f" && fail 'field ignored for plugin agents'
  return 0
}

# Design 0.2, section 12.2: the review of a card body that next-card wrote
# from a row, by an agent that did not write it. The step is held sentence by
# sentence: the second review of P-15 changed 14 of them and no test saw it.
test_reviewer_checks_a_planned_card_against_its_specification_headings() {
  local f="$ROOT/agents/reviewer.md" s want='' line
  s=$(awk '/^## / { on = $0 == "## Procedure" } on && /^5\. /' "$f")
  while IFS= read -r line; do
    assert_contains "$s" "$line"
    want="$want $line"
  done <<'SENTENCES'
When a `Read` item of the card has a comment that starts with `(row `, the item is a specification and the comment names headings in it, as `(row <id>: <heading>; <heading>)`: list each requirement under those headings that no `Acceptance` item covers and no `Out of scope` item excludes.
A requirement is a sentence, list item or table row that says what the software must do.
Each is a `should-fix` finding.
Give the specification's path and the line of the requirement, and as the failure what is then not built.
These findings are about the card, not work beyond it.
Leave out a requirement that the code on the base branch already meets, and say in one line where: usually a card this one depends on built it.
A name in the comment that matches no heading of the specification, compared by letters and digits only with case ignored, is a `should-fix` finding too; a heading can itself hold `; `, so match the comment against the specification's headings before you split it.
A comment that names no heading, `(row <id>)`, leaves nothing to check: say so in one line.
For a card with no such item, skip this step.
SENTENCES
  # Nothing before, between or after them.
  assert_eq "5.$want" "$s" 'step 5'
  # It is the last of five, and the rest of the agent is what it was in 0.1.
  assert_eq '1. 2. 3. 4. 5. ' "$(awk '/^## / { on = $0 == "## Procedure" } on && /^[0-9]+\. / { printf "%s ", $1 }' "$f")" 'steps of the procedure'
  assert_eq 1 "$(grep -c '^5\. ' "$f")" 'lines that start with 5.'
  assert_eq '156200674 2751' "$(grep -v '^5\. ' "$f" | cksum)" 'the reviewer without the step'
}

PLAN_REVIEWER="$ROOT/agents/plan-reviewer.md"

# plan_reviewer_step <n>: the text of one numbered step of the procedure.
plan_reviewer_step() {
  awk -v n="$1." '/^[0-9]\. / { on = $1 == n } /^## / { on = 0 } on' "$PLAN_REVIEWER"
}

test_plan_reviewer_agent_is_read_only() {
  local f="$PLAN_REVIEWER"
  assert_eq 'name: plan-reviewer' "$(sed -n 2p "$f")" 'agent name'
  assert_eq 'tools: Read, Grep, Glob, Bash' "$(grep '^tools:' "$f")" tools
  # No field beyond these: one that plugin agents ignore would suggest it works,
  # and one such as background changes how the agent runs.
  assert_eq 'name description tools ' "$(awk '/^---$/ { n++; next } n == 1 { sub(/:.*/, ""); printf "%s ", $0 }' "$f")" 'front matter fields'
  # The description is in every session's context: one sentence, and short.
  assert_eq 1 "$(grep '^description: ' "$f" | grep -o '\. \|\.$' | grep -c .)" 'sentences in the description'
  [ "$(grep '^description: ' "$f" | wc -c)" -le 200 ] || fail 'the description is longer than 200 characters'
  grep -q 'do not edit, create or delete files' "$f" || fail 'the plan reviewer is not told to change nothing'
  grep -q 'do not commit, stash, check out, reset or push' "$f" || fail 'the plan reviewer is not told to leave git alone'
  # Bash is the one tool of the four that can write.
  grep -q 'never to change the repository' "$f" || fail 'Bash is not limited to reading'
}

test_plan_reviewer_is_told_to_assume_the_outline_is_wrong() {
  grep -q 'You did not write it\.' "$PLAN_REVIEWER" || fail 'the plan reviewer is not told it did not write the outline'
  grep -q 'Assume the outline is wrong' "$PLAN_REVIEWER" || fail 'the plan reviewer is not told to assume the outline is wrong'
}

test_plan_reviewer_reads_the_outline_from_the_working_tree() {
  local s
  grep -q "You are given the outline's path and a base branch" "$PLAN_REVIEWER" || fail 'the plan reviewer does not say what it is given'
  # The five steps of design section 12.1; the first is the reading step.
  assert_eq '1. 2. 3. 4. 5. ' "$(grep -o '^[0-9]\. ' "$PLAN_REVIEWER" | tr -d '\n')" 'steps of the procedure'
  s=$(plan_reviewer_step 1)
  assert_contains "$s" 'from the working tree'
  assert_contains "$s" 'not committed'
  assert_contains "$s" 'specification'
  s=$(plan_reviewer_step 2)
  assert_contains "$s" 'A requirement with no `does` line is a finding'
  assert_contains "$s" 'two rows both claim'
}

test_plan_reviewer_uses_the_severities_of_the_reviewer() {
  local s form='/^```$/ { on = !on; next } on { print $1 }'
  for s in must-fix should-fix nit; do
    grep -q "^- \`$s\`: " "$PLAN_REVIEWER" || fail "the plan reviewer does not define $s"
  done
  assert_eq "$(awk "$form" "$ROOT/agents/reviewer.md")" "$(awk "$form" "$PLAN_REVIEWER")" 'severities of the output form'
  grep -q 'the outline.s line and a failure scenario' "$PLAN_REVIEWER" || fail 'a finding does not need a line and a failure scenario'
  grep -q '`must-fix: none`' "$PLAN_REVIEWER" || fail 'no line for a category with no findings'
  # The closing lines are what tell "read and found nothing" from "not read".
  grep -q 'print nothing after them' "$PLAN_REVIEWER" || fail 'the report does not end at its closing lines'
  for s in 'searched:' 'no spec item:' 'outside the level:'; do
    grep -q "\`$s\`" "$PLAN_REVIEWER" || fail "no closing line '$s'"
  done
}

test_plan_reviewer_looks_for_joined_does_lines_and_lines_about_tests() {
  local s
  s=$(plan_reviewer_step 3)
  assert_contains "$s" 'joins two statements'
  assert_contains "$s" 'only says that tests exist'
  assert_contains "$s" 'Neither is a `must-fix` finding by itself'
  # "Neither" refers to the two bullets before it.
  assert_contains "$(printf '%s\n' "$s" | awk '/Neither is a/ { print prev } { prev = $0 }')" 'only says that tests exist'
  grep '^- `must-fix`: ' "$PLAN_REVIEWER" | grep -q '`does` line' && fail 'the must-fix definition names a does line'
  # One example of each, as the spike's reviewer raised neither.
  assert_eq 2 "$(printf '%s\n' "$s" | grep -c 'For example')" 'examples in step 3'
}

test_plan_reviewer_looks_for_a_missing_not_line_between_rows_of_one_heading() {
  local s
  s=$(plan_reviewer_step 4)
  assert_contains "$s" 'two rows cite one heading'
  assert_contains "$s" '`not` line'
  assert_contains "$s" 'what the other owns'
}

test_plan_reviewer_reads_what_lies_outside_the_level_of_the_outline() {
  local s
  s=$(plan_reviewer_step 5)
  assert_contains "$s" 'Not planned'
  assert_contains "$s" 'no `spec` item'
  assert_contains "$s" "under no heading at the outline's level"
  assert_contains "$s" 'work that no row does'
}

test_plan_reviewer_gives_paths_relative_to_the_repository() {
  grep -q 'Every path you print is relative to the repository' "$PLAN_REVIEWER" || fail 'the plan reviewer is not told to print relative paths'
  # The example findings show one.
  awk '/^```$/ { on = !on; next } on && $2 !~ /^cards\/plan\/[a-z0-9]*\.md:[0-9][0-9]*$/ { bad = 1 } END { exit bad }' "$PLAN_REVIEWER" || fail 'an example finding has no relative path'
}

test_templates_are_complete() {
  local f
  for f in REVIEW.md pull_request_template.md claude-md-section.md workdeck.conf workdeck.yml settings-permissions.json; do
    [ -s "$ROOT/templates/$f" ] || fail "templates/$f is missing or empty"
  done
  # The plugin ships no project rules: the REVIEW template has headings only.
  ! grep -q -v -E '^(#|<!--|$)' "$ROOT/templates/REVIEW.md" || fail 'templates/REVIEW.md carries rules'
}

# The allow rule for pushing card branches is a prefix match, so the deny
# list must close the refspec forms that would land a card branch elsewhere.
# A rule for "has a colon" would end in `:*`, which Claude Code reads as the
# prefix form, so there is one rule for each character a destination starts with.
test_permission_template_denies_refspec_pushes() {
  local f="$ROOT/templates/settings-permissions.json" deny r c
  deny=$(awk '/"deny"/ { on = 1 } on' "$f")
  for r in 'Bash(git push origin card/* *)' 'Bash(git push -u origin card/* *)'; do
    assert_contains "$deny" "\"$r\""
  done
  for c in a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 _; do
    assert_contains "$deny" "\"Bash(git push *:$c*)\""
  done
  # Six more, for the ways a shell spells the same destination: a quote of
  # either kind, a variable, a backslash, a command substitution and a brace.
  # They are read here as the file has them, before JSON is decoded. The rule
  # for a backslash has eight in the file, four once decoded: with four in the
  # file Claude Code 2.1.296 let `card/x:\main` through, and with eight it
  # refused it.
  while IFS= read -r c; do
    grep -q -F -- "\"Bash(git push *:$c*)\"" "$f" || fail "no deny rule for a destination written with $c first"
  done <<'CHARS'
\"
'
$
\\\\\\\\
`
{
CHARS
  assert_eq 69 "$(rules deny | grep -c '^git push \*:')" 'deny rules for a refspec'
}

# A rule that ends in `:*` is the prefix form. With another * in it, Claude
# Code 2.1.296 says at every start that it "is matched as a literal prefix",
# asterisk included, so it refuses nothing.
test_permission_template_has_no_rule_that_mixes_a_wildcard_with_the_prefix_form() {
  local r
  for r in allow deny; do
    rules "$r" | grep -n -E '\*.*:\*$' && fail "a rule of $r mixes * with a trailing :*"
  done
  return 0
}

test_permission_template_does_not_pre_approve_a_push_with_a_refspec() {
  local c
  while IFS= read -r c; do
    matches deny "$c" || fail "not denied: $c"
  done <<'COMMANDS'
git push origin card/A-1-x:main
git push -u origin card/A-1-x:main
git push origin plan/2610091200:main
git push -u origin plan/2610091200:main
git push origin card/A-1-x:refs/heads/main
git push origin card/A-1-x:Develop
git push origin card/A-1-x:0.2
git push origin card/A-1-x:_x
git push origin card/A-1-x:"main"
git push origin card/A-1-x:'main'
git push origin card/A-1-x:$BASE
git push origin card/A-1-x:${BASE}
git push origin card/A-1-x:`echo main`
git push origin card/A-1-x:{main,tmp}
git push origin plan/2610091200:"main"
COMMANDS
  # A destination written with a backslash first has a rule too, held by text
  # in test_permission_template_denies_refspec_pushes: matches reads the rule
  # before JSON is decoded, and cannot say what Claude Code makes of it.
}

# rules <allow|deny>: the Bash(...) patterns of one list, one per line.
rules() {
  awk -v want="$1" '
    /"allow"/ { cur = "allow" } /"deny"/ { cur = "deny" }
    cur == want && match($0, /"Bash\(.*\)"/) { print substr($0, RSTART + 6, RLENGTH - 8) }' "$ROOT/templates/settings-permissions.json"
}
# matches <allow|deny> <command>: does any rule of the list match the whole
# command, with * standing for any text? (Claude Code also lets a trailing
# " *" match the bare command, but only when it is the rule's only wildcard,
# so the "card/* *" and "plan/* *" deny rules do not match the plain push;
# none of these cases depends on it.) A rule that ends in `:*` is not a shell
# pattern: it is the prefix form, and what is before the suffix is literal, an
# asterisk included. A rule is read as the file has it, before JSON is decoded.
matches() {
  local pat
  while IFS= read -r pat; do
    case $pat in
      *':*') case $2 in "${pat%:\*}" | "${pat%:\*} "*) return 0 ;; esac ;;
      *)
        # shellcheck disable=SC2254
        case $2 in $pat) return 0 ;; esac
        ;;
    esac
  done <<RULES
$(rules "$1")
RULES
  return 1
}

test_permission_template_does_not_deny_the_handoff_push() {
  local c
  for c in 'git push -u origin card/AUTH-03-token-refresh' 'git push origin card/Q-2610061200' 'git push -u origin card/X-1-fix-foo' 'git push -u origin card/X-2-add-d'; do
    matches deny "$c" && fail "denied: $c"
    matches allow "$c" || fail "not allowed: $c"
  done
  matches deny 'gh pr create --base main --title x --body-file body.md' && fail 'gh pr create is denied'
  return 0
}

# Design 0.2, section 10.3, step 1: the plan skill pushes a plan/* branch, and
# the deny list closes the second refspec as it does for card/* (finding 9).
test_permission_template_allows_the_plan_branch_push() {
  local c
  for c in 'git push -u origin plan/2610091200' 'git push origin plan/2610091200'; do
    matches deny "$c" && fail "denied: $c"
    matches allow "$c" || fail "not allowed: $c"
  done
  # The whole list of push rules, so nothing wider came with them. The approval
  # commit is prompted: no rule for git add or git commit, in either spelling.
  assert_eq 'git push -u origin card/*
git push origin card/*
git push -u origin plan/*
git push origin plan/*' "$(rules allow | grep '^git push')" 'the allow rules for a push'
  rules allow | grep -q -E '^git (add|commit)' && fail 'an allow rule for git add or git commit'
  # rules reads only Bash(...) entries; a bare "Bash" allows every command.
  grep -q -E '^ *"Bash",?$' "$ROOT/templates/settings-permissions.json" && fail 'a bare Bash entry'
  return 0
}

test_permission_template_denies_a_plan_branch_push_with_a_further_argument() {
  local c
  for c in 'git push origin plan/* *' 'git push -u origin plan/* *'; do
    rules deny | grep -qxF "$c" || fail "no deny rule: $c"
  done
  for c in 'git push origin plan/2610091200 main' 'git push -u origin plan/2610091200 main' 'git push origin plan/2610091200:main'; do
    matches deny "$c" || fail "not denied: $c"
  done
}

test_permission_template_denies_known_bad_pushes() {
  local c
  while IFS= read -r c; do
    matches deny "$c" || fail "not denied: $c"
  done <<'COMMANDS'
git push --force origin card/A-1-x
git push -f origin card/A-1-x
git push origin card/A-1-x --force
git push origin card/A-1-x -f
git push origin main -f
git push origin card/A-1-x:main
git push origin card/A-1-x main
git push -u origin card/A-1-x main
git push origin +card/A-1-x
git push origin --delete card/A-1-x
git push --delete origin card/A-1-x
git push -d origin card/A-1-x
git push origin -d card/A-1-x
git push origin main --delete
git push origin main -d
git reset --hard HEAD~1
git branch -D card/A-1-x
gh pr merge 42
COMMANDS
}

test_permission_template_allows_what_next_card_runs() {
  local c
  for c in 'gh pr list --author @me --state open --json number,headRefName,reviewDecision' 'gh pr view 12 --comments' 'git branch --list card/A-1*' 'card status --fetch' 'date +%y%m%d%H%M'; do
    matches allow "$c" || fail "not allowed: $c"
    matches deny "$c" && fail "denied: $c"
  done
  return 0
}

test_repository_has_the_files_a_stranger_looks_for() {
  local f
  for f in .gitattributes .gitignore .editorconfig SECURITY.md CHANGELOG.md CONTRIBUTING.md Makefile SUPPORT.md CODE_OF_CONDUCT.md LICENSE docs/README.md; do
    [ -s "$ROOT/$f" ] || fail "$f is missing"
  done
  grep -q 'eol=lf' "$ROOT/.gitattributes" || fail '.gitattributes does not pin LF; card rejects CRLF'
  grep -q '^test:' "$ROOT/Makefile" || fail 'Makefile has no test target'
  grep -q '^lint:' "$ROOT/Makefile" || fail 'Makefile has no lint target'
  grep -q "$("$BASH" "$CARD" version | sed 's/^card //')" "$ROOT/CHANGELOG.md" || fail 'CHANGELOG has no entry for this version'
}

# The tag v0.1.2 holds the former name. The entry is what tells a user of that
# tag why its card stops and what to change.
test_changelog_says_what_0_1_3_renames() {
  local e
  e=$(awk '/^## \[/ { on = index($0, "[0.1.3]") > 0 } on' "$ROOT/CHANGELOG.md")
  printf '%s\n' "$e" | grep -q '^## \[0\.1\.3\] - [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$' || fail 'CHANGELOG has no dated entry for 0.1.3'
  assert_contains "$e" 'The code of 0.1.2'
  assert_contains "$e" 'former name'
  assert_contains "$e" 'CI workflow'
  assert_contains "$e" 'WorkDeck'
  assert_contains "$e" '`workdeck.conf`'
  assert_contains "$e" '`/workdeck:*`'
  assert_contains "$e" '`v0.1.2`'
  assert_contains "$e" 'exits 2'
  assert_contains "$e" '`v0.1.3`'
  grep -q '^\[0\.1\.3\]: .*/releases/tag/v0\.1\.3$' "$ROOT/CHANGELOG.md" || fail 'CHANGELOG has no link for 0.1.3'
}

# Design 0.2, section 21, item 11: the version waits for the trial. Until then
# the planner's entry has no version and no date, and the manifest stays as it is.
test_changelog_has_an_unreleased_entry_for_the_planner() {
  local e
  [ "$(awk '/^## \[/ { print; exit }' "$ROOT/CHANGELOG.md")" = '## [Unreleased]' ] || fail 'the first entry of CHANGELOG is not headed [Unreleased]'
  e=$(awk '/^## \[/ { on = index($0, "[Unreleased]") > 0 } on' "$ROOT/CHANGELOG.md")
  assert_contains "$e" '### Added'
  assert_contains "$e" '### Changed'
  assert_contains "$e" '`/workdeck:plan'
  assert_contains "$e" '`workdeck:plan-reviewer`'
  assert_contains "$e" '`card plan`'
  assert_contains "$e" '`card plan new <spec path> <PREFIX> [--level N]`'
  assert_contains "$e" '`card plan accept <PREFIX>`'
  assert_contains "$e" '`card plan start <id>`'
  assert_contains "$e" '`card plan check <id>`'
  # One phrase for each item under Changed.
  assert_contains "$e" '`card show` include rows'
  assert_contains "$e" '`/workdeck:next-card` writes the card when it starts a row'
  assert_contains "$e" '`/workdeck:handoff` adds to the pull request body'
  assert_contains "$e" '`/workdeck:init` no longer stops'
  assert_contains "$e" 'The reviewer agent lists the requirements'
  assert_contains "$e" 'The end-of-turn hook does not count commits'
  assert_contains "$e" 'allows the push of a `plan/*` branch'
  assert_contains "$e" '`/workdeck:init` writes a cards or log directory that has another name'
  assert_contains "$e" '`card new` refuses a card path that is a symbolic link'
  assert_contains "$e" '`workdeck.conf` stays at `version = 1`'
  assert_contains "$e" 'To plan in a repository set up with 0.1, run `/workdeck:init` again'
  assert_contains "$e" 'It receives them when the version changes'
  assert_contains "$e" '### Upgrading from 0.1'
  assert_contains "$e" 'card and session log formats do not change'
  if printf '%s\n' "$e" | grep -q '0\.2\.[0-9]'; then fail 'the unreleased entry names a release of 0.2'; fi
  if printf '%s\n' "$e" | grep -q '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'; then fail 'the unreleased entry has a date'; fi
  if grep -qi '^## \[0\.2\|^\[0\.2\|^\[Unreleased\]:' "$ROOT/CHANGELOG.md"; then fail 'CHANGELOG names a release of 0.2'; fi
  assert_eq 'card 0.1.3' "$("$BASH" "$CARD" version)"
  grep -q '"version": "0.1.3"' "$ROOT/.claude-plugin/plugin.json" || fail 'plugin.json is not at 0.1.3'
}

test_plugin_manifest_names_its_repository() {
  local f="$ROOT/.claude-plugin/plugin.json" k
  for k in displayName homepage repository; do
    grep -q "\"$k\":" "$f" || fail "plugin.json has no $k"
  done
  grep -q "$(sed -n 's/^  "repository": "\(.*\)",$/\1/p' "$f")" "$CARD" || fail 'the URL in bin/card differs from plugin.json'
}

test_plugin_manifest_names_the_license() {
  local id
  id=$(sed -n 's/^  "license": "\([^"]*\)",\{0,1\}$/\1/p' "$ROOT/.claude-plugin/plugin.json")
  assert_eq MIT "$id" 'license in plugin.json'
  assert_eq 'MIT License' "$(sed -n 1p "$ROOT/LICENSE")" 'first line of LICENSE'
  grep -q '^Copyright (c) [0-9][0-9][0-9][0-9] Ashwin Sathian$' "$ROOT/LICENSE" || fail 'LICENSE has no copyright line with a year'
  grep -q 'THE SOFTWARE IS PROVIDED "AS IS"' "$ROOT/LICENSE" || fail 'LICENSE is not the whole MIT text'
  sed -n 1,10p "$CARD" | grep -qx "# SPDX-License-Identifier: $id" || fail 'bin/card has no SPDX line in its header'
  grep -q "license-$id-" "$ROOT/README.md" || fail 'README has no license badge'
  grep -q "^\[$id\](LICENSE)" "$ROOT/README.md" || fail 'README does not link the license'
}

test_example_deck_lints_and_lists() {
  mkdir "$T/ex"
  cp -R "$ROOT/examples/hello-deck/." "$T/ex/" || fail 'no example deck'
  cd "$T/ex" || exit 1
  git init -q . && git symbolic-ref HEAD refs/heads/main && git add -A && git commit -q -m example
  card lint; assert_rc 0
  card list
  assert_contains "$OUT" 'done     GREET-01'
  assert_contains "$OUT" 'ready    GREET-02'
  card stats
  assert_contains "$OUT" '3417'
  # The output shown in the example README is real.
  card list
  assert_contains "$(cat README.md)" "$OUT"
}

test_docs_have_one_design_file_and_a_development_folder() {
  local f
  for f in docs/design.md docs/evidence.md docs/development/README.md docs/development/plan-0.1.md docs/development/findings.md docs/development/later.md; do
    [ -s "$ROOT/$f" ] || fail "$f is missing"
  done
  # No tracked file still points at the old locations.
  cd "$ROOT" || exit 1
  ! git grep -n -E 'docs/(specs|plans)/|docs/(findings|later)\.md' -- . ':!test/cases/02-plugin.sh' || fail 'a file names an old docs path'
}

test_development_records_for_0_2_are_listed_and_exist() {
  local f idx="$ROOT/docs/development/README.md"
  for f in scope-0.2.md review-0.2.md ../design-0.2.md; do
    [ -s "$ROOT/docs/development/$f" ] || fail "docs/development/$f is missing"
    grep -q "^| \[\`$f\`\]($f) |" "$idx" || fail "docs/development/README.md has no row for $f"
  done
}

test_scope_note_for_0_3_is_listed_and_exists() {
  local d="$ROOT/docs/development" f
  for f in scope-0.3.md review-0.3.md; do
    [ -s "$d/$f" ] || fail "docs/development/$f is missing"
    grep -qF "| [\`$f\`]($f) |" "$d/README.md" || fail "docs/development/README.md has no row for $f"
  done
  # The note says it is decided, and its last section is the six decisions,
  # numbered in order. The record has a part for them. These hold strings and
  # not their sense: a note that says the opposite in other words passes.
  grep -q '^Status: decided on ' "$d/scope-0.3.md" || fail 'the status line does not say the note is decided'
  assert_eq '1 2 3 4 5 6' "$(awk '/^## /{ on = (index($0, "## Decided on ") == 1); if (!on) n = "" } on && /^[0-9]+\. \*\*/ { n = n (n == "" ? "" : " ") ($1 + 0) } END { print n }' "$d/scope-0.3.md")" 'the decisions in the last section of the note'
  grep -q '^### The six decisions$' "$d/review-0.3.md" || fail 'the review record has no part for the six decisions'
}

# The three records of 0.3. Like the test above, this holds the form of the
# design and of the record, and not their sense.
test_development_records_for_0_3_are_listed_and_exist() {
  local d="$ROOT/docs/development" des="$ROOT/docs/design-0.3.md" f n
  for f in scope-0.3.md review-0.3.md ../design-0.3.md; do
    [ -s "$d/$f" ] || fail "docs/development/$f is missing"
    grep -qF "| [\`$f\`]($f) |" "$d/README.md" || fail "docs/development/README.md has no row for $f"
  done
  # The design adds to the two before it and follows the scope note.
  for f in '(design.md)' '(design-0.2.md)' '(development/scope-0.3.md)'; do
    grep -qF "$f" "$des" || fail "the design does not link $f"
  done
  # Numbered like docs/design.md: second-level headings 1, 2, 3 and so on,
  # with none left out and at least as many as a design needs.
  n=$(awk '/^## / && $2 != ++n "." { bad = 1 } END { print (bad ? "bad" : n + 0) }' "$des")
  case $n in bad | ?) fail "the design's sections are not numbered in order from 1 (got '$n')" ;; esac
  grep -q '^Status: decided on ' "$des" || fail 'the status line of the design does not say it is decided'
  # Its open points are decided: eight rows, numbered in order, each with what
  # the draft had and what was decided, here and in the review record.
  for f in "$des" "$d/review-0.3.md"; do
    assert_eq '1 2 3 4 5 6 7 8' "$(awk -F ' *[|] *' '
      /^#/ { on = ($0 ~ /^##+ (22\. Decisions on the open points|The eight decisions)$/); next }
      on && $2 ~ /^[0-9]+\. / && $3 != "" && $4 != "" { n = n (n == "" ? "" : " ") ($2 + 0) }
      END { print n }' "$f")" "the eight decisions in ${f##*/}"
  done
  # The record has the passes on the design, and no file says it is not written.
  ! grep -n 'The design is not written yet\|is not started' "$d/review-0.3.md" "$d/scope-0.3.md" || fail 'a record still says the design is not written'
  assert_eq 2 "$(grep -c '^## [A-Z][a-z]* pass, 2026-[0-9-]*: the \(design\|decisions\)' "$d/review-0.3.md")" 'passes of the review record on the design'
  # Every claim about Claude Code or git has a page and says how it is known:
  # each line of the table after its two heading lines is a numbered row, in
  # order, whose status starts with one of three words, and a claim with no
  # page is unverified.
  n=$(awk -F ' *[|] *' '
    /^## / { on = ($0 ~ /behavior this design relies on$/); next }
    on && /^[|]/ && ++line > 2 {
      rows++
      if ($2 != rows || $3 == "" || $4 == "" || $5 !~ /^(read|run|unverified)([ .:,]|$)/) bad++
      else if ($4 == "none" && $5 !~ /^unverified/) bad++
    }
    END { print rows + 0, bad + 0 }' "$des")
  case $n in ? | ?' '*) fail "the behavior table of the design has fewer than ten rows: $n" ;; *' 0') ;; *) fail "rows of the behavior table out of order, or with no page or no status: $n" ;; esac
}

# The spike of design-0.2 section 21, item 1. The record is finished when no
# part of it still says it was not run.
test_spike_record_for_0_2_is_listed_and_answers_its_questions() {
  local d="$ROOT/docs/development" rec f h n
  rec="$d/spike-0.2.md"
  [ -s "$rec" ] || fail 'docs/development/spike-0.2.md is missing'
  grep -q '^| \[`spike-0.2.md`\](spike-0.2.md) |' "$d/README.md" || fail 'docs/development/README.md has no row for spike-0.2.md'
  for f in plan-skill.md plan-reviewer.md outline-design.md outline-sample.md; do
    [ -s "$d/spike-0.2/$f" ] || fail "docs/development/spike-0.2/$f is missing"
  done
  for h in 'What was run' 'Outline of docs/design.md' 'Outline of the Spec Kit sample' 'A card from one row' 'Heading levels' 'Growth of the plan runs' 'Claude Code behavior' 'Outline format'; do
    grep -q "^## $h\$" "$rec" || fail "the record has no section '$h'"
  done
  ! grep -n 'Not run yet' "$rec" || fail 'a part of the record was not run'
  # Each fault names the check of design section 11.1 that catches it, or none.
  assert_eq 2 "$(grep -c '^| Fault | Caught by |$' "$rec")" 'tables of faults with the check that catches each, one per outline'
  assert_eq 2 "$(grep -c '^growth [0-9][0-9]*$' "$rec")" 'growth figures as card tokens prints them'
  grep -Eq '^The outline format of design section 5 is (confirmed|changed)' "$rec" || fail 'the record does not say whether the outline format is confirmed'
  for n in 14 15 16 17; do
    grep -q "^| $n | .*[0-9]\.[0-9][0-9]*\.[0-9]" "$rec" || fail "the record has no result with a Claude Code version for row $n"
    grep "^| $n | " "$ROOT/docs/design-0.2.md" | grep -q 'spike-0\.2\.md' || fail "design section 19, row $n, does not give the spike's result"
  done
}

# The spike ends with a list of changes for the deck. Each is answered in the
# review record, accepted or turned down.
test_review_record_answers_what_the_spike_asked_for() {
  local d="$ROOT/docs/development" n
  grep -q '^## Fifth pass' "$d/review-0.2.md" || fail 'the review record has no fifth pass'
  grep -q 'fifth pass of \[`review-0.2.md`\](review-0.2.md)' "$d/spike-0.2.md" || fail 'the spike record does not point at the fifth pass'
  # Rows of the first table of that pass only.
  n=$(awk '/^## Fifth pass/ { on = 1 } on && /^Found by the attack/ { exit } on && /^\| / && $0 !~ /^\| (The spike asked for|---)/ { n++ } END { print n + 0 }' "$d/review-0.2.md")
  [ "$n" -eq 11 ] || fail "the fifth pass answers $n of the spike's requests"
}

test_nothing_claims_evals_that_do_not_exist() {
  cd "$ROOT" || exit 1
  [ -d evals ] && return 0
  ! git grep -n -i 'ships three plugin eval' -- docs/design.md || fail 'the design says eval cases ship'
  ! ls cards/DOC-03-* 2>/dev/null || fail 'the eval card is still in the deck'
}

test_reference_names_every_card_command() {
  local c
  for c in $("$BASH" "$CARD" help | awk '/^  [a-z]/ && $1 != "help," { print $1 }'); do
    grep -q "^  $c " "$ROOT/docs/reference.md" || fail "docs/reference.md does not list card $c"
  done
  for c in version check base cards_dir log_dir budget.XS touch_ignore status_max_chars reviewer; do
    grep -q "\`$c\`" "$ROOT/docs/reference.md" || fail "docs/reference.md does not document the $c setting"
  done
}

# doc_section <file> <heading>: the text of one second-level section. A line
# inside a code fence is not a heading: a card and an outline have their own.
# It knows only a fence of backticks at the start of a line, which is every
# fence README.md and docs/reference.md have.
doc_section() {
  awk -v h="## $2" '/^```/ { fence = !fence } !fence && /^## / { on = $0 == h } on' "$ROOT/$1"
}
readme_section() { doc_section README.md "$1"; }

# Design 0.2, section 16, last item: the warning stands beside the plan skill.
test_readme_names_the_plan_skill_and_warns_about_an_untrusted_specification() {
  local s row
  s=$(readme_section Skills)
  row=$(printf '%s\n' "$s" | grep -F '| `/workdeck:plan <spec path> [what to change]` |') || fail 'the Skills table has no row for the plan skill'
  assert_contains "$row" 'built on the main branch and not yet released'
  assert_contains "$s" 'A specification from an untrusted source is an instruction to that session'
  assert_contains "$s" '`plan/*` branch'
  assert_contains "$s" 'open a pull request'
  # The rows for the three skills 0.2 changes say what changed.
  assert_contains "$(printf '%s\n' "$s" | grep -F '| `/workdeck:next-card [id]` |')" 'row of an outline'
  assert_contains "$(printf '%s\n' "$s" | grep -F '| `/workdeck:handoff [split]` |')" 'since it was approved'
  assert_contains "$(printf '%s\n' "$s" | grep -F '| `/workdeck:init` |')" 'already set up'
  assert_contains "$(readme_section Roadmap)" 'built on the main branch and not yet released'
  # The card's notes from P-17, P-11 and P-16: init on a repository that is set
  # up, the 0.2 condition of the stop hook, and what the permission rules leave.
  s=$(readme_section 'Quick start')
  assert_contains "$s" 'on a repository that already has `workdeck.conf` no longer stops'
  assert_contains "$s" 'It does not offer the pull request template, the CI workflow or the settings for teammates there'
  assert_contains "$(readme_section 'What the plugin runs')" 'a commit that changes only the cards directory does not count'
  assert_contains "$(readme_section 'When it stops')" 'the commits must change something outside the cards directory'
}

# The two bullets that waited for the hand runs say what docs/evidence.md has.
test_readme_known_limits_say_what_the_hand_runs_showed() {
  local s b e n=0
  s=$(readme_section 'Known limits')
  assert_not_contains "$s" 'Not run: whether the deny rules'
  assert_contains "$s" 'a redirect and a pipe after the branch name did not make a deny rule match'
  assert_contains "$s" 'The skills now say to run the push as its own command'
  b=$(printf '%s\n' "$s" | grep '^- Some commands are not pre-approved: `git checkout`, `git pull`, `git add` and `git commit`\.') || fail 'Known limits has no bullet on the commands that are not pre-approved'
  assert_contains "$b" 'five hand-run sessions'
  assert_contains "$b" 'wrote a file from the shell'
  assert_contains "$b" 'several chained commands'
  assert_contains "$b" 'inferred from a pasted terminal and from waits in the transcripts'
  assert_contains "$b" 'no prompt was recorded as such'
  assert_contains "$b" '](docs/evidence.md'
  assert_not_contains "$b" 'has not been recorded'
  # What the runs do not bear out is said: one of the four did not wait, and
  # the Write and Edit tools waited as well.
  assert_contains "$b" 'returned without a wait'
  assert_contains "$b" 'those calls waited too'
  # No command the bullet names has a permission entry. This compares a prefix:
  # the first two words of each allow entry against the start of each code span.
  # A span that starts with any of them (`card`, `gh pr`, `git push`, `git branch`,
  # `git status`, `git diff`, `git log`, `git show`, `git merge-base`) fails
  # whether or not an entry matches it, a path under cards/ included. The
  # template is split at commas, so two entries on one line are both read.
  while IFS= read -r e; do
    n=$((n + 1))
    assert_not_contains "$b" "\`$e"
  done < <(awk '/"deny"/ { exit } /"Bash\(/ { sub(/.*Bash\(/, ""); sub(/\).*/, ""); if ($1 == "<check>") next; k = ($2 == "" || $2 == "*" ? $1 : $1 " " $2); sub(/:?\*$/, "", k); print k }' < <(tr ',' '\n' < "$ROOT/templates/settings-permissions.json"))
  [ "$n" -ge 10 ] || fail "read $n allow entries from the permission template, expected 10 or more"
}

# Design 0.2, section 8, the rows for a 0.1 user, and the limits of section 11.3.
test_readme_says_a_0_1_repository_runs_init_again_to_plan() {
  local s
  s=$(readme_section FAQ)
  assert_contains "$s" 'run `/workdeck:init` again'
  assert_contains "$s" 'change the tag in the workflow and add the step that runs `card plan`'
  # A skill the model cannot invoke costs nothing; the agents' descriptions do.
  assert_contains "$s" 'adds nothing to a session'
  assert_contains "$s" 'descriptions of the two agents'
  assert_not_contains "$s" 'descriptions of the four skills'
  s=$(readme_section 'Known limits')
  assert_contains "$s" 'one heading level'
  assert_contains "$s" 'Only `#` headings count'
  assert_contains "$s" '`card plan` is not a handoff gate'
}

# Design 0.2, section 9: each form with its arguments and its exit codes.
test_reference_names_every_plan_subcommand() {
  local s c
  s=$(doc_section docs/reference.md '`card plan`')
  [ -n "$s" ] || fail 'docs/reference.md has no section for card plan'
  while IFS= read -r c; do
    printf '%s\n' "$s" | grep -F "| \`$c\` |" | grep 'Exit 0 ' | grep 'Exit 1 ' | grep -q 'Exit 2 ' || fail "docs/reference.md gives no row with exit 0, 1 and 2 for $c"
  done <<'COMMANDS'
card plan
card plan new <spec path> <PREFIX> [--level N]
card plan accept <PREFIX>
card plan start <id>
card plan check <id>
COMMANDS
  # Exit 2 is said once for every form.
  assert_contains "$s" 'Every form exits 2 on a usage error'
  # The arguments are the ones card itself prints.
  card plan --help
  assert_eq 'usage: card plan [new <spec path> <PREFIX> [--level N] | accept <PREFIX> | start <id> | check <id>]' "$OUT$ERR" 'usage of card plan'
}

# Design 0.2, sections 5 and 6.
test_reference_describes_the_outline_format() {
  local s k
  s=$(doc_section docs/reference.md 'Outline format')
  [ -n "$s" ] || fail 'docs/reference.md has no section for the outline format'
  for k in spec spec_blob prefix level size depends does not; do
    assert_contains "$s" "\`$k\`"
  done
  assert_contains "$s" '## Not planned'
  assert_contains "$s" 'may be left out'
  assert_contains "$s" 'never used again'
  s=$(doc_section docs/reference.md 'Card states')
  assert_contains "$s" 'A row with no card file has the same states'
  assert_contains "$s" 'plus a letter'
}

test_design_points_to_the_0_2_design() {
  local f="$ROOT/docs/design.md"
  # At the top: before the first section.
  awk '/^## / { exit } { print }' "$f" | grep -qF '[`design-0.2.md`](design-0.2.md) adds to it' || fail 'docs/design.md does not point to design-0.2.md at its top'
  [ -s "$ROOT/docs/design-0.2.md" ] || fail 'docs/design-0.2.md is missing'
}

test_readme_install_line_matches_the_manifests() {
  local plugin market repo
  plugin=$(sed -n 's/^  "name": "\(.*\)",$/\1/p' "$ROOT/.claude-plugin/plugin.json" | head -1)
  market=$(sed -n 's/^  "name": "\(.*\)",$/\1/p' "$ROOT/.claude-plugin/marketplace.json" | head -1)
  repo=$(sed -n 's|^  "repository": "https://github.com/\(.*\)",$|\1|p' "$ROOT/.claude-plugin/plugin.json")
  grep -q "/plugin marketplace add $repo" "$ROOT/README.md" || fail "README does not add the marketplace $repo"
  grep -q "/plugin install $plugin@$market" "$ROOT/README.md" || fail "README does not install $plugin@$market"
  grep -q "raw.githubusercontent.com/$repo/v$("$BASH" "$CARD" version | sed 's/^card //')/bin/card" "$ROOT/README.md" || fail 'README download line does not name this version'
}

test_readme_links_resolve() {
  local l
  for l in $(grep -o '](\([^)#]*\)' "$ROOT/README.md" | sed 's/^](//' | grep -v '^http' | sort -u); do
    [ -e "$ROOT/$l" ] || fail "README links to $l, which does not exist"
  done
}

test_evidence_names_the_first_pull_request() {
  local log="$ROOT/log/2026-10-06-DOC-02-1.md" k v
  grep -q 'github.com/AshwinSathian/workdeck/pull/1' "$ROOT/docs/evidence.md" || fail 'evidence does not link pull request 1'
  # The figures on the page are the ones in the session log.
  for k in baseline_tokens peak_tokens growth_tokens; do
    v=$(sed -n "s/^$k: //p" "$log" | awk '{ printf "%d,%03d", $1 / 1000, $1 % 1000 }')
    grep -q "$v" "$ROOT/docs/evidence.md" || fail "evidence does not give $k as $v"
  done
  ! grep -q -i 'no pull requests\|none did' "$ROOT/README.md" || fail 'README still says no card went through the loop'
}

# Design 0.2, section 17, last item: the three hand runs are on the evidence page.
test_evidence_records_the_hand_runs_of_plan_next_card_and_init() {
  local s w n
  s=$(doc_section docs/evidence.md 'Hand runs of the planner in a scratch repository')
  [ -n "$s" ] || fail 'evidence has no section for the hand runs'
  for w in '--plugin-dir' '--setting-sources project' '/workdeck:plan' '/workdeck:next-card' '/workdeck:init' 'Changes to the card since it was approved' 'stop hook' 'no prompt is recorded as such' '### Faults found' 'None is fixed here' '### Not run'; do
    assert_contains "$s" "$w"
  done
  # One growth figure per run: init, plan twice, the dependency's card and the row that had it.
  n=$(printf '%s\n' "$s" | grep -c '^| Growth | [0-9][0-9,]* |$')
  [ "$n" -ge 5 ] || fail "the hand runs give $n growth figures, not one per run"
  # Each fault names the file it is in.
  n=$(printf '%s\n' "$s" | awk '/^### Faults found/ { on = 1; next } /^### / { on = 0 } on && /^- /' | grep -vc '^- `[a-z]*/[^`]*`')
  [ "$n" -eq 0 ] || fail "$n faults do not start with the file they are in"
  s=$(doc_section docs/evidence.md 'Not yet shown')
  [ -n "$s" ] || fail 'evidence has no section Not yet shown'
  ! printf '%s\n' "$s" | grep -q 'The DOC-02 session ran under' || fail 'Not yet shown still has the 0.1 text on init'"'"'s permission entries'
}

# M-01. mk_release_tree: a tree at $T/rel whose files all name 1.2.3, with
# scripts/release-check.sh copied in; cd into it. The script reads the tree it
# sits in, so a case changes one file there and runs the copy.
mk_release_tree() {
  local d="$T/rel"
  mkdir -p "$d/bin" "$d/scripts" "$d/.claude-plugin"
  cp "$ROOT/scripts/release-check.sh" "$d/scripts/" || fail 'scripts/release-check.sh is missing'
  # shellcheck disable=SC2016
  printf '%s\n' '#!/usr/bin/env bash' '# Version 1.2.3. https://example.invalid' 'readonly VERSION=1.2.3' 'echo "card $VERSION"' > "$d/bin/card"
  printf '%s\n' '{' '  "name": "x",' '  "version": "1.2.3"' '}' > "$d/.claude-plugin/plugin.json"
  printf '%s\n' '{' '  "name": "x"' '}' > "$d/.claude-plugin/marketplace.json"
  printf '%s\n' '# Changelog' '' '## [Unreleased]' '' '## [1.2.3] - 2026-01-02' '' 'The third.' '' '### Added' '' '- A thing.' '' \
    '## [1.2.2] - 2026-01-01' '' '- Older.' '' \
    '[1.2.3]: https://example.invalid/releases/tag/v1.2.3' '[1.2.2]: https://example.invalid/releases/tag/v1.2.2' > "$d/CHANGELOG.md"
  printf '%s\n' '# X' '' '```' 'curl -fsSL https://raw.githubusercontent.com/o/r/v1.2.3/bin/card -o card' '```' > "$d/README.md"
  cd "$d" || exit 1
}

release_check() { run "$BASH" "$T/rel/scripts/release-check.sh" "$@"; }

# release_fault <file> <sed expression> <file the report must name> [words]:
# a fresh tree with one line changed fails, and the report names that file.
release_fault() {
  mk_release_tree
  edit "$1" "$2"
  release_check 1.2.3
  assert_rc 1
  printf '%s\n' "$OUT" | grep -q "^$3: " || fail "a fault in $1 is not reported as $3"
  assert_eq 1 "$(printf '%s\n' "$OUT" | grep -c .)" "lines reported for a fault in $1"
  [ -z "${4-}" ] || assert_contains "$OUT" "$4"
}

test_release_check_passes_on_this_tree_and_fails_on_a_version_mismatch() {
  local v n
  # This tree, at the version `card version` prints. Between releases the
  # changelog holds work under [Unreleased], and a tree in that state is not
  # ready to tag: the script must then report that, once, and nothing else.
  # With nothing under [Unreleased], as straight after a release, it passes.
  v=$("$BASH" "$CARD" version | sed 's/^card //')
  n=$(awk '/^## \[/ { on = index($0, "[Unreleased]") > 0; next } on && NF' "$ROOT/CHANGELOG.md" | grep -c .)
  run "$BASH" "$ROOT/scripts/release-check.sh" "$v"
  if [ "$n" -eq 0 ]; then
    assert_rc 0
    assert_eq "release-check: $v ok" "$OUT" 'report on this tree'
  else
    assert_rc 1
    assert_eq "CHANGELOG.md: $n lines are still under ## [Unreleased]" "$OUT" 'report on this tree'
  fi

  mk_release_tree
  release_check 1.2.3; assert_rc 0; assert_empty "$ERR" stderr
  release_check v1.2.3; assert_rc 0

  release_fault bin/card 's/^readonly VERSION=.*/readonly VERSION=1.2.4/' bin/card "'card 1.2.4'"
  release_fault bin/card 's/^# Version 1\.2\.3\./# Version 1.2.2./' bin/card
  release_fault .claude-plugin/plugin.json 's/"version": "1\.2\.3"/"version": "1.2.2"/' '\.claude-plugin/plugin\.json'
  release_fault .claude-plugin/marketplace.json 's/"name": "x"/"name": "x", "version": "1.2.2"/' '\.claude-plugin/marketplace\.json'
  release_fault CHANGELOG.md 's/^## \[1\.2\.3\] - .*/## [1.3.0] - 2026-01-02/' 'CHANGELOG\.md'
  release_fault CHANGELOG.md 's/^## \[1\.2\.3\] - .*/## [1.2.3]/' 'CHANGELOG\.md' 'date'
  release_fault CHANGELOG.md 's/^## \[Unreleased\]$/&\
\
- Not released./' 'CHANGELOG\.md' '[Unreleased]'
  release_fault CHANGELOG.md '/^\[1\.2\.3\]: /d' 'CHANGELOG\.md' 'link'
  release_fault README.md 's|/v1\.2\.3/bin/card|/v1.2.2/bin/card|' 'README\.md' 'v1.2.2'
  release_fault README.md 's|^curl .*|curl -fsSL https://example.invalid/card|' 'README\.md'

  # A marketplace that names the version passes; the wrong version as the
  # argument is reported once for each file that names another.
  mk_release_tree
  edit .claude-plugin/marketplace.json 's/"name": "x"/"name": "x", "version": "1.2.3"/'
  release_check 1.2.3; assert_rc 0
  release_check 1.2.4; assert_rc 1
  for v in bin/card .claude-plugin/plugin.json .claude-plugin/marketplace.json CHANGELOG.md README.md; do
    printf '%s\n' "$OUT" | grep -q "^$v: " || fail "the wrong version is not reported for $v"
  done

  release_check; assert_rc 2; assert_contains "$ERR" 'usage:'
  release_check 1.2; assert_rc 2
  release_check '1.2.3;x'; assert_rc 2
  release_check 1.2.3 extra; assert_rc 2

  # The notes are the entry without its heading, and nothing of its neighbors.
  release_check --notes 1.2.3; assert_rc 0
  assert_eq 'The third.' "$(printf '%s\n' "$OUT" | head -1)" 'first line of the notes'
  assert_contains "$OUT" '- A thing.'
  assert_not_contains "$OUT" 'Older'
  assert_not_contains "$OUT" '## ['
  release_check --notes 1.2.2; assert_rc 0
  assert_eq '- Older.' "$OUT" 'notes of the last entry, without the link lines'
  release_check --notes 9.9.9; assert_rc 1; assert_empty "$OUT" 'notes of no entry'

  # A line in a code fence is not a heading, and a link definition that is
  # not a version's stays in the notes.
  mk_release_tree
  edit CHANGELOG.md 's/^- A thing\.$/&\
\
```\
## [9.9.9] in a fence\
```\
\
See [the guide][g].\
\
[g]: https:\/\/example.invalid\/g/'
  release_check 1.2.3; assert_rc 0
  release_check --notes 1.2.3; assert_rc 0
  assert_contains "$OUT" '## [9.9.9] in a fence'
  assert_contains "$OUT" '[g]: https://example.invalid/g'
  assert_not_contains "$OUT" 'Older'
}

# The workflow is not run here, and no tag is pushed: this reads the file.
# It holds form: a test cannot parse YAML with the tools the repository allows.
test_release_workflow_runs_the_check_and_publishes_card_with_its_checksum() {
  local f="$ROOT/.github/workflows/release.yml" w n s
  [ -s "$f" ] || fail '.github/workflows/release.yml is missing'
  grep -q "^    tags: \['v\*'\]$" "$f" || fail 'the workflow does not run on a pushed tag v*'
  ! grep -q 'branches:' "$f" || fail 'the workflow names a branch: the tag may be on a branch that is not main'
  # shellcheck disable=SC2016
  for w in 'make lint' 'make test' 'scripts/release-check.sh "${GITHUB_REF_NAME#v}"' 'scripts/release-check.sh --notes "${GITHUB_REF_NAME#v}"' \
    'cp bin/card dist/card' 'sha256sum card > SHA256SUMS' 'subject-path: dist/card' \
    'gh release create "$GITHUB_REF_NAME" dist/card dist/SHA256SUMS dist/card.sigstore.json' '--verify-tag' '--notes-file'; do
    grep -q -F -- "$w" "$f" || fail "the workflow has no [$w]"
  done
  # Nothing is published before the checks: the job that publishes needs the
  # job that checks, and the release is the last thing it does.
  grep -q '^    needs: check$' "$f" || fail 'the publishing job does not wait for the check'
  n=$(grep -n 'gh release create' "$f" | cut -d: -f1)
  assert_empty "$(awk -v n="$n" 'NR > n && /uses:|run:/' "$f")" 'steps after the release is created'
  n=$(grep -n '^  publish:$' "$f" | cut -d: -f1)
  for w in 'run: make lint' 'run: make test' 'bin/card lint' 'run: make validate' 'for a in mawk gawk' 'scripts/release-check.sh "'; do
    [ "$(grep -n -F -- "$w" "$f" | head -1 | cut -d: -f1)" -lt "$n" ] || fail "[$w] is not in the job that runs first"
  done
  ! grep -q 'continue-on-error\|always()\|failure()' "$f" || fail 'a step of the workflow runs after a failure'
  # Started by hand it is a dry run: the two steps that need a tag are the
  # only ones with that condition, and the release is one of them.
  grep -q '^  workflow_dispatch:$' "$f" || fail 'the workflow cannot be started by hand for a dry run'
  assert_eq 2 "$(grep -c "^        if: github.event_name == 'push'$" "$f")" 'steps that run only for a tag'
  s=$(awk '/^      - name: Create the release$/ { getline; print; exit }' "$f")
  assert_eq "        if: github.event_name == 'push'" "$s" 'the condition on the release step'
  # Every action is pinned to a commit, with its version beside it.
  n=$(grep -c 'uses:' "$f")
  [ "$n" -ge 3 ] || fail "the workflow uses $n actions"
  assert_eq "$n" "$(grep -c -E 'uses: [A-Za-z0-9_./-]+@[0-9a-f]{40} # v[0-9]' "$f")" 'actions pinned to a commit'
  # Nothing is granted to the workflow as a whole; each job states its own,
  # and only the job that publishes may write.
  grep -q '^permissions: {}$' "$f" || fail 'the workflow grants a permission to every job'
  assert_eq 2 "$(grep -c '^    permissions:$' "$f")" 'jobs that state their permissions'
  n=$(grep -n '^  publish:$' "$f" | cut -d: -f1)
  assert_empty "$(awk -v n="$n" 'NR < n && /: write/' "$f")" 'write permissions outside the publishing job'
  assert_eq 'attestations: write contents: write id-token: write' \
    "$(grep -o '[a-z-]*: write' "$f" | sort | tr '\n' ' ' | sed 's/ $//')" 'write permissions'
  # The README shows how to check the download against what the workflow publishes.
  s=$(readme_section Install)
  assert_contains "$s" '/releases/download/'
  assert_contains "$s" 'shasum -a 256 -c SHA256SUMS'
  assert_contains "$s" 'gh attestation verify card --repo AshwinSathian/workdeck --signer-workflow AshwinSathian/workdeck/.github/workflows/release.yml'
  grep -q '^release-check:' "$ROOT/Makefile" || fail 'Makefile has no release-check target'
}

test_releasing_doc_lists_every_step_the_workflow_does_not_do() {
  local f=docs/releasing.md s w
  [ -s "$ROOT/$f" ] || fail "$f is missing"
  s=$(doc_section "$f" 'What stays by hand')
  for w in 'The decision to tag' 'The version commit' 'The tag' "The repository's homepage" 'Announcing' 'scripts/release-check.sh' 'P-24'; do
    assert_contains "$s" "$w"
  done
  # What the workflow does, in the words of the file it describes.
  s=$(doc_section "$f" 'What the workflow does')
  for w in 'make lint' 'make test' 'release-check' '`card`' '`SHA256SUMS`' '`card.sigstore.json`' 'CHANGELOG.md' 'does not deliver the plugin'; do
    assert_contains "$s" "$w"
  done
  s=$(doc_section "$f" 'A release from a branch')
  assert_contains "$s" 'section 22, decision 1'
  assert_contains "$s" 'does not ask which branch'
  s=$(doc_section "$f" 'Withdrawing a bad release')
  assert_contains "$s" 'gh release delete'
  assert_contains "$s" 'a new version'
  s=$(doc_section "$f" 'A dry run')
  assert_contains "$s" 'gh workflow run release.yml'
  assert_contains "$s" 'read from the tagged commit'
  s=$(doc_section "$f" 'The first run')
  assert_contains "$s" 'P-24'
  assert_contains "$s" 'gh attestation verify'
  # The page the attestation step was written from.
  grep -q -F 'docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations' "$ROOT/$f" || fail "$f does not cite the page on attestations"
  assert_contains "$(readme_section Contributing)" '](docs/releasing.md)'
  grep -q -F '](docs/releasing.md)' "$ROOT/CONTRIBUTING.md" || fail 'CONTRIBUTING.md does not point at docs/releasing.md'
}

# M-02. The workflows this repository runs, and the one init offers to users.
# These hold form: a test cannot parse YAML with the tools the repository allows.
PINNED='uses: [A-Za-z0-9_./-]+@[0-9a-f]{40} # v[0-9][0-9.]*$'

test_every_workflow_action_is_pinned_to_a_commit() {
  local f n=0 bad
  for f in "$ROOT"/.github/workflows/*.y*ml "$ROOT/templates/workdeck.yml"; do
    bad=$(grep -n 'uses:' "$f" | grep -v -E "$PINNED")
    [ -z "$bad" ] || fail "${f#"$ROOT"/} has an action that is not pinned to a commit with its version beside it: $bad"
    n=$((n + $(grep -c 'uses:' "$f")))
  done
  [ "$n" -ge 3 ] || fail "only $n actions were found in the workflows"
  # The pattern refuses a tag, a branch and a short commit.
  for bad in 'uses: actions/checkout@v4' 'uses: actions/checkout@main' 'uses: actions/checkout@11d5960 # v4.4.0' \
    'uses: actions/checkout@11d5960a326750d5838078e36cf38b85af677262'; do
    ! printf '      - %s\n' "$bad" | grep -q -E "$PINNED" || fail "[$bad] counts as pinned"
  done
  # The pins are kept current, or they rot.
  f="$ROOT/.github/dependabot.yml"
  [ -s "$f" ] || fail '.github/dependabot.yml is missing'
  grep -q '^  - package-ecosystem: "github-actions"$' "$f" || fail 'dependabot does not update github-actions'
  grep -q '^      interval: "weekly"$' "$f" || fail 'dependabot does not run weekly'
  # The linter is not an action: a script names its version and the checksum
  # of each archive, and both systems get that version.
  f="$ROOT/scripts/ci-shellcheck.sh"
  grep -q '^VERSION=[0-9][0-9.]*$' "$f" || fail 'ci-shellcheck.sh does not name one shellcheck version'
  assert_eq 2 "$(grep -c -E '^  [A-Za-z0-9_.]+\) arch=[a-z0-9_.]+ sum=[0-9a-f]{64} ;;$' "$f")" 'shellcheck archives with a checksum'
  grep -q 'shasum -a 256 -c' "$f" || fail 'ci-shellcheck.sh does not check the archive'
  for f in "$ROOT"/.github/workflows/*.y*ml; do
    ! grep -q 'make lint' "$f" || grep -q 'run: /bin/bash scripts/ci-shellcheck.sh "$RUNNER_TEMP" >> "$GITHUB_PATH"$' "$f" || fail "${f#"$ROOT"/} lints with whatever shellcheck the runner has"
    ! grep -q 'brew install shellcheck\|apt.* shellcheck' "$f" || fail "${f#"$ROOT"/} installs a shellcheck of no fixed version"
  done
  grep -q 'shellcheck --version' "$ROOT/.github/workflows/ci.yml" || fail 'ci.yml does not print the shellcheck version'
}

test_workflows_state_their_permissions() {
  local f p
  for f in "$ROOT"/.github/workflows/*.y*ml "$ROOT/templates/workdeck.yml"; do
    grep -q '^permissions:' "$f" || fail "${f#"$ROOT"/} has no top-level permissions block"
  done
  # ci.yml and the template read, and write nothing.
  for f in "$ROOT/.github/workflows/ci.yml" "$ROOT/templates/workdeck.yml"; do
    p=$(awk '/^permissions:/ { on = 1; next } on && /^[^ ]/ { exit } on' "$f")
    assert_eq '  contents: read' "$p" "permissions of ${f#"$ROOT"/}"
    ! grep -q ': write' "$f" || fail "${f#"$ROOT"/} grants a write permission"
  done
  # CI runs the link check on both systems: it is a step of the matrix job.
  grep -q '^        run: make links$' "$ROOT/.github/workflows/ci.yml" || fail 'ci.yml does not run the link check'
  grep -q '^links:' "$ROOT/Makefile" || fail 'Makefile has no links target'
  grep -q '^check: lint test links$' "$ROOT/Makefile" || fail 'make check does not run lint, test and links'
  # Code owners: the maintainer for everything, and by name for the files
  # where a change is a security change.
  f="$ROOT/.github/CODEOWNERS"
  [ -s "$f" ] || fail '.github/CODEOWNERS is missing'
  for p in '*' '/bin/card' '/hooks/' '/templates/settings-permissions.json' '/.github/workflows/'; do
    grep -q -E "^$(printf '%s' "$p" | sed 's/[.*]/\\&/g') +@AshwinSathian$" "$f" || fail "CODEOWNERS has no owner for $p"
  done
  [ "$(grep -n '^\* ' "$f" | cut -d: -f1)" -lt "$(grep -n '^/bin/card ' "$f" | cut -d: -f1)" ] || fail 'the rule for everything is not first: the last match wins'
  # SECURITY.md says what is pinned and how a release is checked.
  f="$ROOT/SECURITY.md"
  grep -q 'pinned to a commit' "$f" || fail 'SECURITY.md does not say the actions are pinned'
  grep -q 'gh attestation verify' "$f" || fail 'SECURITY.md does not say how a release is verified'
}

test_markdown_links_and_anchors_resolve() {
  cd "$ROOT" || exit 1
  run "$BASH" "$ROOT/scripts/check-links.sh"
  assert_empty "$OUT" 'broken links in this repository'
  assert_rc 0
}

test_check_links_reports_a_broken_link_and_a_broken_anchor() {
  new_repo
  mkdir -p sub cards
  # shellcheck disable=SC2016
  printf '%s\n' '# Top' '' '## Second heading' '' '## The `card` command, and more!' '' '## Twice' '' '## Twice' '' \
    '## 21. Build order' '' '```' '## In a fence' '```' '' '## A [link](a.md) in it' > b.md
  # shellcheck disable=SC2016
  printf '%s\n' '# A' \
    '[ok](b.md) [ok](b.md#second-heading) [ok](sub/) [ok](#a) [ok](b.md#the-card-command-and-more)' \
    '[bad](nope.md)' \
    '[ok](b.md#twice) [ok](b.md#twice-1) [bad](b.md#twice-2)' \
    '[ext](https://example.invalid/nope.md#x) [mail](mailto:a@example.invalid)' \
    '`[code](inline.md)` and [bad](b.md#in-a-fence)' \
    '```' '[fenced](fenced.md)' '```' \
    '[ok](b.md#21-build-order) [ok](b.md#a-link-in-it) [ok](<b.md> "a title")' \
    '[bad](#nope)' \
    '[ref]: gone.md' \
    '```inline``` is not a fence, so this is read: [bad](after.md)' \
    '``code with ` inside`` [bad](double.md) and `x`' \
    '  [ref2]: gone2.md' \
    "[ok](b.md 'a title') [ok](b.md?plain=1#top) [ok](sub/my%20file.md)" \
    '[ok](b.md#dash--and-arrow--here) [ok](b.md#an-emphasised-word) [ok](b.md#snake_case-stays) [ok](b.md#indented)' > a.md
  printf '%s\n' '' '## Dash — and arrow → here' '' '## An _emphasised_ word' '' '## snake_case stays' '' '   ## Indented' >> b.md
  echo x > 'sub/my file.md'
  printf '%s\n' '[ok](../b.md#top) [ok](/b.md) [bad](b.md) [bad](../b.md#Top)' > sub/c.md
  # A Read item of a card that is not done is a path from the root with an
  # anchor. A card that is done is a record: its Read items are not checked.
  # shellcheck disable=SC2016
  printf '%s\n' '---' 'id: X-01' 'done: false' '---' '' '## Read' '- b.md#second-heading (why)' '- b.md#nope' '- gone/' '- `b.md` (in backticks)' '' '## Touch' '- other.md' > cards/X-01-open.md
  printf '%s\n' '---' 'id: X-02' 'done: true' '---' '' 'done: false' '' '## Read' '- gone.md#nope' > cards/X-02-done.md
  # An ignored file is not read; one that is neither tracked nor ignored is.
  echo 'ignored.md' > .gitignore
  echo '[bad](nope.md)' > ignored.md
  git add a.md b.md sub cards .gitignore
  run "$BASH" "$ROOT/scripts/check-links.sh"
  assert_rc 1
  assert_eq 'a.md:3: nope.md
a.md:4: b.md#twice-2
a.md:6: b.md#in-a-fence
a.md:11: #nope
a.md:12: gone.md
a.md:13: after.md
a.md:14: double.md
a.md:15: gone2.md
cards/X-01-open.md:8: b.md#nope
cards/X-01-open.md:9: gone/
sub/c.md:1: b.md
sub/c.md:1: ../b.md#Top' "$OUT" 'report'
  assert_empty "$ERR" stderr
  # It runs from a subdirectory, and outside a repository it is a usage error.
  cd sub || exit 1
  run "$BASH" "$ROOT/scripts/check-links.sh"; assert_rc 1
  cd "$T" || exit 1
  run "$BASH" "$ROOT/scripts/check-links.sh"; assert_rc 2
  assert_contains "$ERR" 'check-links:'
  # No network: the script names no tool that makes a call.
  ! grep -n -E '(^|[^a-z-])(curl|wget|gh|nc|ssh|git (fetch|pull|push|clone|ls-remote)) ' "$ROOT/scripts/check-links.sh" | grep -v '^[0-9]*:#' || fail 'check-links.sh names a network tool'
  # The cards directory is read from workdeck.conf, whatever letters it has.
  cd "$T/repo" || exit 1
  git mv cards tickets
  echo 'cards_dir = tickets' > workdeck.conf
  run "$BASH" "$ROOT/scripts/check-links.sh"
  assert_contains "$OUT" 'tickets/X-01-open.md:8: b.md#nope'
}

# M-03. An issue form is YAML with a fixed schema, and a form that does not
# parse is shown as no template at all, with no error. A test cannot parse
# YAML with the tools the repository allows, so these hold form, not a parse:
# each question is there, under the key and at the indent the schema gives it.

# form_field <file> <id>: the lines of the element with that id, from its
# "- type:" line to the line before the next element.
form_field() {
  awk -v id="    id: $2" '
    /^  - type: / { if (hit) exit; buf = ""; }
    { buf = buf $0 "\n" }
    $0 == id { hit = 1 }
    END { if (hit) printf "%s", buf }' "$1"
}

# form_requires <file> <id> <type>: the element exists, is of that type, has
# a label, and is required.
form_requires() {
  local e
  e=$(form_field "$1" "$2")
  [ -n "$e" ] || fail "$(basename "$1") has no question with the id $2"
  assert_contains "$e" "  - type: $3"
  printf '%s\n' "$e" | grep -q '^      label: .' || fail "$2 has no label"
  printf '%s\n' "$e" | grep -A1 '^    validations:$' | grep -q '^      required: true$' || fail "$2 is not a required question"
}

test_issue_forms_ask_for_what_a_bug_needs() {
  local d="$ROOT/.github/ISSUE_TEMPLATE" f k e
  assert_no_file "$d/bug.md"
  assert_no_file "$d/idea.md"
  for f in "$d/bug.yml" "$d/idea.yml"; do
    [ -s "$f" ] || fail "${f#"$ROOT"/} is missing"
    for k in name description body; do
      grep -q "^$k:" "$f" || fail "${f#"$ROOT"/} has no top-level $k"
    done
    ! grep -q "$(printf '\t')" "$f" || fail "${f#"$ROOT"/} has a tab: YAML refuses one as an indent"
    # An id and a label are unique in a form.
    assert_empty "$(grep '^    id: ' "$f" | sort | uniq -d)" "repeated ids in ${f#"$ROOT"/}"
    assert_empty "$(grep '^      label: ' "$f" | sort | uniq -d)" "repeated labels in ${f#"$ROOT"/}"
    # The shape of every element: a known type; `attributes` and `validations`
    # at the element's indent and nowhere else; a question has an id and a
    # label; markdown has its text and a dropdown its options.
    k=$(grep -c '^  - type: ' "$f")
    assert_empty "$(grep '^  - type: ' "$f" | grep -v -x '  - type: \(markdown\|textarea\|input\|dropdown\)')" "unknown element types in ${f#"$ROOT"/}"
    assert_eq "$k" "$(grep -c '^    attributes:$' "$f")" "elements with attributes in ${f#"$ROOT"/}"
    assert_eq "$k" "$(grep -c 'attributes:' "$f")" "attributes keys in ${f#"$ROOT"/}"
    e=$(grep -c '^  - type: markdown$' "$f")
    assert_eq "$e" "$(grep -c '^      value: |$' "$f")" "markdown elements with text in ${f#"$ROOT"/}"
    assert_eq "$((k - e))" "$(grep -c '^    id: [a-z][a-z0-9-]*$' "$f")" "questions with an id in ${f#"$ROOT"/}"
    assert_eq "$((k - e))" "$(grep -c '^      label: .' "$f")" "questions with a label in ${f#"$ROOT"/}"
    assert_eq "$((k - e))" "$(grep -c '^    validations:$' "$f")" "questions that say whether they are required in ${f#"$ROOT"/}"
    assert_eq "$((k - e))" "$(grep -c 'validations:' "$f")" "validations keys in ${f#"$ROOT"/}"
    assert_eq "$((k - e))" "$(grep -c '^      required: \(true\|false\)$' "$f")" "required keys in ${f#"$ROOT"/}"
    assert_eq "$(grep -c '^  - type: dropdown$' "$f")" "$(grep -c '^      options:$' "$f")" "dropdowns with options in ${f#"$ROOT"/}"
  done
  [ "$(grep -c '^        - .' "$d/bug.yml")" -ge 2 ] || fail 'the dropdown of the bug form has fewer than two options'
  f="$d/bug.yml"
  form_requires "$f" what-happened textarea
  form_requires "$f" expected textarea
  form_requires "$f" card-version input
  form_requires "$f" git-version input
  form_requires "$f" claude-version input
  form_requires "$f" system input
  form_requires "$f" install dropdown
  e=$(form_field "$f" install)
  assert_contains "$e" 'marketplace'
  assert_contains "$e" '--plugin-dir'
  for k in '`card version`' '`git --version`' '`claude --version`'; do
    grep -q -F -- "$k" "$f" || fail "the bug form does not name the command $k"
  done
  # The session log is asked for and is not required.
  e=$(form_field "$f" session-log)
  [ -n "$e" ] || fail 'the bug form does not ask for the session log'
  assert_not_contains "$e" 'required: true'
  # What not to paste.
  for k in 'transcript' 'token' 'private path'; do
    grep -q -i "$k" "$f" || fail "the bug form does not say not to paste a $k"
  done
  # The idea form asks what the person was doing and what they did instead
  # before it asks for a solution, and points at what is already known.
  f="$d/idea.yml"
  form_requires "$f" doing textarea
  form_requires "$f" instead textarea
  [ -n "$(form_field "$f" solution)" ] || fail 'the idea form does not ask for a solution'
  assert_eq 'doing instead solution' "$(sed -n 's/^    id: //p' "$f" | tr '\n' ' ' | sed 's/ $//')" 'order of the idea form'
  grep -q -F 'docs/development/later.md' "$f" || fail 'the idea form does not link later.md'
  grep -q -F 'README.md#roadmap' "$f" || fail 'the idea form does not link the roadmap'
  f="$d/config.yml"
  grep -q '^blank_issues_enabled: false$' "$f" || fail 'blank issues are not turned off'
  grep -q -F '/security/' "$f" || fail 'config.yml does not link the security policy'
  grep -q -F 'SUPPORT.md' "$f" || fail 'config.yml does not link SUPPORT.md'
  assert_eq "$(grep -c '^  - name: ' "$f")" "$(grep -c '^    url: https://' "$f")" 'contact links with a url'
  assert_eq "$(grep -c '^  - name: ' "$f")" "$(grep -c '^    about: ' "$f")" 'contact links with an about line'
}

test_docs_index_lists_every_file_under_docs() {
  local f=docs/README.md p n=0
  [ -s "$ROOT/$f" ] || fail "$f is missing"
  cd "$ROOT" || exit 1
  # Every tracked file at the first two levels, and every directory below
  # them, is the target of a link on the map.
  for p in $(git ls-files docs | awk -F/ 'NF <= 3 { print; next } { print $1 "/" $2 "/" $3 "/" }' | sort -u); do
    [ "$p" = "$f" ] && continue
    grep -q -F "](${p#docs/})" "$f" || fail "$f has no link to $p"
    n=$((n + 1))
  done
  [ "$n" -ge 15 ] || fail "only $n paths under docs/ were found"
  # One line each: a link is the first thing on its line, in a list or a table.
  assert_eq 0 "$(grep -c '^[^-|#].*](.*\.md).*](.*\.md)' "$f")" 'lines of prose that hold two files'
  grep -q 'never edited' "$f" || fail "$f does not say which files are records"
  grep -q -F '](docs/README.md)' README.md || fail 'README does not link the map of docs/'
}

test_contributing_walks_a_first_change_through_a_card() {
  local s w
  s=$(doc_section CONTRIBUTING.md 'A first change, step by step')
  [ -n "$s" ] || fail 'CONTRIBUTING.md has no walk through a first change'
  for w in 'gh repo fork' '--plugin-dir' '/workdeck:quick "' '/workdeck:next-card' 'make check' '/workdeck:handoff' \
    '`card lint`' '`card touched' '`card tests' 'The reviewer' 'The maintainer' 'Without Claude Code'; do
    assert_contains "$s" "$w"
  done
  s=$(doc_section CONTRIBUTING.md 'How decisions are made')
  [ -n "$s" ] || fail 'CONTRIBUTING.md does not say how decisions are made'
  for w in 'One person merges' 'adversarial review' 'docs/development/' 'cards/REVIEW.md'; do
    assert_contains "$s" "$w"
  done
  for w in 'SUPPORT.md' 'make check'; do
    grep -q -F "$w" "$ROOT/CONTRIBUTING.md" || fail "CONTRIBUTING.md does not name $w"
  done
  # SUPPORT.md: where a question goes, what is not done, what to include.
  s=$(cat "$ROOT/SUPPORT.md")
  for w in '## Where a question goes' '## What the maintainer does not do' '## What to include' 'other than Claude Code' 'private' 'card version'; do
    assert_contains "$s" "$w"
  done
  s=$(readme_section Contributing)
  assert_contains "$s" '](SUPPORT.md)'
  assert_contains "$s" '](docs/README.md)'
}
