# Qura Ecosystem — Central Issue Register

Single register for issues across all Qura repositories. Status values and
verification levels are defined in `docs/STATUS_RULES.md`.

Last verified: 2026-10-20

Conventions:
- IDs `CS-*` = client-server, `CP-*` = client-panel, `KB-*` = qura-kb,
  `X-*` = cross-repo. IDs prefixed `P-` are **provisional** (inferred
  recommendations, not official issues) — no invented owners/dates/priorities.
- "Evidence" cites repo artifacts. Dates come from git/README/test runs only.
- These IDs are internal tracking IDs created for this register; they are not
  from an external issue tracker (none was found — the repos have no GitHub
  Issues at the time of inspection).

## Completed

| ID | Repo | Area | Title | Type | Status | Priority | Owner | Created | Target | Completed | Dependencies | Evidence | Last Verified | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| CS-1 | client-server | Foundation | FastAPI app factory, envelope, errors, health, CORS, security headers, redacting logs, authz scaffold (Phase 1) | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | — | Commit `1c1a638`; tests pass (173) | 2026-10-20 | L1 (fake DB) |
| CS-2 | client-server | Schema | SQLAlchemy models + Alembic initial schema + DB guard (Phase 2) | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | — | Commit `1c1a638`; `test_models_metadata`, `test_migration` | 2026-10-20 | L1 offline; live DB apply unverified |
| CS-3 | client-server | Auth | Signup/signin/session/signout, invite verify, forgot/reset password; Argon2id, CSRF, enumeration resistance (Phase 3) | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-2 | Commit `1c1a638`; `test_auth_*` | 2026-10-20 | L1 (fake DB) |
| CS-4 | client-server | Profile | Profile + settings read/update | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-3 | `test_profile_api.py` | 2026-10-20 | L1 |
| CS-5 | client-server | Core APIs | Dashboard, policies read, assets/family CRUD, claims read, transactions read, notifications, support, master-data/FAQs (Phase 4) | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-3 | Commit `1c1a638`; multiple API tests | 2026-10-20 | L1 (fake DB) |
| CS-6 | client-server | Security | Security-header + CSRF regression tests; DI-scoped readiness | Task | Completed | Medium | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-1 | Commit `0ae39fb`; `test_security_headers`, `test_auth_session_csrf` | 2026-10-20 | L1 |
| CS-7 | client-server | Policies | Policy upload + AI extract (preview) + track + confirm + download; sha256 dedup; private storage | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-5 | Commit `dc879f4`; `test_policies_operations.py`, `test_policies_storage.py` | 2026-10-20 | L1 (fake DB); real AI path untested |
| CS-8 | client-server | Schema | `kyc_documents` migration + policy verification backfill migration | Task | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-2 | Commit `dc879f4`; migrations 0002, 0003 | 2026-10-20 | Structure only; live apply unverified |
| CP-1 | client-panel | UI | Full client-portal UI (dashboard, policies, claims, support, notifications, transactions, profile, settings, marketplace, admin, auth) | Feature | Completed | High | Mohammed Ahmed Anjarwala | 2026-09-10 | — | 2026-09-10 | — | Commit `58baa37` | 2026-10-20 | Demo UI complete |
| CP-2 | client-panel | Integration | Phase 5 backend integration: dev proxy, env config, unified API client | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-3 | Commit `98725d6`; `api.test.ts` passes | 2026-10-20 | L1; live e2e unverified |
| CP-3 | client-panel | Policies | Wire policy upload/preview/download + insurance service to backend | Feature | Completed | High | parthdevinnovator | 2026-10-20 | — | 2026-10-20 | CS-7, CP-2 | Commit `0c22201` | 2026-10-20 | L0/L1; live e2e unverified |
| KB-1 | qura-kb | Tracking | Central project-tracking documentation set | Task | Completed | High | Kiro (assisted) | 2026-10-20 | — | 2026-10-20 | — | This repo's docs | 2026-10-20 | This deliverable |

## Open / In Progress / Blocked

