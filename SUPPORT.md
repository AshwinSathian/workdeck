# Support

WorkDeck has one maintainer, who answers in the open and when there is time. This page says where to ask, what to send, and what not to expect.

## Where a question goes

- **A question about using it.** Read the [README](README.md) and [`docs/reference.md`](docs/reference.md) first: the FAQ, "Known limits" and "When it stops" in the README answer most. If they do not, [open an issue](https://github.com/AshwinSathian/workdeck/issues/new/choose) with the "Idea or question" form and say in the title that it is a question. A question the docs should have answered is a fault in the docs, and is treated as one.
- **Something that went wrong.** [Open an issue](https://github.com/AshwinSathian/workdeck/issues/new/choose) with the Bug form.
- **A security problem.** Not an issue: report it privately, as [`SECURITY.md`](SECURITY.md) says.
- **A change you want to make.** [`CONTRIBUTING.md`](CONTRIBUTING.md) walks a first change through.

There is no chat, no mailing list and no forum. Everything is an issue or a pull request in this repository, so that the next person can find the answer.

## What the maintainer does not do

- **No support for a harness other than Claude Code.** The skills, the hooks and the reviewer agent are a Claude Code plugin. `card` is plain bash and runs anywhere bash 3.2 does; a problem with `card` alone is welcome whatever started it.
- **No private help.** Not by email, and not by direct message. A question asked in private is answered by a pointer to this page.
- **No support for native Windows shells.** `card` needs bash and the usual Unix tools.
- **No promise of a date.** A reply usually comes within a week. Only the latest release gets fixes.
- **No help with a deck's content.** What a card should say, and how a project should be cut, are yours to decide. A row the planner cut badly is a bug report, with the specification and the outline.

## What to include

The Bug form asks for these, and a question is answered sooner with them too:

- What you ran, the exact command or skill, and what it printed.
- What you expected.
- The output of `card version`, `git --version` and `claude --version`, and your system.
- Whether the plugin is installed from the marketplace or loaded with `--plugin-dir`.
- The session log of the card, from your log directory, where there is one.

Do not paste a session transcript, a token or a key, or a private path. A transcript holds everything the session read, and an issue is public.
