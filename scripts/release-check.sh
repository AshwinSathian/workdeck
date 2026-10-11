#!/usr/bin/env bash
# release-check.sh: is this tree ready to be tagged as a version?
#
# Usage: scripts/release-check.sh <version>           check the tree
#        scripts/release-check.sh --notes <version>   print that version's
#                                                     entry of CHANGELOG.md
#
# The version is three numbers, 0.2.0, with or without a leading v. The check
# passes only when bin/card, the plugin manifest, the marketplace manifest
# where it names a version, the top entry of CHANGELOG.md and the README's
# download line all name it, and nothing is under "## [Unreleased]". It prints
# one line per fault to stdout, "<file>: <what is wrong>".
#
# It reads the tree it sits in and nothing else: no network, no tag, no git.
# The release workflow runs it against the tag's name, and a maintainer runs
# it before making the tag (docs/releasing.md). Same tools as bin/card: bash
# 3.2, and awk, sed and grep in the forms the three awks share.
#
# Exit codes: 0 ok; 1 a fault, or no such entry for --notes; 2 usage.
set -u

usage() {
  echo 'usage: release-check.sh [--notes] <version>' >&2
  exit 2
}

notes=0
if [ "${1-}" = --notes ]; then
  notes=1
  shift
fi
[ "$#" -eq 1 ] || usage
v=${1#v}
case $v in
  *[!0-9.]* | .* | *. | *..* | *.*.*.*) usage ;;
  *.*.*) ;;
  *) usage ;;
esac

ROOT=$(cd "$(dirname "$0")/.." && pwd -P) || exit 2
cd "$ROOT" || exit 2
for f in bin/card .claude-plugin/plugin.json .claude-plugin/marketplace.json CHANGELOG.md README.md; do
  [ -f "$f" ] || { echo "release-check: $f is missing" >&2; exit 2; }
done

# A heading is a line that starts with "## [" outside a code fence, and a
# fence is a line that starts with three backticks: the only kind CHANGELOG.md
# has.

# entry: the lines of CHANGELOG.md from this version's heading to the next.
entry() {
  awk -v h="## [$v]" '
    /^```/ { fence = !fence }
    !fence && index($0, "## [") == 1 { on = ($0 == h || index($0, h " ") == 1) }
    on' CHANGELOG.md
}

# entry_body: the entry without its heading, without the version link lines
# that end the file ("[0.1.3]: https://..."), and without blank lines at
# either end.
entry_body() {
  entry | awk '
    NR == 1 { next }
    /^\[[0-9][0-9.]*\]: / { next }
    /^[ \t]*$/ { if (seen) blank++; next }
    { while (blank > 0) { print ""; blank-- } seen = 1; print }'
}

if [ "$notes" -eq 1 ]; then
  body=$(entry_body)
  [ -n "$body" ] || { echo "release-check: CHANGELOG.md has no entry for $v" >&2; exit 1; }
  printf '%s\n' "$body"
  exit 0
fi

bad=0
fault() {
  printf '%s: %s\n' "$1" "$2"
  bad=1
}

got=$("${BASH:-bash}" bin/card version 2>/dev/null)
[ "$got" = "card $v" ] || fault bin/card "\`card version\` prints '${got:-nothing}', not 'card $v'"
grep -q -F "# Version $v." bin/card || fault bin/card "the header comment does not say 'Version $v.'"

grep -q -F "\"version\": \"$v\"" .claude-plugin/plugin.json ||
  fault .claude-plugin/plugin.json "no line \"version\": \"$v\""

# The marketplace manifest need not name a version. Where it does, each one
# is this one.
other=$(grep '"version"' .claude-plugin/marketplace.json | grep -c -v -F "\"version\": \"$v\"")
[ "$other" -eq 0 ] || fault .claude-plugin/marketplace.json "$other \"version\" not set to \"$v\""

top=$(awk '
  /^```/ { fence = !fence }
  !fence && index($0, "## [") == 1 && index($0, "## [Unreleased]") != 1 { print; exit }' CHANGELOG.md)
case $top in
  "## [$v] - "[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
    [ -n "$(entry_body)" ] || fault CHANGELOG.md "the entry for $v is empty"
    ;;
  "## [$v]"*) fault CHANGELOG.md "the heading of $v has no date: '$top'" ;;
  *) fault CHANGELOG.md "the top entry is '${top:-none}', not '## [$v] - <date>'" ;;
esac
left=$(awk '
  /^```/ { fence = !fence }
  !fence && index($0, "## [") == 1 { on = index($0, "## [Unreleased]") == 1; next }
  on && !/^[ \t]*$/ { n++ }
  END { print n + 0 }' CHANGELOG.md)
[ "$left" -eq 0 ] || fault CHANGELOG.md "$left lines are still under ## [Unreleased]"
# The file ends with one link line per version. Where it has any, it has this one.
if grep -q '^\[[0-9][0-9.]*\]: ' CHANGELOG.md; then
  grep -q -F "[$v]: " CHANGELOG.md || fault CHANGELOG.md "no link line for [$v]"
fi

# The download line, and any release asset the README names by its tag.
urls=$(grep -o 'raw\.githubusercontent\.com/[^ )`"]*/bin/card' README.md)
if [ -z "$urls" ]; then
  fault README.md 'no download line for bin/card'
else
  other=$(printf '%s\n' "$urls" | grep -v -F "/v$v/bin/card" | sed 's|.*/\([^/]*\)/bin/card$|\1|' | sort -u | tr '\n' ' ')
  [ -z "$other" ] || fault README.md "the download line names ${other% }, not v$v"
fi
other=$(grep -o 'releases/download/v[0-9][^/ )`"]*' README.md | grep -v -x -F "releases/download/v$v" | sed 's|.*/||' | sort -u | tr '\n' ' ')
[ -z "$other" ] || fault README.md "a release asset is named at ${other% }, not v$v"

[ "$bad" -eq 0 ] || exit 1
echo "release-check: $v ok"
