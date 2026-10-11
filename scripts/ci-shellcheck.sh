#!/usr/bin/env bash
# ci-shellcheck.sh: fetch one version of shellcheck for a CI runner.
#
# Usage: scripts/ci-shellcheck.sh <directory>
#
# Downloads the release archive for this system into the directory, checks it
# against the checksum below, unpacks it, and prints the directory that holds
# the `shellcheck` file, for the workflow to add to PATH.
#
# Both systems get the same version, and it is the one that
# `brew install shellcheck` gives a laptop today, so that `make lint` says
# the same thing everywhere. It is a file and not an action, so nothing updates it: change
# the version and both checksums together, from the release page of
# koalaman/shellcheck.
#
# This is the one script here that uses the network. The workflows run it;
# the suite and `card` do not.
set -eu
VERSION=0.11.0

[ "$#" -eq 1 ] && [ -d "$1" ] || { echo 'usage: ci-shellcheck.sh <directory>' >&2; exit 2; }
case "$(uname -s).$(uname -m)" in
  Darwin.arm64) arch=darwin.aarch64 sum=339b930feb1ea764467013cc1f72d09cd6b869ebf1013296ba9055ab2ffbd26f ;;
  Linux.x86_64) arch=linux.x86_64 sum=b7af85e41cc99489dcc21d66c6d5f3685138f06d34651e6d34b42ec6d54fe6f6 ;;
  *) echo "ci-shellcheck: no archive is named here for $(uname -s).$(uname -m)" >&2; exit 1 ;;
esac

cd "$1"
curl -fsSL -o shellcheck.tar.gz "https://github.com/koalaman/shellcheck/releases/download/v$VERSION/shellcheck-v$VERSION.$arch.tar.gz"
echo "$sum  shellcheck.tar.gz" | shasum -a 256 -c - >&2
tar -xzf shellcheck.tar.gz
printf '%s\n' "$PWD/shellcheck-v$VERSION"
