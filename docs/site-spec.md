# The WorkDeck website

A specification for the project's website. It is written to be planned with `/workdeck:plan docs/site-spec.md`: each second-level heading asks for work, except those the last section lists. The release plan it belongs to is [`development/plan-0.2.0.md`](development/plan-0.2.0.md).

Date: 2026-10-11
Status: written by the session that wrote the release plan, on the maintainer's instruction to plan "a very comprehensive website". Not reviewed. The maintainer approves it by merging the pull request that adds it, and the plan reviewer reads it again when it is planned.

## Purpose and audience

The README answers "what is this" for someone already on the repository. The website has to do three things the README cannot do well in one page.

- A developer who has never heard of WorkDeck decides in two minutes whether it is for them, and can see a real card, a real session log and a real pull request before installing anything.
- A user in the middle of a session finds the exact behavior of a command, a skill, a gate or a hook, and what to do when it stops.
- Someone evaluating the method, not the tool, can read how the project was built with itself, with the failures left in.

It is not a marketing site. Every claim on it is one the repository can show, and where something is not measured the page says so in the same size of type as the rest.

## Constraints

- **Static, and built with what the repository already needs.** Pages are hand-written HTML with one stylesheet and one small script. There is no site generator, no package manager and no build step that needs more than bash, git and the standard tools. The website must not make `make test` need anything new.
- **One source for anything that can drift.** The command list, the version, the changelog, the configuration keys and their defaults, and the figures of the evidence and specimen pages are not typed into a page. A script writes them into marked regions of the pages from `card help`, `bin/card`, `CHANGELOG.md`, `docs/reference.md`, `docs/evidence.md` and `scripts/specimen-stats.sh`. The generated regions are committed, and a test fails when they are stale.
- **No request to anyone else.** No analytics, no font or script from another host, no embedded video, no cookie. A test fails on any `http` URL in a `src`, in a stylesheet or in a `link` that loads a resource.
- **Works without the script.** Every page reads in full with JavaScript off. The script adds search, the copy buttons, the theme switch and the deck demo, and nothing else depends on it.
- **Accessible.** One `h1` per page and no skipped heading level, a skip link, landmarks, visible focus, text contrast of at least 4.5 to 1 in both themes, no information carried by color alone, alternative text or an empty `alt` on every image, `prefers-reduced-motion` respected. The parts a script can check are checked by a test.
- **Small.** A page with its stylesheet and script is under 100 kB before compression, the hero image aside. A test holds the budget.
- **Relative links only,** so the site works under a project path, under a custom domain later, and opened from disk.
- **The rule on other projects.** `cards/REVIEW.md` allows a reference to another project only in the README's comparison section. The comparison page needs the same exception, and the card that builds it amends the rule in the same pull request.

## Structure and hosting

The site lives in `site/` and is deployed to GitHub Pages by a workflow of its own, on a push to the main branch that changes `site/` or one of the sources above. The workflow builds nothing: it runs the stale check, the site's tests and the link check, and uploads the directory. Its actions are pinned to commits and its permissions are the least Pages needs.

Turning Pages on, and setting the repository's homepage to the site, are settings only the maintainer can change. The card that adds the workflow ends by listing them, and the workflow's first run is checked by hand.

Every page shares one header, one footer and one navigation, kept the same by the build script and not by copying. The header shows the released version and says, until 0.2.0 is tagged, which parts of the site describe something not yet released.

The site also has: a `404.html`; a `sitemap.xml` and a `robots.txt`; a feed of releases; a card image for links shared elsewhere, and a favicon, both drawn as SVG in the repository; a print stylesheet; and an `llms.txt` at the root, a plain index of the pages and of the raw markdown they come from, for an agent that is asked about WorkDeck.

## Visual design

The site should look like the tool: plain, exact and calm. A card is the central object and should be drawn as one, the same way on every page: its front matter, its sections, its state.

- One type family for text and one monospace, both from the reader's system. No downloaded font.
- A light and a dark theme from `prefers-color-scheme`, with a switch that is remembered, defined once as custom properties.
- Diagrams are inline SVG drawn for the site, not screenshots: the loop, the states of a card and what moves it from one to the next, a specification becoming an outline becoming cards, and where each hook and gate sits in a session.
- Terminal output is real output, in text and not in an image, with a copy button on every command a reader would type and none on output.
- The first card of the build settles the look on two pages, the home page and one reference page, and the maintainer approves it before the rest are built.

## Home

What WorkDeck is in one sentence and who it is for in another. Then, without scrolling far: a real card beside the pull request it produced, the install lines, and the loop as a diagram. Below that, the four things the method holds to, each with the evidence for it or the words "not measured": a session sized to fit, a scope that a script checks, a review by an agent that did not write the code, one pull request that a person merges.

It says what WorkDeck is not and does not do, as plainly as what it does, and links the limits page.

## Getting started

Three pages, each ending where the next begins.

