# agentic-tdd-experiment

A federated journaling/social app (self-hosted, ActivityPub-based) — but the real subject of this repo is exploring how TDD/BDD works well when paired with an agent. See `docs/working_agreement.md` for full collaboration norms and `docs/adr/` for architecture decisions; both are worth reading in full, not just this summary.

## Stack
Ruby, Sinatra (**not** Rails), RSpec 3.13, rack-test, Sequel, SQLite3, dotenv.

## Hard rules
- No Rails, ever.
- No implementation code without a failing spec first — except: symmetric/unambiguous unit test groups (e.g. both branches of a simple boolean method) may be batched with their implementation. Revert to strict one-test-at-a-time when discovering a new interface or facing real branching complexity.
- Big design pivots (e.g. swapping persistence approach) are always flagged to the user before acting, not just done.
- WIP = 1 story at a time, optionally + 1 architecture spike (brief the user before starting a spike).
- Stories are "NYT Headline" format: title + description + bulleted **examples** (not "acceptance criteria").

## Commands
- Run tests: `bundle exec rspec`
- Run app: `bundle exec rackup`

## Roles
User is product/customer: writes and prioritizes stories, final say on the queue and big design pivots. Assistant is implementer + architecture-option-surfacer, pairs throughout.
