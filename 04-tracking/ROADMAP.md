# Qura Ecosystem — Roadmap

Planned work, milestones, dependencies and target dates across the three Qura
repositories. Target dates are separate from actual completion (see
`COMPLETION_LOG.md`). Use `TBD` where no date is agreed. Status vocabulary is in
`00-overview/STATUS_RULES.md`.

Last verified: 2026-10-20

## Milestones

| Milestone | Scope | Status | Target | Actual | Evidence |
|---|---|---|---|---|---|
| M1 Backend foundation + schema (Phases 1–2) | client-server | Completed | — | 2026-10-20 | Commit `1c1a638` |
| M2 Auth + profile (Phase 3) | client-server | Completed | — | 2026-10-20 | `test_auth_*`, `test_profile_api` |
| M3 Core client APIs (Phase 4) | client-server | Completed | — | 2026-10-20 | Commit `1c1a638` + tests |
| M4 Frontend UI | client-panel | Completed | — | 2026-09-10 | Commit `58baa37` |
| M5 Frontend↔backend integration (Phase 5) | cross | Completed (code); e2e not verified | — | 2026-10-20 | Commits `98725d6`, `0c22201` |
| M6 Policy documents + uploads (upload/extract/download, avatar, KYC, RM) | cross | Completed (code, L1); runtime not verified | — | 2026-10-20 | Commit `dc879f4` |
| M7 Live DB + end-to-end verification (Phases 6–7) | cross | In Progress | TBD | — | Active branch `phase-6-7-testing-and-db-integration`; no e2e evidence |
| M8 Deferred portal features (claims submit, invoices, coverage engine, admin invites, email, PII encryption, sessions table) | client-server | Planned/Backlog | TBD | — | README deferred list |
| M9 KB service definition + scaffold | qura-kb | Blocked (needs scope decision) | TBD | — | Near-empty repo |

## Dependency graph (milestone level)

```
M1 ─► M2 ─► M3 ─► M5 ─┐
              M4 ─────┤► M5 ─► M6 ─► M7 ─► (production readiness)
                                     │
                                     └─► M8 (deferred features, parallelizable)

M9 (KB service) depends on a senior scope decision; largely independent of M1–M8,
   but its project-tracking role references their status.
```

## Phase 6–7 (current focus) — testing and DB integration

Target dates: **TBD**. Work items:
- CS-9: apply + verify Alembic migrations on a live `qura_*` PostgreSQL.
- X-1: end-to-end verification of SPA ↔ backend ↔ live DB.
- P-CS-1/P-CS-2/P-CS-3: fill test gaps (avatar/KYC, RM, real extraction).
- CP-5: update the stale frontend README.
- X-2: reconcile frontend routes that the backend defers.

## Deferred portal features (M8 — Backlog/Planned, all target TBD)

Claim submission + document upload (CS-10), transaction invoices (CS-11),
coverage/plan engine (CS-12), admin invite creation (CS-13), email delivery
(CS-14), PII-at-rest encryption/masking (CS-15), `sessions` table (CS-16), RM
view + WebSocket (CS-17), reference/FAQ seeding (CS-18), Google sign-in (CP-4).

## KB service (M9 — Blocked, target TBD)

Blocked on KB-2 (scope/stack decision). Then KB-3 (architecture spec) and KB-4
(scaffold). Current agreed scope is architecture + project tracking only;
insurance knowledge features are explicitly deferred.

## Cross-repository dependencies

- Frontend features depend on the backend `/api/client` contract (CP-2, CP-3 → CS-3/CS-5/CS-7).
- End-to-end verification (X-1) depends on a live DB (CS-9).
- Full signup e2e depends on admin invite creation (CS-13).
- Frontend marketplace/insurer flows depend on backend features currently out of
  scope (X-2) — a frontend-ahead-of-backend gap.
- KB service work (M9) depends on senior decisions, not on portal code.

## Known unknowns (target dates)

Every forward-looking target date in this roadmap is **TBD** — no agreed dates
were found in the repositories or provided by the senior. See
`BLOCKERS_AND_RISKS.md` for the decisions needed to set them.
