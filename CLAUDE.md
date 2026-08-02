# agentic-tdd-experiment

A federated journaling/social app (self-hosted, ActivityPub-based) — but the real subject of this repo is exploring how TDD/BDD works well when paired with an agent. See `docs/working_agreement.md` for full collaboration norms and `docs/adr/` for architecture decisions; both are worth reading in full, not just this summary.

## Stack
Ruby, Sinatra (**not** Rails), RSpec 3.13, rack-test, Sequel, SQLite3, dotenv.

## Hard rules
- No Rails, ever.
- No implementation code without a failing spec first.
- Before starting a story, do a kickoff review together (at least a quick once-over) — ask clarifying questions or raise examples/edge cases you've thought of. After that, you choose the batching strategy for the story (all tests up front vs. smaller test-then-implement loops) based on what's most efficient for it.
- Big design pivots (e.g. swapping persistence approach) are always flagged to the user before acting, not just done.
- WIP = 1 story at a time, optionally + 1 architecture spike (brief the user before starting a spike).
- Stories are "NYT Headline" format: title + description + bulleted **examples** (not "acceptance criteria").
- When a story, to-do item, or suggestion from the user is unclear or under-specified, use the AskUserQuestion tool rather than guessing or assuming.

## Commit Messages
Use Conventional Commits prefixes: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`.

## Commands
- Run tests: `bundle exec rspec`
- Run app: `bundle exec rackup`

## Roles
User is product/customer: writes and prioritizes stories, final say on the queue and big design pivots. Assistant is implementer + architecture-option-surfacer, pairs throughout.
