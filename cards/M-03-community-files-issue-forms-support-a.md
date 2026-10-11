---
id: M-03
title: Community files: issue forms, support, a map of the docs
size: S
depends:
done: false
---

## Read
- docs/development/plan-0.2.0.md (the settings only the maintainer can change are listed there, not here)
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- SECURITY.md
- .github/ISSUE_TEMPLATE/
- .github/pull_request_template.md
- README.md#contributing
- docs/development/README.md
- cards/REVIEW.md

## Touch
- .github/ISSUE_TEMPLATE/bug.yml (new) replaces bug.md
- .github/ISSUE_TEMPLATE/idea.yml (new) replaces idea.md
- .github/ISSUE_TEMPLATE/bug.md (removed)
- .github/ISSUE_TEMPLATE/idea.md (removed)
- .github/ISSUE_TEMPLATE/config.yml
- SUPPORT.md (new)
- docs/README.md (new)
- CONTRIBUTING.md
- README.md (the Contributing section, and a link to docs/README.md)
- test/cases/02-plugin.sh

## Tests
- test_issue_forms_ask_for_what_a_bug_needs
- test_docs_index_lists_every_file_under_docs
- test_contributing_walks_a_first_change_through_a_card
- test_repository_has_the_files_a_stranger_looks_for

## Acceptance
- The bug form asks, as required fields: what happened and what was expected, the output of `card version`, of `git --version` and of `claude --version`, the system, and whether the plugin is installed from the marketplace or loaded with `--plugin-dir`. It asks for the session log of the card where there is one, and says what not to paste: a transcript, a token, a private path.
- The idea form asks what the person was doing when they wanted it and what they did instead, before it asks for a solution, and links `docs/development/later.md` and the roadmap so that a known idea is found first.
- `config.yml` turns blank issues off and links the security policy and SUPPORT.md.
- SUPPORT.md says where a question goes, what the maintainer does not do (no support for a harness other than Claude Code, no private help), and what to include.
- `docs/README.md` is a map of every file and directory under `docs/`: one line each, in the order a newcomer should read them, and which are records that are never edited. A test fails when a tracked file under `docs/` at the first two levels is in no line of it.
- CONTRIBUTING.md gains a section that walks a first change through the project's own loop, with the commands as typed: fork, `/workdeck:quick` or a card, the gates, the pull request, what the reviewer and the maintainer look at. It says what a contributor without Claude Code can still do, and how.
- CONTRIBUTING.md says how decisions are made in a project with one maintainer: who merges, what an adversarial review is here, and where a decision is recorded.
- `test_repository_has_the_files_a_stranger_looks_for` also requires SUPPORT.md, CODE_OF_CONDUCT.md, LICENSE and docs/README.md.

## Out of scope
- Turning on Discussions, the homepage, the social preview, branch rules. They are settings; the plan lists them for the maintainer.
- A code of conduct change, a contributor agreement, a funding file.
- The website's contributing page. The site's cards own it and link here.

## Notes
- GitHub issue forms are YAML with a fixed schema; read the current documentation page for the keys before writing, and name it in the session log. A form that does not parse is shown as no template at all, with no error.
- A test cannot parse YAML with the tools the repository allows. It can hold that each required question is present and marked required on the line GitHub's schema puts it; say in the test's comment that this is form and not a parse.
- The files removed are in `Touch` so that the scope gate lets them go.
