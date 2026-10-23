# Qura Ecosystem — Blockers and Risks

Unresolved blockers, risks and decisions the senior needs to make. Status
vocabulary in `00-overview/STATUS_RULES.md`.

Last verified: 2026-10-20

## Blockers (stop progress until resolved)

| ID | Area | Blocker | Impact | Needed to unblock |
|---|---|---|---|---|
| B-1 | qura-kb (KB-2) | KB service scope/stack/integration not decided | KB service cannot be designed or scaffolded | Senior decision on scope, stack, and portal integration |
| B-2 | client-server (CS-9) | No live `qura_*` PostgreSQL has been migrated/verified | Real schema/constraint/JSONB/UUID behaviour unproven; blocks e2e | Provision a `qura_*` DB and run `alembic upgrade head` + checks |
| B-3 | cross (CS-13) | Invite creation (admin path) not implemented | True end-to-end signup can't run without a seeded invite | Implement admin/CLI invite creation or seed invites |
| B-4 | cross (CS-14) | Email delivery not configured | Forgot-password / notifications can't deliver outside dev (`debug_token`) | Configure an email provider |

## Risks

| ID | Area | Risk | Likelihood/Impact | Mitigation |
|---|---|---|---|---|
| R-1 | Verification | "Tests pass" is against an in-memory fake DB, not live Postgres | Med / High | Run live DB integration before claiming done (B-2) |
| R-2 | Contract drift | Frontend `API_ROUTES` include marketplace/insurer/KYC/payment routes the backend defers | Med / Med | Reconcile and mark unsupported routes (X-2) |
| R-3 | Security — PII | PAN/Aadhaar/DOB stored as plaintext typed columns | Med / High | Column-level encryption/masking (CS-15) before real PII |
| R-4 | Security — sessions | Revocation is user-level only (no per-device, no idle timeout) | Low / Med | Add `sessions` table (CS-16) |
| R-5 | Docs drift | client-panel README still says "frontend-only demo" though it is backend-wired | High / Low | Update README (CP-5) |
| R-6 | Dates | All commit dates cluster on two days; no acceptance (L3) dates exist | — / Med | Record senior acceptance explicitly going forward |
| R-7 | Branching | Both portal repos have unmerged `phase-6-7-testing-and-db-integration` ahead of `main` | Low / Med | Confirm merge/release intent |
| R-8 | External dep | Policy extraction depends on an OpenAI-compatible endpoint + key | Low / Med | Degrades honestly to manual entry when absent; test the live path |

## Decisions required from the senior

1. KB service: scope, stack, and whether it integrates with the portal (B-1).
2. Target dates for Phase 6–7 (live DB + e2e) and deferred features — all `TBD`.
3. Priority/sequence of deferred backend features (claims submit, invoices,
   coverage engine, admin invites, email, PII encryption, sessions table).
4. Whether marketplace/insurer/KYC/payment belong in Qura's backend scope or stay
   frontend-only for now (X-2).
5. Confirmation of the reported manual policy upload/download check: which
   build, demo vs live backend, and whether against a live DB.
6. Owners for currently-unowned items (most `TBD`).

## Conflicting / missing information (flagged, not resolved)

- **Frontend README vs code**: README describes a fictional demo; code is wired
  to a real backend behind `VITE_DEMO_MODE`. Treated as README being stale.
- **Phase numbering**: backend README documents Phases 1–4; the latest commit and
  the active branch imply Phases 5–7 (integration, uploads, DB/testing) without a
  README update. No single authoritative phase definition exists in-repo.
- **Senior's reported checks vs evidence**: reported upload/download verification
  could not be independently confirmed from the repositories.
- **No external issue tracker**: the repos have no GitHub Issues; all IDs in
  `ISSUE_REGISTER.md` are internal to this register.
