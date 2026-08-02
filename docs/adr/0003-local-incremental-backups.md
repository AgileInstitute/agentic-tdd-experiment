# ADR 3: Local incremental/differential backups, not portable identity

Backfilled 2026-08-01 — decision predates this log.

## Context
Choosing ActivityPub (ADR 2) ties each user's identity and data to their home community server. This creates a "home server goes away" risk — a host stops maintaining a server, hardware fails, a community shuts down — with no built-in way to recover a user's data or move it elsewhere.

## Options Considered
- **Portable identity (AT-Protocol-style)** — already rejected in ADR 2 as more protocol complexity than the self-hosted-community model needs.
- **No mitigation** — leaves users exposed to total data loss if their home server disappears.
- **On-demand full-dump export** (e.g. Facebook-style data export) — gives users a copy of their data, but as an occasional, manual, full snapshot rather than an ongoing safety net.
- **Automated incremental/differential local backups** — frequent, automated, and only capture changes since the last backup rather than a full dump each time.

## Decision
Users can take frequent, automated, incremental/differential local backups of their data.

## Why
Gives users practical data portability and resilience against server loss without taking on a portable-identity protocol's complexity. Incremental/differential backups are cheaper to run frequently than repeated full dumps, so the safety net can stay current rather than depending on users to remember to export.
