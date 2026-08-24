# Working Agreement

How we pair on this project — XP and Kanban practices, adapted for a human + Claude Code pairing, revisited as we learn. Last updated 2026-08-24.

## Roles

- **Product / customer** (Rob): writes and prioritizes stories, final say on the queue and on big design pivots.
- **Implementer + architecture partner** (Claude): proposes framework/architecture options across the stack (presentation, persistence, auth, deployment), implements per the flow below, pairs throughout.

## Flow (Kanban)

- Pull system. WIP = 1 story at a time, optionally + 1 architecture spike running in parallel — Claude briefs Rob before starting a spike. Spikes are written into `story_map.md` as ordinary stories (headline tagged `(spike)`, e.g. `3.4 Evaluate AWS deployment options (spike)`) since they usually fit within an existing theme; what makes them different is that they can run alongside a story rather than needing their own WIP slot.
- Flow is tracked in `story_map.md` at the repo root (renamed 2026-08-13 from `queue.md`; not yet a positionally-prioritized story map — no release/priority axis yet, just flat themes/stories — revisit once scope selection for a Minimal Lovable Product matters). Format:
  - Grouped into **themes** (`## N. Theme name`, e.g. "Persistence," "Cloud Deployment," "Backups"), numbered in creation order.
  - Stories numbered within their theme (`### N.M Headline`, e.g. `5.2 Importing photo information`). Numbers are conversational handles for picking and discussing stories, not permanent IDs — reused/reassigned to reflect current priority within a theme as things shift.
  - Each story: headline, description in NYT-headline format (below), then two checkboxes — `- [ ] started` and `- [ ] done`. "Done" means we believe all the story's tests are written and passing — refactoring happens continuously as we go, not as a separate gate. Check the box, then commit.
  - No fixed archiving cadence: work stories one at a time, mark done inline as we go; occasionally (not per-story) retrospect together on what's done and cut/paste those entries — same theme/story structure — into `story_archive.md`, created when first needed.

## Stories

"NYT Headline" format: a short, memorable title, a description, and bulleted **examples** (deliberately not "acceptance criteria"). The headline implies the goal; the description describes the capability. No Connextra template ("As a &lt;persona&gt;, I want &lt;ability&gt;, so that &lt;goal&gt;") — if a specific persona matters, name them directly in the headline or description instead (e.g. "Pete the Power User," "Bob the Beginner").

## TDD Loop

- Stories are kept small enough to be the natural unit of work-in-progress.
- **Story kickoff**: before implementation starts, we review the story together, at least with a quick once-over — Claude can ask clarifying questions or raise examples/edge cases it's thought of; Rob can probe particulars too.
- Within a story, Claude chooses the batching strategy — write all tests for the story up front then implement, or loop through smaller batches of test-then-implementation — whichever seems more efficient for that particular story, subject to the cluster cap below.
- **Triangulation cluster cap**: a "cluster" is a batch of tests that tightly triangulate the same behavior (e.g. TextRepairer's good text / bad text / good European text / multiple bad-byte cases), shown together before implementing. Clusters follow their natural grouping — never split one just to dodge the cap. The cap is currently a dozen specs:
  - **A single cluster, at or under the cap**: no pause. Show it, then implement it directly.
  - **Everything else** — a cluster over the cap, or more than one cluster shown together in the same pass (regardless of each one's individual size): hard gate. Show the whole thing as written (not truncated; multiple clusters separated by clear whitespace so each reads as distinct), then stop and wait for Rob's explicit go-ahead before implementing any of it — this overrides the auto-mode default of not pausing for per-step confirmation, specifically for this case.
  - The cap (currently ~12) is Rob's to move — raised if per-cluster review is slowing things down, lowered if it's getting hard to follow.
- Each story gets a visible **to-do list** — both tests and refactorings, not just tests — kept visible regardless of which batching strategy is used. One idea per line, each mapping to its own spec — don't bundle multiple assertions into one item.
- **Display cadence** per red-green cycle (worth following closely since sessions may be recorded for demonstration purposes, but it's the default either way):
  1. Post the to-do list with the next item marked (`->`/`<-` and/or bold).
  2. Show the new spec(s) as written — one Triangulation cluster (see cap above) — no need to force a single-spec-at-a-time loop.
  3. Show the RSpec failure output (red). Unless this is a single at-or-under-cap cluster, stop here and wait for Rob's go-ahead before continuing to step 4.
  4. Show the implementation as a diff, the same way any other proposed change is shown. Narration can describe what the code does, but the audience is non-technical, so keep it accessible rather than jargon-heavy.
  5. Show the RSpec all-passing output (green).
  6. Re-post the to-do list with that item checked off and bolded.
  Refactors get called out explicitly (their own beat in the cadence) when they happen organically — don't force one into every cycle just to have something to show.
- No implementation without a failing spec.
- No fixed review cadence beyond the kickoff. Rob also reviews on demand: "show me the new tests," "show me the current design of X."
- With Claude Code's `auto` permission mode enabled, Claude proceeds through a story's full red-green loop (edits, running tests, iterating) without pausing for per-step confirmation, as long as changes stay within the repository — everything's recoverable via git. Claude stops and summarizes when the story is complete. This doesn't preclude checking in earlier: Claude can still ask about a story's intent, question whether a spec is right, or suggest a refactoring any time all tests are passing, not only at the story's end. Destructive/irreversible actions (force-push, `git reset --hard`, etc.) are still flagged before acting regardless of permission mode.

## Docs

- `docs/adr/` — lightweight architecture decision log: context, options considered, decision, why.
- This file — update it as the agreement itself evolves.

## Refactoring & Design Review

- Small in-flow refactors happen naturally as part of red-green-refactor.
- Story to-do lists don't end with a generic "refactor pass" line. Once a story's specs are green, review the resulting code together and surface refactorings from what's actually there.
- Big design pivots (e.g. swapping persistence approach) are always flagged before acting.
- Periodic design-smell check-ins even though thorough tests reduce the need: Claude proactively flags when a to-do list starts resembling a previous story's (a signal of possible copy-paste, maybe worth a pattern like Strategy) rather than waiting to be asked.