| ID | Repo | Area | Title | Type | Status | Priority | Owner | Created | Target | Completed | Dependencies | Evidence | Last Verified | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| CS-9 | client-server | DB | Apply + verify Alembic migrations on live `qura_*` PostgreSQL | Task | Open | High | TBD | 2026-10-20 | TBD | — | CS-2, CS-8 | README "live DB not exercised"; no apply evidence | 2026-10-20 | Branch name implies in-flight: `phase-6-7-testing-and-db-integration` |
| X-1 | cross | Integration | End-to-end verify SPA ↔ backend ↔ live DB | Task | Open | High | TBD | 2026-10-20 | TBD | — | CS-9, CP-2, CP-3 | No evidenced e2e run | 2026-10-20 | Blocks L2 for most features |
| KB-2 | qura-kb | Service | Define KB service scope, stack and integration | Decision | Blocked | High | TBD (senior) | 2026-10-20 | TBD | — | — | Near-empty repo (`32335d9`) | 2026-10-20 | Blocked on senior decision |

## Backlog / Planned

| ID | Repo | Area | Title | Type | Status | Priority | Owner | Target | Dependencies | Evidence | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| CS-10 | client-server | Claims | Claim submission + claim document upload pipeline | Feature | Backlog | Medium | TBD | TBD | CS-7 | README: "Claims are read-only … deferred" | Tables exist; upload handling does not |
| CS-11 | client-server | Transactions | Transaction invoice generation (`/transactions/{id}/invoice`) | Feature | Backlog | Low | TBD | TBD | CS-5 | README: deferred | — |
| CS-12 | client-server | Dashboard | Coverage/plan analysis engine + recommendations | Feature | Backlog | Medium | TBD | TBD | — | README: `coverageAnalysis.status="unavailable"` | — |
| CS-13 | client-server | Admin | Invite creation (admin/CLI path) | Feature | Backlog | Medium | TBD | TBD | CS-3 | README: "Invite creation is not implemented" | Blocks true e2e signup |
| CS-14 | client-server | Email | Email delivery for forgot-password / notifications | Feature | Backlog | Medium | TBD | TBD | — | README: "No email delivery configured" | Dev returns `debug_token` only |
| CS-15 | client-server | Security | PII-at-rest encryption/masking (PAN, Aadhaar, DOB) | Feature | Backlog | High | TBD | TBD | — | README: "PII at rest is not encrypted/masked" | Plaintext typed columns today |
| CS-16 | client-server | Sessions | `sessions` table for per-device revocation / idle timeout | Feature | Backlog | Medium | TBD | TBD | CS-2 | README: user-level revocation only | Needs Alembic migration |
| CS-17 | client-server | Support | RM-assigned ticket view + WebSocket live updates | Feature | Backlog | Low | TBD | TBD | — | README: deferred; frontend polls | `sender_profile` currently null |
| CS-18 | client-server | Reference | Seed reference/master-data + FAQ rows | Task | Backlog | Low | TBD | TBD | — | README: "Reference data is not seeded" | Later approved data migration |
| CP-4 | client-panel | Auth | Google sign-in | Feature | Backlog | Low | TBD | TBD | — | `signInWithGoogle` returns "not implemented" | Explicit stub |
| CP-5 | client-panel | Docs | Update README (stale: still "frontend-only demo") | Task | Backlog | Low | TBD | TBD | CP-2 | README vs integration commits | — |
| X-2 | cross | Contract | Reconcile frontend marketplace/insurer/KYC/payment routes vs backend (out-of-scope on backend) | Task | Backlog | Medium | TBD | TBD | — | `API_ROUTES` has routes backend defers | Frontend ahead of backend |
| KB-3 | qura-kb | Service | KB service architecture spec | Task | Backlog | Medium | TBD | TBD | KB-2 | — | After scope decision |
| KB-4 | qura-kb | Service | Scaffold KB service (structure, CI, tests) | Task | Backlog | Medium | TBD | TBD | KB-2, KB-3 | — | — |

## Provisional recommendations (inferred — confirm before adopting)

| ID | Repo | Area | Title | Type | Status | Notes |
|---|---|---|---|---|---|---|
| P-CS-1 | client-server | Tests | Add API tests for avatar + KYC upload/download | provisional | Backlog | Code exists (`profile/uploads.py`) but no endpoint tests |
| P-CS-2 | client-server | Tests | Add tests for RM assignment lookup | provisional | Backlog | No RM test file |
| P-CS-3 | client-server | Tests | Exercise real OpenAI extraction path in a sandbox | provisional | Backlog | Only the degraded/unavailable branch is tested |
| P-CP-1 | client-panel | Cleanup | Remove or repurpose unused `document.service.ts` | provisional | Backlog | localStorage demo store, no callers |
| P-CP-2 | client-panel | Data | Decide if nominees need a real backend resource | provisional | Backlog | Currently derived client-side with hardcoded share |
