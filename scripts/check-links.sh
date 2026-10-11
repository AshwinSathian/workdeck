#!/usr/bin/env bash
# check-links.sh: does every relative link in the markdown files resolve?
#
# Usage: scripts/check-links.sh        run anywhere inside the repository
#
# It reads every markdown file that git tracks, and every one that is neither
# tracked nor ignored, so that a new file is checked before its first commit.
# It checks two forms of link:
#
#   1. A markdown link, [text](target), and a reference definition,
#      [label]: target. The target is a path from the file's directory, or
#      from the root when it starts with "/".
#   2. A Read item of a card that is not done: a line "- path#anchor" under
#      "## Read" in a file of the cards directory. The path is from the root.
#      A card that is done is a record, and its Read items are not checked.
#
# For both, the target must exist, and where it is a markdown file and the
# link has an "#anchor", the anchor must be that of a heading in it, as
# GitHub makes anchors: lower case, letters, digits, "-" and "_" kept, each
# space a "-", and "-1", "-2" for a heading that repeats.
#
# Not checked: a link inside a code fence or inline code, a link with a
# scheme (https:, mailto:), and a section cited in prose. It makes no network
# call. Same tools as bin/card: bash 3.2, git, and awk in the forms the three
# awks share.
#
# It is not a markdown parser, and these are its known limits:
#   - A letter outside ASCII is left out of both sides before an anchor is
#     compared, so a wrong anchor that differs only there is not reported.
#   - A heading underlined with === or ---, and an anchor made with HTML, are
#     not known: a link to one is reported.
#   - A target ends at the first ")", so a path with parentheses is reported.
#   - A fence is opened and closed by any fence line, whatever its length, and
#     a fence inside a block quote is not seen.
#   - A path with a space is not read as a Read item.
#
# It prints one line per broken link to stdout, "<file>:<line>: <target>".
# Exit codes: 0 none; 1 at least one; 2 usage, or not in a repository.
set -u
# Bytes, not characters, so that the three awks agree on a letter outside ASCII.
export LC_ALL=C

[ "$#" -eq 0 ] || { echo 'usage: check-links.sh' >&2; exit 2; }
root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo 'check-links: not in a git repository' >&2; exit 2; }
cd "$root" || exit 2
root=$(pwd -P)

# The cards directory, as workdeck.conf names it. The file is read as text.
cards=cards
if [ -f workdeck.conf ]; then
  c=$(awk '/^[ \t]*cards_dir[ \t]*=/ { sub(/^[^=]*=[ \t]*/, ""); sub(/[ \t]+$/, ""); print; exit }' workdeck.conf)
  [ -z "$c" ] || cards=${c%/}
fi

tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT

# The files, one per line. A tracked file that was deleted is not on disk.
git ls-files -co --exclude-standard -- '*.md' | while IFS= read -r f; do
  [ -f "$f" ] && printf '%s\n' "$f"
done > "$tmp/files"
[ -s "$tmp/files" ] || exit 0

# each_file <awk program> [awk arguments]: runs awk over every file, a
# hundred at a time. The programs reset their state at the first line of a file.
each_file() {
  local prog=$1 batch='' n=0 f
  shift
  while IFS= read -r f; do
    batch="$batch$f
"
    n=$((n + 1))
    if [ "$n" -eq 100 ]; then
      printf '%s' "$batch" | run_awk "$prog" "$@"
      batch=''
      n=0
    fi
  done < "$tmp/files"
  [ "$n" -eq 0 ] || printf '%s' "$batch" | run_awk "$prog" "$@"
}

# run_awk <program> [awk arguments]: the file names come on stdin, and none
# is split at a space.
run_awk() {
  local prog=$1 f
  shift
  set -- "$@" "$FENCE$prog"
  while IFS= read -r f; do set -- "$@" "./$f"; done
  awk "$@"
}

