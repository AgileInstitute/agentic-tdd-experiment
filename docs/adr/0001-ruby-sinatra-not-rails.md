# ADR 1: Ruby + Sinatra, not Rails

Backfilled 2026-08-01 — decision predates this log.

## Context
Needed a web framework for the project. The project's own purpose is exploring how TDD/BDD works well when paired with an agent, so the framework choice matters beyond just building the app — it needs to support small, deliberate, test-driven steps without a lot of surrounding ceremony.

## Options Considered
- **Rails** — batteries-included, but its conventions and magic (auto-loading, generators, implicit wiring, ActiveRecord callbacks) obscure the code paths that TDD is meant to make explicit, and bring a large dependency/boot footprint disproportionate to a small app, working against fast, tight test feedback loops.
- **Sinatra** — minimal and explicit; `Sinatra::Base` subclasses can be tested in isolation with plain unit tests via `rack-test`, with no framework magic to work around and no unused framework layers (persistence is handled separately via Sequel/SQLite, not ActiveRecord).

## Decision
Ruby with Sinatra, structured as modular `Sinatra::Base` subclasses.

## Why
Minimal framework surface keeps wiring explicit rather than convention-driven, which preserves the design pressure TDD depends on. Modular subclassing keeps units small, fast to boot, and independently testable — directly serving the project's core goal of exploring what agentic TDD looks like when it works well.