- **Install:** the plugin from the marketplace, `card` alone for people and CI with the checksum check, the requirements, and how to tell that it worked.
- **First card:** `/workdeck:init` on a repository, then one change through `/workdeck:quick`, with what the user types, what they are asked and what they see, taken from a real run. It ends at a merged pull request.
- **First plan:** a specification through `/workdeck:plan`, the outline and its review, and the first row through `/workdeck:next-card`, using the planned example deck of the repository.

Each page says what it costs: the prompts to expect, the tokens a session of each size has measured, and what was written into the repository.

## Concepts

One page each, short, with the diagram that belongs to it: the card and its sections; the deck and how state is read from branches; sizes and budgets, and what growth measures; the gates; the reviewer and `REVIEW.md`; the session log; the outline and its rows; what a skill is and why the user types each one.

Every page ends with "where this is decided", a link to the section of the design that holds the rule.

## Guides

Task pages for what people will actually hit. Each starts with the situation, gives the commands, and says what can go wrong.

- Adopting WorkDeck on a codebase that already exists, and on one already set up with an earlier version.
- Writing a good card by hand, with three real cards taken apart: one that held, one that split, one whose scope grew.
- Writing a specification that plans well, and reading an outline before approving it.
- When a session stops: each stop of each skill, what it means and the way out. The README's "When it stops" is the source.
- Splitting a card, review fixes on an open pull request, and a card that is blocked on a person.
- Running `card` in CI, pinned to a release.
- Tuning budgets from `card stats`.
- Using it in a team today, and what 0.3 will change.

## Reference

Generated where it can be. One page per command of `card` with its arguments, output, exit codes and an example; one per skill with its steps as the skill file has them; the configuration file; the card, log and outline formats; the hooks; the two agents; the permission entries init writes, each with what it allows and why the deny list is as long as it is; the errors, by message, so that a message pasted into the search finds its page.

The reference names the version it describes on every page.

## The deck demo

One interactive page, and the only one where the script does real work. It shows a small deck, the planned example, and lets a reader step through what happens to it: a card started, handed off, merged; a row written into a card; a split; a blocked card. At each step it shows what `card list` and `card next` would print, which the build takes from real runs of `card` on that deck in each state, not from a second implementation of the state rules in JavaScript.

With the script off, the page shows the same steps as a sequence of sections.

## Evidence and limits

The measurements, from `docs/evidence.md`: what was measured, on how many sessions, and what was not. The trial of 0.2 when it exists. The known limits, the claims about Claude Code that the designs mark unverified, and the things left out on purpose.

This page and the home page must never disagree. A test holds that every figure on the home page is one this page generates.

## Built with itself

The specimen page as a section of the site: how this repository was run as a deck, with the figures the specimen script prints, a timeline of the releases drawn from the changelog and the tags, and a way to browse the project's own cards, logs and review records by card id. It links each to the file on the repository and to the pull request.

It includes the failures, as the specimen page does.

## Comparison, FAQ and roadmap

- **Comparison:** the README's section, kept honest in the same way: what each alternative does better is said first.
- **FAQ:** the README's questions and those the issue tracker has produced.
- **Roadmap:** what 0.2 is, what 0.3 will be with a summary of its design, and what is deliberately not planned.
- **Changelog:** generated, with a link to each release and its assets.

## Search

A search over every page that runs in the reader's browser from an index the build writes, with no service behind it. It finds a command by name, an error by its message and a configuration key by its name before it finds prose. Without the script, the search page is the index: every page with its headings.

## Tests and upkeep

The site is held the way the rest of the repository is. Shell tests in `test/`, run by `make test`, with no new tool:

- every page has a title, a description, the shared header and footer, one `h1` and its landmarks;
- every relative link and every anchor resolves, and no page is unreachable from the navigation;
- every command in `card help` and every skill in `skills/` has a reference page, and no reference page names one that is gone;
- the generated regions are current;
- the constraints above that a script can check: no outside request, the size budget, alternative text, heading order;
- the version on the site is the version `card version` prints, or the page says it describes what is not released.

The Pages workflow may also run a browser-based audit of performance and accessibility as a report. It is not a gate and adds nothing to `make test`.

A change to a skill, to `card help` or to the changelog that leaves the site stale fails the suite, so the site is updated in the pull request that made it stale. CONTRIBUTING.md says so.

## Launch

The site goes live when 0.2.0 is released, not before: until then it would describe a planner that a user cannot install as released. The last card of the build runs after the release card. It removes the "not yet released" wording, checks every page against the released version, and ends with the list of what the maintainer does by hand: turn Pages on, set the homepage, and look at the live site on a phone.

## Out of scope

- A blog, a newsletter, comments, accounts, a hosted playground that runs `card`.
- Translations.
- Documentation for 0.3 beyond the roadmap page.
- A custom domain. The links are relative so that one can be added without a change.

## Not for planning

"Purpose and audience", "Constraints" and "Out of scope" ask for no card of their own: every card is held to them. The outline lists them, and this section, under `Not planned`.
