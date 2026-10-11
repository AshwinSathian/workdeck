# Development records

How WorkDeck 0.1 was built, how 0.2 was planned, and the scope of 0.3. None of this is needed to use it; the design is in [`../design.md`](../design.md).

| File | What it is |
|---|---|
| [`plan-0.1.md`](plan-0.1.md) | The build plan, written by the coding agent for the maintainer before any code, and kept as written. "I" in it is the agent and "you" is the maintainer. Its section G was added after an adversarial review of the plan. |
| [`findings.md`](findings.md) | What turned out wrong or awkward while building, with the evidence and what was decided. Sixteen findings, three of them independent reviews. |
| [`later.md`](later.md) | Ideas that were left out of 0.1 on purpose. |
| [`scope-0.2.md`](scope-0.2.md) | The scope of 0.2, the planner: what it is, who it is for, what is out and the open risks. One page, approved by the maintainer before the design was written. |
| [`../design-0.2.md`](../design-0.2.md) | The design of 0.2. It adds to the 0.1 design and is numbered the same way. Its section 21 is the order the 0.2 cards follow. |
| [`review-0.2.md`](review-0.2.md) | Two adversarial reviews of the 0.2 scope and design, each by an agent that did not write what it reviewed, a third pass on the amendments, a fourth made while the deck was written, and a fifth on what the spike asked for. Each finding has its evidence and what was decided. |
| [`spike-0.2.md`](spike-0.2.md) | The spike before the 0.2 build: a draft of the plan skill and of the plan reviewer, run by hand on two specifications before any check was written. What the outlines got wrong, whether a card can be written from one row, and whether the outline format holds. The drafts and the outlines are in [`spike-0.2/`](spike-0.2/). |
| [`scope-0.3.md`](scope-0.3.md) | The scope of 0.3, teams: claiming a card, worktrees and parallel sessions. What it is, who it is for, what is out and the open risks. One page, written before the design and amended from the design's reviews. It ends with six decisions, taken by the session that wrote it on the maintainer's instruction. |
| [`../design-0.3.md`](../design-0.3.md) | The design of 0.3. It adds to the designs of 0.1 and 0.2 and is numbered the same way. One command, `card claim`, starts a card. Decided by the session that wrote it, on the maintainer's instruction, after two adversarial reviews; its section 22 has the eight decisions and section 21 the order of the build. |
| [`review-0.3.md`](review-0.3.md) | The reviews of the 0.3 scope, by agents that did not write it, with each finding, what was decided and the six decisions; and two passes on the design, with the eight decisions on its open points and what they amended in the scope. |

The repository's own cards are in [`../../cards/`](../../cards/) and its session logs in [`../../log/`](../../log/). WorkDeck 0.1 was built card by card with its own card files, gates and logs, driven by hand in one long agent session. Those logs record `unknown` for the measured token fields, because one session's growth does not describe any single card. The exception is DOC-02, which the maintainer ran through the plugin and merged as pull request 1. See [`../evidence.md`](../evidence.md) for the measurements.
