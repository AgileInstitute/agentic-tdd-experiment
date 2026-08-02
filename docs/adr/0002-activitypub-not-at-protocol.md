# ADR 2: ActivityPub, not AT Protocol

Backfilled 2026-08-01 — decision predates this log.

## Context
The app is a federated journaling/social platform: communities are self-hosted on individual servers, and users can belong to multiple communities with a combined feed. A federation protocol is needed to let independently-hosted communities interoperate.

## Options Considered
- **AT Protocol** — built around portable, DID-based identity that isn't tied to any single server, which decouples an account from its hosting server but adds significant protocol complexity (identity resolution, portable data repos) not otherwise needed here.
- **ActivityPub** — W3C standard, server-to-server federation model where identity is tied to the home server. Simpler protocol surface, and a natural fit for a self-hosted-community deployment model where the server is already the unit of hosting and administration.

## Decision
ActivityPub.

## Why
The self-hosted-community model already anchors identity to a home server, so AT Protocol's portable-identity machinery solves a problem this architecture doesn't have, at a real complexity cost. The server-loss risk that portable identity would otherwise mitigate is instead addressed separately via local incremental backups (see ADR 3).