# Shared by both programs. A fence line starts, after at most three spaces,
# with three backticks or tildes; one of backticks that has another backtick
# after them is inline code and not a fence.
# shellcheck disable=SC2016
FENCE='
  function fence_line(s,   r) {
    if (s !~ /^ ? ? ?(```|~~~)/) return 0
    if (s ~ /^ *~/) return 1
    r = s
    sub(/^ *`+/, "", r)
    return index(r, "`") == 0
  }
'

# The anchors of every heading: "<file><tab><anchor>".
# shellcheck disable=SC2016
each_file '
  FNR == 1 { fence = 0; split("", seen) }
  fence_line($0) { fence = !fence; next }
  fence || !/^ ? ? ?#+[ \t]/ { next }
  {
    h = $0
    sub(/^ *#+[ \t]+/, "", h)
    sub(/[ \t]+#*[ \t]*$/, "", h)
    sub(/[ \t]+$/, "", h)
    while (match(h, /\]\([^)]*\)/)) h = substr(h, 1, RSTART - 1) substr(h, RSTART + RLENGTH)
    h = tolower(h)
    a = ""
    n = length(h)
    for (i = 1; i <= n; i++) {
      c = substr(h, i, 1)
      if (c == " ") a = a "-"
      else if (c == "_") {
        # An underscore at the edge of a word is emphasis, and GitHub drops it.
        p = (i > 1) ? substr(h, i - 1, 1) : " "
        q = (i < n) ? substr(h, i + 1, 1) : " "
        if (p != " " && index(" .,;:!?)", q) == 0) a = a c
      }
      else if (index("abcdefghijklmnopqrstuvwxyz0123456789-", c)) a = a c
    }
    k = seen[a]++
    print substr(FILENAME, 3) "\t" (k ? a "-" k : a)
  }' > "$tmp/anchors"

# The links: "<file>:<line><tab><kind><tab><target>". The kind is L for a
# link, whose path is from the file, and R for a Read item, whose path is
# from the root.
# shellcheck disable=SC2016
each_file '
  function emit(kind, t) {
    sub(/^[ \t]+/, "", t)
    sub(/[ \t]+("[^"]*"|\047[^\047]*\047)[ \t]*$/, "", t)
    sub(/[ \t]+$/, "", t)
    sub(/^</, "", t)
    sub(/>$/, "", t)
    sub(/\?[^#]*/, "", t)
    gsub(/%20/, " ", t)
    if (t != "") print name ":" FNR "\t" kind "\t" t
  }
  FNR == 1 {
    name = substr(FILENAME, 3)
    fence = 0; read = 0; open = 0
    front = ($0 == "---")
    card = (index(name, cards "/") == 1 && index(substr(name, length(cards) + 2), "/") == 0)
    if (front) next
  }
  front {
    if ($0 == "---") front = 0
    else if (card && /^done:[ \t]*false[ \t]*$/) open = 1
    next
  }
  fence_line($0) { fence = !fence; next }
  fence { next }
  /^## / { read = ($0 == "## Read") }
  card && open && read && /^- / && $2 !~ /^\[/ {
    t = $2
    gsub(/`/, "", t)
    emit("R", t)
    next
  }
  {
    line = $0
    gsub(/``([^`]|`[^`])*``/, "", line)
    gsub(/`[^`]*`/, "", line)
    if (line ~ /^ ? ? ?\[[^]^][^]]*\]:[ \t]/) {
      t = line
      sub(/^ *\[[^]]*\]:[ \t]+/, "", t)
      emit("L", t)
      next
    }
    while (match(line, /\]\([^)]*\)/)) {
      emit("L", substr(line, RSTART + 2, RLENGTH - 3))
      line = substr(line, RSTART + RLENGTH)
    }
  }' -v "cards=$cards" > "$tmp/links"

bad=0
tab=$(printf '\t')
while IFS="$tab" read -r where kind target; do
  case $target in
    *://* | mailto:*) continue ;;
  esac
  src=${where%:*}
  path=${target%%#*}
  anchor=''
  case $target in *'#'*) anchor=${target#*#} ;; esac
  case $kind:$path in
    L:) file=$src ;;
    L:/*) file=${path#/} ;;
    L:*) file=$(dirname "$src")/$path ;;
    *) file=$path ;;
  esac
  if [ ! -e "$file" ]; then
    printf '%s: %s\n' "$where" "$target"
    bad=1
    continue
  fi
  [ -n "$anchor" ] && [ -f "$file" ] || continue
  case $file in *.md) ;; *) continue ;; esac
  # The heading side has no byte outside ASCII: take them out of this side too.
  case $anchor in *[!\ -~]*) anchor=$(printf '%s' "$anchor" | tr -d '\200-\377') ;; esac
  rel=$(cd "$(dirname "$file")" && pwd -P)/$(basename "$file")
  rel=${rel#"$root"/}
  if ! grep -q -x -F "$rel$tab$anchor" "$tmp/anchors"; then
    printf '%s: %s\n' "$where" "$target"
    bad=1
  fi
done < "$tmp/links"

exit "$bad"
