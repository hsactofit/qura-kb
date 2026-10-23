# Qura Ecosystem — Completion Log

Verified completed work with actual (evidence-backed) completion dates. A commit
alone is not treated as completion; each entry records the highest verification
level reached (see `00-overview/STATUS_RULES.md`). Target/planned dates live in
`ROADMAP.md`, not here.

Last verified: 2026-10-20

## Important caveat on dates

All git commit dates in both portal repositories cluster on **2026-09-10**
(initial frontend demo) and **2026-10-20** (everything else). Completion dates
below are the git commit dates for the evidence commit. They reflect when code
landed, not necessarily when a feature was accepted by the senior. No independent
acceptance (L3) dates were found.

## Completed items

| Item | Repo | Completed (evidence date) | Verification | Evidence | Notes |
|---|---|---|---|---|---|
| Backend foundation (Phase 1) | client-server | 2026-10-20 | L1 (fake DB) | Commit `1c1a638`; 173 tests pass | — |
| Schema + Alembic initial + DB guard (Phase 2) | client-server | 2026-10-20 | L1 offline | Commit `1c1a638`; `test_models_metadata`, `test_migration` | Live DB apply NOT verified |
| Auth + session + CSRF (Phase 3) | client-server | 2026-10-20 | L1 (fake DB) | Commit `1c1a638`; `test_auth_*` | — |
| Profile + settings | client-server | 2026-10-20 | L1 (fake DB) | `test_profile_api.py` | — |
| Core client APIs (Phase 4) | client-server | 2026-10-20 | L1 (fake DB) | Commit `1c1a638` + API tests | Coverage analysis partial by design |
| Security-header + CSRF regression tests | client-server | 2026-10-20 | L1 | Commit `0ae39fb` | — |
| Policy upload/extract/track/confirm/download | client-server | 2026-10-20 | L1 (fake DB) | Commit `dc879f4`; `test_policies_operations.py`, `test_policies_storage.py` | Real AI extraction path NOT verified; 501 status is an honest stub |
| kyc_documents + verification backfill migrations | client-server | 2026-10-20 | Structure only | Commit `dc879f4`; migrations 0002, 0003 | Live apply NOT verified |
| Frontend client-portal UI | client-panel | 2026-09-10 | L0 (demo) | Commit `58baa37` | Full UI across all pages |
| Phase 5 backend integration (unified client, proxy, env) | client-panel | 2026-10-20 | L1 | Commit `98725d6`; `api.test.ts` | Live e2e NOT verified |
| Policy upload/preview/download wired to backend | client-panel | 2026-10-20 | L0/L1 | Commit `0c22201` | Live e2e NOT verified |
| Central project-tracking docs | qura-kb | 2026-10-20 | L1 (this deliverable) | This docs set | — |

## Automated test evidence (captured 2026-10-20)

- **client-server**: `pytest -q` → **173 passed** (7 warnings) against the
  in-memory fake DB layer. 22 test files, ~170 `def test_` functions.
- **client-panel**: `vitest run` → **27 passed** across 4 files
  (`api.test.ts`, `insurance.service.test.ts`, `demoApi.test.ts`,
  `example.test.ts`).

## Explicitly NOT verified (do not mark complete)

- Live PostgreSQL migration apply and real constraint/JSONB/UUID behaviour.
- End-to-end SPA ↔ backend ↔ live DB flow.
- Avatar and KYC upload/download endpoints (no API tests).
- RM assignment lookup (no tests).
- Real OpenAI-compatible extraction call (tests run with extraction unconfigured).

## Senior-reported manual check (unverified by evidence here)

The senior reported personally checking policy **upload and download**. This is
recorded as a reported `L2` for the policy upload/download flow, but it is **not
independently verifiable from the repository** and no environment/run log was
found. Confirm scope (which repo/build, demo vs live backend, live DB or fake)
before treating it as accepted.
