# Qura Ecosystem — Central Issue Register

Single register for issues across all Qura repositories. Status values and
verification levels are defined in `00-overview/STATUS_RULES.md`.

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

## Infrastructure (added 2026-10-23)

Server and pipeline details are in `03-infra/`. Migration steps are in `05-migrations/2026-10-backends-to-minim1.md`.

| ID | Area | Title | Status | Priority | Owner | Evidence / Notes |
|---|---|---|---|---|---|---|
| INFRA-1 | Server | hs-minim1 built: Colima, Postgres 16, both APIs, launchd boot/deploy/backup | Completed (L2) | High | Himanshu (Claude Code) | `03-infra/servers/hs-minim1.md`; boot path and backup/restore verified 2026-10-23 |
| INFRA-2 | CD | Auto-deploy on push to `main`: add the 3 read-only deploy keys on GitHub | Blocked (human) | High | Himanshu | Keys printed by bootstrap; deployer logs `clone failed` until added |
| INFRA-3 | Ingress | Cloudflare tunnel login + hostnames (`client-api`, `crm-api`) | Blocked (human) | High | Himanshu | `tunnel-setup.sh`; domain to confirm |
| INFRA-4 | Frontend | Client-panel `vercel.json` rewrite `/api/client/*` → tunnel; Vercel env | Open | High | TBD | Required by cookie, CSRF and CSP design; see `03-infra/services/client-server.md` |
| INFRA-5 | Frontend | Move CRM panel Render → Vercel, `API_URL=https://quracrmapi.leadrizz.com` | Open | High | TBD | |
| INFRA-6 | Data | Decide on and run the CRM data copy from Aiven `defaultdb` → `qura_crm` | Done (real data copied, see INFRA-15) | High | Himanshu | Demo data or real? |
| INFRA-7 | Backups | Off-site backup copy (rclone → R2) | Open | High | TBD | `backup.sh` supports `BACKUP_RCLONE_REMOTE` |
| INFRA-8 | Alerts | Deploy failure / service-down notifications (Slack or e-mail) | Backlog | Medium | TBD | |
| INFRA-9 | CRM | Replace `prisma db push` with `prisma migrate` (history + safe migrations) | Backlog | Medium | TBD | |
| INFRA-10 | CRM | Remove the hardcoded JWT fallback secret; stop committing `dist/` | Backlog | Medium | TBD | `src/config.ts` |
| INFRA-11 | Server | Physical reboot test of hs-minim1 | Open | Medium | Himanshu | Daemon boot path already verified without a reboot |
| INFRA-12 | Access | Confirm access to `hsactofit/Qura-crm-server` (laptop credentials got "Repository not found") | Open | High | Himanshu | |
| INFRA-13 | Client API | Upstream: the repo `Dockerfile` should copy `alembic/` + `alembic.ini`; an empty `QURA_CORS_ALLOW_ORIGINS` crashes startup | Backlog | Low | TBD | Worked around in `infra/` |

**CS-9 update (2026-10-23)**: `alembic upgrade head` (0001→0003) ran successfully against a live
Postgres 16 `qura_client` on hs-minim1, and `/health/ready` reports DB `connected`. That is L2 for
schema apply. Constraint and JSONB behaviour under real API traffic is still part of X-1.

### 2026-10-23 — Unified policy platform (portal ↔ CRM)

| ID | Area | Item | Status | Priority | Owner | Notes |
|---|---|---|---|---|---|---|
| X-2 | Product | One DB for portal + CRM, state-based sync both ways (sign-ups, uploads, verification, requests, replies, claims) | Done (L3 e2e on hs-minim1) | High | Claude | [PORTAL_CRM_SYNC](../02-architecture/PORTAL_CRM_SYNC.md) |
| CP-10 | Client panel | Open sign-up, AI policy view, verification badges, renewal/callback/question/claim-help requests, claim filing + timeline, advisor card, needs-attention dashboard; removed fake renew/nominee/schedule actions | Done (browser e2e) | High | Claude | branch `feat/unified-policy-sync` |
| CRM-20 | CRM panel | Portal Inbox, portal-aware verify with client summary, Policy 360, portal badges, My Day reply link | Done (browser e2e) | High | Claude | branch `feat/unified-policy-sync` |
| CS-10 | Client server | Migration 0004, open sign-up, rich extraction, CRM sync, POST /claims, /policies/{id}/request | Done (175 tests + e2e) | High | Claude | |
| CRM-21 | CRM server | Portal sync, /portal API, local document storage, internal doc endpoint, rich extraction | Done (e2e) | High | Claude | |
| INFRA-14 | Infra | Push the four `feat/unified-policy-sync` branches + qura-kb to `main` (otherwise the deployer will redeploy old `main` once deploy keys exist) | Open | **Urgent** | Himanshu | needs approval |
| INFRA-15 | Data | Aiven CRM data → `qura_main.crm` (needs the Aiven connection string) | Done 2026-10-23 | High | Himanshu | |
| INFRA-16 | Infra | Drop legacy `qura_client` / `qura_crm` DBs on hs-minim1 (test data only) | Open | Low | | |
| INFRA-17 | Frontend | Vercel connector is account "Ecode Dash" (GitHub Eecodedash6) with no projects/no access to hsactofit repos | Open | High | Himanshu | connect the right Vercel account or grant access |
| INFRA-18 | Secrets | Fill `QURA_OPENAI_API_KEY` (client) and `OPENAI_API_KEY`, `R2_*`, `SMARTFLO_*` (CRM) on hs-minim1 | Open | High | Himanshu | placeholders in `~/qura-server/env/` |
| X-3 | Product | No email/SMS yet: clients learn about replies via portal notifications only | Open | Medium | | |
