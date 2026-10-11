# Releasing

The checklist a maintainer follows to release a version. A pushed tag builds the release; everything before the tag is done by hand, on purpose.

A release is two things, and they do not arrive together:

- **The plugin.** A person who installed it receives the main branch as it is when `version` in `.claude-plugin/plugin.json` changes there. That happens when the version commit merges, before any tag exists.
- **The `card` file.** A person or a CI workflow that downloads `card` names a tag in the URL. That file exists when the tag is pushed, and the release page with its checksum when the workflow has finished.

So the merge of the version commit is the release for plugin users, and the tag follows it at once.

## What stays by hand

In this order.

1. **The decision to tag.** The maintainer makes it, from the record the release's card names. For 0.2.0 that is the trial record in [`evidence.md`](evidence.md), and the card is P-24.
2. **A dry run of the workflow**, where it has not run since `release.yml` last changed. See [A dry run](#a-dry-run).
3. **The version commit.** One card changes the version everywhere, as its last commit before the tag: `bin/card` (the header comment and `VERSION`), `.claude-plugin/plugin.json`, the heading and the link line of the entry in `CHANGELOG.md`, and the README's download line. Before its handoff, run:

   ```
   scripts/release-check.sh 0.2.0     # or: make release-check VERSION=0.2.0
   ```

   It prints one line for each file that names another version, and for anything left under `## [Unreleased]`. It must print `release-check: 0.2.0 ok`.
4. **The merge** of that card's pull request. Read the main branch, not only the diff: plugin users receive all of it.
5. **The tag**, on the merge commit, straight after the merge. Until it exists the README's download line names a tag that is not there.

   ```
   git checkout main && git pull --ff-only
   scripts/release-check.sh 0.2.0
   git tag -a v0.2.0 -m "WorkDeck 0.2.0"
   git push origin v0.2.0
   ```

   The tag is `v` and three numbers. The workflow stops at its check for any other form, so a tag such as `v0.2.0-rc1` builds nothing.
6. **Watching the run**: `gh run watch`, or the Actions tab. See [The first run](#the-first-run).
7. **The repository's homepage**, description and topics, where the release changes what they should say. They are settings, and no workflow changes them.
8. **Announcing.** Nothing is posted anywhere by the workflow.

## What the workflow does

[`.github/workflows/release.yml`](../.github/workflows/release.yml) runs on a pushed tag `v*`, in two jobs.

The first job, `check`, runs on macOS and on Ubuntu, with read access only:

1. What `ci.yml` checks, on the tagged commit: `make lint`, `make test`, `card lint` on this repository's deck, the link check, `make validate`, and on Ubuntu the suite again with awk as mawk and as gawk. A tag on a branch never went through `ci.yml`, so none of it is left out.
2. `scripts/release-check.sh` against the tag's name without its `v`. This is the release-check of the version commit, run again where nobody can skip it.

The second job, `publish`, runs only when both systems passed. It is the only one that may write:

1. It copies `bin/card` as tagged to `card`, and writes its SHA-256 checksum to `SHA256SUMS`.
2. It cuts the release notes out of `CHANGELOG.md` with `scripts/release-check.sh --notes`: the entry of that version, without its heading. Nobody writes the notes by hand, so what the release page says is what the changelog says.
3. It makes a build provenance attestation for `card`: a signed statement of which repository, workflow, commit and tag produced the file. The attestation is stored by the host, and a copy is published as `card.sigstore.json`.
4. Last, it creates the release for the tag, titled `WorkDeck <version>`, with three assets: `card`, `SHA256SUMS` and `card.sigstore.json`.

A failure at any step before the last publishes nothing. One thing can be left behind: if the last step fails, the attestation of step 3 is already stored. It is a true statement about a file that was built, and it does no harm; the next run stores another.

The workflow does not deliver the plugin, does not change a version, does not make or move a tag, and does not touch the main branch.

Every action in it is pinned to a commit, with the version in a comment. The attestation step was written from the host's page [Using artifact attestations](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations) and from the README of `actions/attest` at v4.2.2, both read on 2026-10-11. That README asks for three permissions; the job grants two, `id-token: write` and `attestations: write`, and leaves out `artifact-metadata: write`, which the action uses only for a storage record of a container image. Whether two are enough is not known until the step has run once: the dry run below is where to find out, and if it shows the action needs the third, add it to the `publish` job and nowhere else.

## A dry run

Started by hand, the workflow does everything but the two steps that need a tag: the release check, and the release itself. It runs the checks, builds `card` and `SHA256SUMS`, and makes and stores the attestation.

```
gh workflow run release.yml --ref main
gh run watch
```

Do this before the version commit merges, and again after any change to `release.yml`. The reason is that a tag cannot be used to test the workflow. The workflow file is read from the tagged commit, so a fault in it that the first real run finds cannot be fixed for that tag: a fix on the main branch changes nothing for a run started again from the Actions tab, and the version is spent. A dry run finds the same fault with no tag made.

A dry run stores an attestation for the `card` of the commit it ran on. That is a true statement about that file, and `gh attestation verify` accepts such a file as built by this workflow. It publishes nothing.

## A release from a branch

The tag is normally on the main branch. [`design-0.2.md`](design-0.2.md), section 22, decision 1, names the case where it is not: the main branch holds a reachable half of a later feature when the maintainer decides to tag. Then:

1. Cut a branch at the last commit of the version being released, and pick the fixes onto it.
2. Make the version commit on that branch, run `scripts/release-check.sh`, and tag there.
3. Push the branch and the tag.

The workflow does not ask which branch the tag is on: it checks out the tagged commit and builds from it.

This gives a clean `card` file to a CI workflow and nothing else. The marketplace serves the plugin from the main branch, so `version` is not changed on the main branch while it holds the half-built feature. Finish the half or take it out first, then change the version there.

## Withdrawing a bad release

A tag that people have fetched cannot be taken back, and a CI workflow may already name it. So a bad release is replaced, not repaired:

1. Say so on the release page first: edit its notes with `gh release edit v0.2.0 --notes-file <file>`, with what is wrong and which version fixes it, and mark it with `--prerelease` so that it is not shown as the latest.
2. Fix the fault through a card, and release a new version, 0.2.1, in the way this page describes. Plugin users receive the fix when its version commit merges.
3. Only where the file itself is harmful, remove it: `gh release delete v0.2.0` removes the page and its assets, and leaves the tag. Leave the tag too, unless the tagged tree is the harm: a deleted tag breaks every workflow that names it, and that is the reason to delete it or not.

Do not move a tag to another commit. The checksum and the attestation of the first build would then describe a file the tag no longer gives.

When the workflow failed and nothing was published, nothing needs withdrawing, but plugin users already have the version and the README names a tag with no release page. If the failure was the runner's, run the failed jobs again from the Actions tab. If the tagged commit is at fault, the workflow file among it, running it again fails the same way, because the run reads everything from the tagged commit: the version is spent. Fix the cause on the main branch through a card and release the next version at once.

## The first run

The workflow was written and tested by reading it: the card that added it pushed no tag and started no run. Its first real run is the release of 0.2.0, card P-24, after [a dry run](#a-dry-run). Watch that run and check, in order:

- Both `check` jobs pass, and the release check prints `release-check: 0.2.0 ok`.
- The attestation step passes with the two permissions it has.
- The release page has the three assets, and its notes are the entry of `CHANGELOG.md`.
- A download checks out, from a clean directory:

  ```
  gh release download v0.2.0 --repo AshwinSathian/workdeck
  shasum -a 256 -c SHA256SUMS
  gh attestation verify card --repo AshwinSathian/workdeck --signer-workflow AshwinSathian/workdeck/.github/workflows/release.yml
  cmp card <(git show v0.2.0:bin/card)
  ```

  The last line, run in a checkout, shows that the asset is the tagged file.
- The README's download line fetches the same bytes: `curl -fsSL <the line's URL> | shasum -a 256` gives the checksum in `SHA256SUMS`.

Whatever differs from this page is fixed in this page, through a card, with what the run showed.

## Earlier releases

0.1.0 to 0.1.3 were released by hand. 0.1.0 has a release page with no assets, and 0.1.1 and 0.1.2 have one with `card` and `card.sha256`. `v0.1.3` is a tag with no release page: `gh release list` shows none for it. Nothing here builds one for a past tag.
