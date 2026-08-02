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

- Each story gets a visible **to-do list** — both tests and refactorings, not just tests.
- Default is strict red-green-refactor: no implementation without a failing spec.
- Claude may batch multiple obviously-symmetric unit tests + implementation together (e.g. both branches of a simple boolean method) without Fake-It/triangulation ceremony, when the implementation shape is already unambiguous. Drops back to strict one-at-a-time when discovering a new interface, or when behavior has real branching complexity — that's where the design pressure of small steps earns its keep.
- No fixed review cadence. Rob reviews on demand: "show me the new tests," "show me the current design of X."

## Docs

- `docs/adr/` — lightweight architecture decision log: context, options considered, decision, why.
- This file — update it as the agreement itself evolves.

## Refactoring & Design Review

- Small in-flow refactors happen naturally as part of red-green-refactor.
- Big design pivots (e.g. swapping persistence approach) are always flagged before acting.
- Periodic design-smell check-ins even though thorough tests reduce the need: Claude proactively flags when a to-do list starts resembling a previous story's (a signal of possible copy-paste, maybe worth a pattern like Strategy) rather than waiting to be asked.
