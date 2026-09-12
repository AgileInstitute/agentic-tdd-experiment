# Setting Up This Project on a New Machine

Checklist for moving work on this repo to a different computer: same
Anthropic account, destination **Germany**, machine is a **Windows laptop**
(current machine is a Mac). Split into what git already carries and what's
local-only and needs to be redone or copied by hand.

## Windows: use WSL2, not native Windows

Strongly recommended over native PowerShell/CMD, because of this stack:

- The `sqlite3` gem (via Sequel) needs native extensions compiled at
  install time. This is routinely painful on native Windows (needs
  RubyInstaller + the DevKit/MSYS2 toolchain, and version mismatches are a
  common source of install failures) and much smoother under Linux.
- `bin/exploratory_preview` and `bin/preview_timeline` are shebang
  (`#!/usr/bin/env ruby`) scripts with no `.rb` extension — they won't run
  directly from PowerShell/CMD (no shebang support, no extension to
  associate with `ruby.exe`). They run as-is under WSL2.
- Git line-ending behavior (`core.autocrlf`) is one less thing to think
  about under WSL2, since the filesystem and line endings stay Unix-style
  end to end.

Install WSL2 (`wsl --install`, Ubuntu is the default distro), then do
everything below — Ruby install, `bundle install`, Claude Code install,
`git clone` — inside the WSL2 Linux environment rather than on the Windows
side. Claude Code itself supports native Windows too, but running it inside
the same WSL2 environment as the Ruby toolchain keeps paths and permissions
consistent.

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
  - Because this move also changes OS (Mac → Windows/WSL2), the absolute
    path **cannot** match — it goes from `/Users/robmyers/Documents/...` to
    something like `/home/<user>/...` under WSL2. There's no way to
    preserve the project-hash match this time; it's not worth chasing.
  - Instead: clone the repo, open Claude Code in it once (so it creates the
    new project directory under `~/.claude/projects/` on the new machine),
    then copy the memory `*.md` files and `MEMORY.md` from the old
    machine's project memory directory into the new one. Transfer via a
    secure channel — see `.env` below — since this is personal working
    context, not secret, but still not for casual channels.

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

## Network considerations (Germany)

No known restrictions on accessing Anthropic's API/claude.ai from Germany —
it's within the EU with generally open access to US cloud services, so no
VPN is expected to be needed for Claude Code itself. Worth a quick check
once actually there, since policies can change, but nothing to pre-configure
for this.

GDPR is a live consideration for the *app* being built here (federated
journaling/social, so EU personal data) — worth a story/ADR of its own if
it isn't covered already, but that's a product concern, not a machine-setup
one, so not expanded further in this doc.
