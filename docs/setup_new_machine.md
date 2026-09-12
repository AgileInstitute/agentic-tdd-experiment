# Setting Up This Project on a New Machine

Checklist for moving work on this repo to a different computer (e.g. same
Anthropic account, different country). Split into what git already carries
and what's local-only and needs to be redone or copied by hand.

## Comes for free via git

Cloning `https://github.com/AgileInstitute/agentic-tdd-experiment.git` brings
all code, `CLAUDE.md`, `docs/working_agreement.md`, `docs/adr/`,
`story_map.md`, and `story_archive.md`. Nothing to do here beyond the clone
itself.

## Needs to be redone or copied

- [ ] **Ruby toolchain** — install the same Ruby version, then
      `bundle install`. Check `.ruby-version` / `Gemfile.lock` for the exact
      version in use.

- [ ] **Claude Code auth** — install Claude Code on the new machine and run
      `/login` with the same Anthropic account. Same account, so no special
      config; OAuth just re-authenticates there.

- [ ] **Claude Code memory** — the file-based memory holding accumulated
      feedback (bash granularity, story numbering, diff format, etc.) lives
      at `~/.claude/projects/<project-path-hash>/memory/`, keyed off the
      repo's *absolute path*, not tracked in git.
  - Clone the repo to the **same absolute path** on the new machine if at
    all possible (same relative location under the home directory) — that's
    what makes Claude Code resolve it to the same project hash.
  - Copy the memory directory over (tar/zip it, transfer via a secure
    channel — see below) into the equivalent path on the new machine.
  - If the path can't match exactly (different username/OS), the memory
    won't be found automatically; you'd be starting that project's memory
    fresh unless it's manually placed under the new hash.

- [ ] **`.claude/settings.local.json`** — gitignored, per-machine tool
      permissions allowlist. Recreate manually or copy the file over.

- [ ] **`.env`** — gitignored, holds `APP_SECRET` and other local config
      (see `.env.example` for the shape). Never commit this. Transfer via a
      secure channel only — password manager, `scp` over SSH, etc. — never
      email or chat.

- [ ] **Local SQLite db** (`db/*.sqlite3`) — gitignored dev data. Copy the
      file directly if you want the same data on the new machine; otherwise
      it starts fresh from migrations.

- [ ] **Exploratory-testing sample data**
      (`/spec/fixtures/exploratory/`) — gitignored, real personal
      posts/photos used by `bin/exploratory_preview`. Not meant to be
      shared; the new machine populates its own if needed.

## Network considerations

No special Claude Code configuration is needed for a different country, but
some countries restrict access to Anthropic's API/claude.ai. Check this once
the destination is known — a VPN may be required. Not addressed further here
since it depends on the specific location.
