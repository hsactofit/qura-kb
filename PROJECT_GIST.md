# Qura Ecosystem — Project Gist

Consolidated overview and current status of the entire Qura ecosystem. This is
the single entry point; details live in the linked documents.

Last verified: 2026-10-20

Related docs: [ARCHITECTURE_OVERVIEW](ARCHITECTURE_OVERVIEW.md) ·
[ISSUE_REGISTER](ISSUE_REGISTER.md) · [ROADMAP](ROADMAP.md) ·
[COMPLETION_LOG](COMPLETION_LOG.md) · [BLOCKERS_AND_RISKS](BLOCKERS_AND_RISKS.md) ·
[STATUS_RULES](docs/STATUS_RULES.md)

---

## Executive summary

Qura is an insurance **client portal** made of a React/Vite frontend
(`Qura-client-panel`) and a FastAPI backend (`qura-client-server`), plus a
standalone **knowledge-base service** (`qura-kb`) that today serves only as the
project-tracking hub. A fourth repo, `arham-secure-server`, is a read-only
reference from a prior project and is not part of Qura's runtime.

Where things stand: the backend has a complete, well-tested feature set for
auth, profile, policies (incl. document upload/AI-extract/download), assets,
family, claims (read), transactions (read), notifications, support and reference
data — **173 automated tests pass**. The frontend has a complete UI wired to that
backend behind a demo toggle — **27 automated tests pass**. The big caveat: all
backend tests run against an **in-memory fake database**, and there is **no
evidenced end-to-end run against live PostgreSQL or a live browser session**. The
team is on a `phase-6-7-testing-and-db-integration` branch, which is exactly that
missing piece. `qura-kb` as a service is undecided and blocked on a scope call.

In one line: **feature-complete-on-paper and green on unit tests, but live
integration and acceptance are still unproven, and all forward dates are TBD.**

## Overall ecosystem status

- **Purpose & scope**: a customer insurance portal (manage policies, claims,
  support, transactions, profile/KYC) with a planned marketplace funnel, backed
  by a dedicated Qura API and database; plus a future KB service.
- **Current phase by repo**:
  - `qura-client-server`: Phases 1–4 done; policy-document + KYC/avatar/RM work
    landed on top; now in Phase 6–7 (live DB + testing).
  - `Qura-client-panel`: UI done; Phase 5 backend integration done; policy
    upload/preview/download wired.
  - `qura-kb`: project-tracking role active; KB **service** not started (blocked).
- **Overall delivery status**: code largely in place and unit-green; live
  integration + acceptance pending.
- **Major completed milestones**: M1 foundation, M2 schema, M3 core APIs, M4 UI,
  M5 integration, M6 policy documents/uploads (see `ROADMAP.md`).
- **Current open issues & blockers**: live DB verification (CS-9/B-2), end-to-end
  verification (X-1), KB scope decision (KB-2/B-1), admin invites (CS-13/B-3),
  email delivery (CS-14/B-4).
- **Upcoming work**: Phase 6–7 live DB + e2e; then deferred features (claims
  submit, invoices, coverage engine, PII encryption, sessions table).
- **Cross-repo dependencies**: frontend ⟶ backend `/api/client` contract;
  e2e ⟶ live DB; full signup ⟶ admin invites; marketplace ⟶ backend features
  still out of scope. KB service ⟶ senior decisions.
- **Last verified**: 2026-10-20 (git history, source, and test runs).

## Repository-by-repository status

### qura-client-server (backend) — see [docs/repositories/CLIENT_SERVER.md](docs/repositories/CLIENT_SERVER.md)

- **Purpose**: dedicated client-portal API (`/api/client`, `{success,message,data}`
  envelope). Independent of `arham-secure-server`; connects only to a `qura_*` DB.
- **Architecture**: FastAPI app factory + per-feature modules; async SQLAlchemy;
  Alembic as sole schema authority; DB guard; private file storage with
  traversal guard; redacting logs; CSRF + opaque signed session cookie.
- **Implemented & verified (L1, fake DB)**: foundation, auth, profile/settings,
  dashboard, policies read, assets/family CRUD, claims read, transactions read,
  notifications, support, master-data/FAQs, policy upload/extract/track/confirm/
  download, upload primitives. **173 tests pass.**
- **Implemented but NOT verified**: avatar + KYC upload/download (no API tests),
  RM lookup (no tests), real AI extraction path, live PostgreSQL behaviour,
  end-to-end with the SPA.
- **Open issues**: CS-9 (live DB apply/verify).
- **Backlog**: claim submission (CS-10), invoices (CS-11), coverage engine
  (CS-12), admin invites (CS-13), email (CS-14), PII encryption (CS-15), sessions
  table (CS-16), RM view + WebSocket (CS-17), reference seeding (CS-18).
- **Dependencies**: frontend consumes its contract; e2e needs a live DB.
- **Next actions**: migrate + verify a live `qura_*` DB; add avatar/KYC/RM tests;
  exercise real extraction; begin deferred features by agreed priority.

### Qura-client-panel (frontend) — see [docs/repositories/CLIENT_PANEL.md](docs/repositories/CLIENT_PANEL.md)

- **Purpose**: the client-portal SPA (dashboard, policies, claims, support,
  notifications, transactions, profile, settings, FAQs, marketplace, admin).
- **Architecture**: one transport client (`src/lib/api.ts`) with session cookie +
  CSRF; full route map; typed service wrappers; AuthContext (no localStorage user
  caching); a build-time `VITE_DEMO_MODE` toggle swapping real backend for
  in-browser fixtures.
- **Implemented & verified (L1)**: transport client, demo adapter, a classifier —
  **27 tests pass**.
- **Implemented & integrated (not runtime-verified here)**: auth, dashboard,
  policies incl. upload/preview/download/status-poll/confirm, claims, support,
  notifications, transactions, profile, settings, assets/family, master data,
  marketplace funnel, admin.
- **Open issues**: none tracked beyond e2e (X-1).
- **Backlog/stubs**: Google sign-in stub (CP-4), stale README (CP-5),
  route reconciliation (X-2); nominees derived client-side; unused
  `document.service.ts`.
- **Dependencies**: backend `/api/client` contract; live e2e needs the backend + DB.
- **Next actions**: run against live backend + DB; reconcile routes; resolve stubs.

### qura-kb (knowledge base + tracking) — see [docs/repositories/QURA_KB.md](docs/repositories/QURA_KB.md)

- **Purpose**: central project tracking (active now) and a future standalone KB
  service (near-term scope = architecture + tracking only; insurance knowledge
  features deferred).
- **Architecture**: service not yet defined (stack TBD).
- **Implemented & verified**: none as a service; the only prior commit is a README
  title. This documentation set is the first substantive content.
- **Open/blocked**: KB-2 — scope/stack/integration decision (blocked on senior).
- **Backlog**: architecture spec (KB-3), scaffold (KB-4).
- **Dependencies**: senior decisions; references portal status.
- **Next actions**: get a scope decision, then spec and scaffold.

## How to use this hub

Start here, then open `ISSUE_REGISTER.md` for the itemized status, `ROADMAP.md`
for sequencing and dependencies, `COMPLETION_LOG.md` for what is genuinely done
(with verification level), and `BLOCKERS_AND_RISKS.md` for the decisions owed.
`docs/STATUS_RULES.md` defines every status and verification level used here.
