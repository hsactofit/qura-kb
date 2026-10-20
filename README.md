# qura-kb

Knowledge-base service for the Qura ecosystem **and** the central
project-management and documentation hub for all Qura repositories.

Today this repo's active role is project tracking. The KB *service* is not yet
built — its scope and stack are still to be decided (see the blockers doc).

## Start here

- **[PROJECT_GIST.md](PROJECT_GIST.md)** — consolidated overview and current
  status of the whole Qura ecosystem (read this first).
- **[ISSUE_REGISTER.md](ISSUE_REGISTER.md)** — central issue register (open,
  in progress, blocked, backlog, completed) across all repos.
- **[ROADMAP.md](ROADMAP.md)** — milestones, dependencies and target dates.
- **[COMPLETION_LOG.md](COMPLETION_LOG.md)** — verified completed work with
  actual completion dates and verification levels.
- **[BLOCKERS_AND_RISKS.md](BLOCKERS_AND_RISKS.md)** — unresolved blockers, risks
  and decisions needed from the senior.
- **[ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md)** — how the projects fit
  together.

## Per-repository status

- **[docs/repositories/CLIENT_SERVER.md](docs/repositories/CLIENT_SERVER.md)** — backend.
- **[docs/repositories/CLIENT_PANEL.md](docs/repositories/CLIENT_PANEL.md)** — frontend.
- **[docs/repositories/QURA_KB.md](docs/repositories/QURA_KB.md)** — this KB repo.

## Conventions

- **[docs/STATUS_RULES.md](docs/STATUS_RULES.md)** defines all status values and
  the verification levels (L0 code → L1 tests → L2 manual → L3 accepted).

## Scope and guarantees of this hub

- Covers `qura-client-server`, `Qura-client-panel` and `qura-kb`.
- `arham-secure-server` is a read-only reference from a prior project and is out
  of scope for Qura tracking.
- Entries are evidence-based (git history, source, migrations, test runs, README,
  or explicit senior statements). Inferred recommendations are marked
  **provisional**. No secrets, credentials or customer data are stored here.

Last verified: 2026-10-20
