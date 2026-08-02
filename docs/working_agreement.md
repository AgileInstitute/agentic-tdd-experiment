# Working Agreement

How we pair on this project — XP and Kanban practices, adapted for a human + Claude Code pairing, revisited as we learn. Last updated 2026-08-01.

## Roles

- **Product / customer** (Rob): writes and prioritizes stories, final say on the queue and on big design pivots.
- **Implementer + architecture partner** (Claude): proposes framework/architecture options across the stack (presentation, persistence, auth, deployment), implements per the flow below, pairs throughout.

## Flow (Kanban)

- Pull system. WIP = 1 story at a time, optionally + 1 architecture spike running in parallel — Claude briefs Rob before starting a spike. Spikes are written into `queue.md` as ordinary stories (headline tagged `(spike)`, e.g. `3.4 Evaluate AWS deployment options (spike)`) since they usually fit within an existing theme; what makes them different is that they can run alongside a story rather than needing their own WIP slot.
- Flow is tracked in `queue.md` at the repo root ("queue" chosen over "backlog" — matches pull-system vocabulary, even though the numbering below isn't strict priority order). Format:
  - Grouped into **themes** (`## N. Theme name`, e.g. "Persistence," "Cloud Deployment," "Backups"), numbered in creation order.
  - Stories numbered within their theme (`### N.M Headline`, e.g. `5.2 Importing photo information`). Numbers are conversational handles for picking and discussing stories, not permanent IDs — reused/reassigned to reflect current priority within a theme as things shift.
  - Each story: headline, description in NYT-headline format (below), then two checkboxes — `- [ ] started` and `- [ ] done`. "Done" means we believe all the story's tests are written and passing — refactoring happens continuously as we go, not as a separate gate. Check the box, then commit.
  - No fixed archiving cadence: work stories one at a time, mark done inline as we go; occasionally (not per-story) retrospect together on what's done and cut/paste those entries — same theme/story structure — into `story_archive.md`, created when first needed.

## Stories

"NYT Headline" format: a short, memorable title, a description, and bulleted **examples** (deliberately not "acceptance criteria"). The headline implies the goal; the description describes the capability. No Connextra template ("As a &lt;persona&gt;, I want &lt;ability&gt;, so that &lt;goal&gt;") — if a specific persona matters, name them directly in the headline or description instead (e.g. "Pete the Power User," "Bob the Beginner").

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
