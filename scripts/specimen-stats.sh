#!/usr/bin/env bash
# specimen-stats.sh: the figures of docs/specimen.md, counted from git.
#
# Usage: scripts/specimen-stats.sh [<commit>]      HEAD when left out
#
# It prints one line for each figure, "<name>: <value>", for the repository
# as it was at that commit. Everything is read from git objects and the
# commit's history, not from the working files, so the figures of a commit
# are the same whenever they are printed, and a test can hold the page to
# them. It makes no network call. Same tools as bin/card: bash 3.2, git, and
# awk in the forms the three awks share.
#
# How each figure is counted:
#   cards              files <cards_dir>/*.md whose front matter has an id
#   by prefix, size    from the id and the size of that front matter
#   a remainder id     an id that ends in a lowercase letter: what a split leaves
#   session logs       files <log_dir>/*.md whose front matter names a card;
#                      measured when growth_tokens is a number; a split when
#                      outcome is split
#   pull requests      commits whose subject starts "Merge pull request #N
#                      from <owner>/<branch>", by the first part of the branch.
#                      A squash merge has a subject that ends "(#N)" and does
#                      not record the branch, so it is counted apart; so is
#                      any other commit whose subject ends that way.
#   review passes      "## " headings outside a code fence in
#                      docs/development/review-*.md
#   tests              lines "test_<name>() {" at the start of a line in
#                      test/cases/*.sh
#
# A shallow clone has no history: the pull request figures are then too low.
# Exit codes: 0 ok; 2 usage, no repository, or no such commit.
set -u
export LC_ALL=C

[ "$#" -le 1 ] || { echo 'usage: specimen-stats.sh [<commit>]' >&2; exit 2; }
root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo 'specimen-stats: not in a git repository' >&2; exit 2; }
cd "$root" || exit 2
c=$(git rev-parse --verify --quiet "${1:-HEAD}^{commit}") || { echo "specimen-stats: no such commit: ${1:-HEAD}" >&2; exit 2; }

# conf <key> <default>: a value of workdeck.conf at that commit, read as text.
conf() {
  local v
  v=$(git show "$c:workdeck.conf" 2>/dev/null | awk -v k="$1" '
    $0 ~ "^[ \t]*" k "[ \t]*=" { sub(/^[^=]*=[ \t]*/, ""); sub(/[ \t]+$/, ""); print; exit }')
  v=${v%/}
  printf '%s\n' "${v:-$2}"
}
cards=$(conf cards_dir cards)
logs=$(conf log_dir log)

# files <directory> <suffix>: the files directly in a directory at that commit.
files() {
  git ls-tree --name-only "$c" "$1/" 2>/dev/null | grep "$2\$"
}

# front <file>: the front matter of a file at that commit, without its fences.
front() {
  git show "$c:$1" 2>/dev/null | awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }'
}

tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT

# One line for each card: "<id> <size>".
files "$cards" '\.md' | while IFS= read -r f; do
  front "$f" | awk '
    /^id:/ { id = $2 }
    /^size:/ { size = $2 }
    END { if (id != "") print id, (size == "" ? "?" : size) }'
done > "$tmp/cards"

# One line for each log: "<growth_tokens> <outcome>".
files "$logs" '\.md' | while IFS= read -r f; do
  front "$f" | awk '
    /^card:/ { card = $2 }
    /^growth_tokens:/ { g = $2 }
    /^outcome:/ { o = $2 }
    END { if (card != "") print (g == "" ? "?" : g), (o == "" ? "?" : o) }'
done > "$tmp/logs"

git log --format=%s "$c" > "$tmp/subjects"

printf 'commit: %s\n' "$c"
printf 'cards: %s\n' "$(grep -c '' "$tmp/cards")"
# In the order the ids sort, and sizes from the smallest.
printf 'cards by prefix: %s\n' "$(sed 's/-.*//' "$tmp/cards" | sort | uniq -c | awk '{ printf "%s%s %s", (NR > 1 ? ", " : ""), $2, $1 } END { if (NR == 0) printf "none" }')"
printf 'cards by size: %s\n' "$(awk '
  { n[$2]++ }
  END {
    k = split("XS S M L XL ?", order, " ")
    for (i = 1; i <= k; i++) if (n[order[i]] > 0) { printf "%s%s %s", (seen ? ", " : ""), order[i], n[order[i]]; seen = 1; n[order[i]] = 0 }
    for (s in n) if (n[s] > 0) { printf "%s%s %s", (seen ? ", " : ""), s, n[s]; seen = 1 }
    if (!seen) printf "none"
  }' "$tmp/cards")"
rem=$(awk '$1 ~ /[a-z]$/ { print $1 }' "$tmp/cards" | sort | tr '\n' ' ')
rem=${rem% }
n=0
[ -z "$rem" ] || n=$(printf '%s\n' "$rem" | tr ' ' '\n' | grep -c .)
printf 'cards with a remainder id: %s%s\n' "$n" "${rem:+ ($(printf '%s' "$rem" | sed 's/ /, /g'))}"
printf 'session logs: %s\n' "$(grep -c '' "$tmp/logs")"
printf 'session logs with measured tokens: %s\n' "$(grep -c '^[0-9][0-9]* ' "$tmp/logs")"
printf 'session logs that end in a split: %s\n' "$(grep -c ' split$' "$tmp/logs")"
merged() { grep -c "^Merge pull request #[0-9][0-9]* from [^/ ]*[/:]$1" "$tmp/subjects"; }
all=$(grep -c '^Merge pull request #[0-9][0-9]* from ' "$tmp/subjects")
card=$(merged 'card/')
plan=$(merged 'plan/')
printf 'pull requests merged from card/ branches: %s\n' "$card"
printf 'pull requests merged from plan/ branches: %s\n' "$plan"
printf 'pull requests merged from other branches: %s\n' "$((all - card - plan))"
printf 'squash merges, branch not recorded: %s\n' "$(grep -v '^Merge pull request #' "$tmp/subjects" | grep -c ' (#[0-9][0-9]*)$')"
printf 'review passes recorded: %s\n' "$(files docs/development '\.md' | grep '/review-[^/]*\.md$' | while IFS= read -r f; do
  git show "$c:$f" | awk '/^```/ { fence = !fence } !fence && /^## /'
done | grep -c '')"
printf 'tests in the suite: %s\n' "$(files test/cases '\.sh' | while IFS= read -r f; do
  git show "$c:$f" | grep '^test_[A-Za-z0-9_]*() {'
done | grep -c '')"
