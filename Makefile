.PHONY: test lint links check bench validate release-check

# The whole suite, under the system bash (3.2 on macOS).
test:
	/bin/bash test/run.sh

lint:
	shellcheck -x -s bash bin/card hooks/*.sh scripts/*.sh test/*.sh test/cases/*.sh test/stubs/*

# Every relative link and anchor in the markdown files. No network.
links:
	/bin/bash scripts/check-links.sh

# What to run before a pull request.
check: lint test links

# Wall time the post-tool-use hook adds to a tool call.
bench:
	/bin/bash scripts/bench-hook.sh

# Is the tree ready to be tagged? make release-check VERSION=0.2.0
# docs/releasing.md says when to run it.
release-check:
	/bin/bash scripts/release-check.sh $(VERSION)

# Needs Claude Code on PATH.
validate:
	claude plugin validate --strict .
	claude plugin validate --strict .claude-plugin/plugin.json
	claude plugin validate --strict agents
	claude plugin validate --strict skills
