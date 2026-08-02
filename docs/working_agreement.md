# Working Agreement

How we pair on this project — XP and Kanban practices, adapted for a human + Claude Code pairing, revisited as we learn. Last updated 2026-08-01.

## Roles

- **Product / customer** (Rob): writes and prioritizes stories, final say on the queue and on big design pivots.
- **Implementer + architecture partner** (Claude): proposes framework/architecture options across the stack (presentation, persistence, auth, deployment), implements per the flow below, pairs throughout.

## Flow (Kanban)

- Pull system. WIP = 1 story at a time, optionally + 1 architecture spike running in parallel — Claude briefs the product owner before starting a spike.
- Flow is tracked in `queue.md` at the repo root ("queue" chosen over "backlog" — matches pull-system vocabulary). **Not yet in place** — pending a story-tracking tool Rob is evaluating separately.

## Stories

"NYT Headline" format: a short, memorable title, a description, and bulleted **examples** (deliberately not "acceptance criteria").

## TDD Loop

- Stories are kept small enough to be the natural unit of work-in-progress.
- **Story kickoff**: before implementation starts, we review the story together, at least with a quick once-over — Claude can ask clarifying questions or raise examples/edge cases it's thought of; Rob can probe particulars too.
- Within a story, Claude chooses the batching strategy — write all tests for the story up front then implement, or loop through smaller batches of test-then-implementation — whichever seems more efficient for that particular story.
- Each story gets a visible **to-do list** — both tests and refactorings, not just tests — kept visible regardless of which batching strategy is used.
- No implementation without a failing spec.
- No fixed review cadence beyond the kickoff. Rob also reviews on demand: "show me the new tests," "show me the current design of X."

## Docs

- `docs/adr/` — lightweight architecture decision log: context, options considered, decision, why.
- This file — update it as the agreement itself evolves.

## Refactoring & Design Review

- Small in-flow refactors happen naturally as part of red-green-refactor.
- Big design pivots (e.g. swapping persistence approach) are always flagged before acting.
- Periodic design-smell check-ins even though thorough tests reduce the need: Claude proactively flags when a to-do list starts resembling a previous story's (a signal of possible copy-paste, maybe worth a pattern like Strategy) rather than waiting to be asked.
