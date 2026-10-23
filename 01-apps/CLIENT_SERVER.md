# qura-client-server — Repository Status

Client-portal backend API.

Last verified: 2026-10-20

- Remote: `github.com/hsactofit/qura-client-server`
- Current branch inspected: `phase-6-7-testing-and-db-integration` (ahead of `origin/main`)
- Stack: Python 3.12, FastAPI, SQLAlchemy 2.x (async + asyncpg), Alembic, PostgreSQL, Pydantic
- Tracking boundary: **inspect only — not modified**

## Purpose and responsibilities

Dedicated backend for the Qura Insurance Client Portal: authentication, user
profile/settings, policies (incl. document upload/extract/download), assets,
family, claims (read), transactions (read), notifications, support tickets,
reference/master data, KYC document upload, avatar upload, and RM lookup. Exposes
a versioned `/api/client` API using a `{success, message, data}` envelope. It is
independent of `arham-secure-server` and connects only to a `qura_*` database.

## Architecture

- FastAPI app factory (`app/main.py`) wiring per-feature routers under
  `/api/client`.
- Modular services in `app/modules/<feature>/` (router + service + schemas +
  mappers).
- Async SQLAlchemy models in `app/db/models/`; Alembic is the sole schema
  authority (`alembic/versions/`).
- Core cross-cutting code in `app/core/` (config, sessions, CSRF, passwords,
  errors/envelope, logging with redaction, security headers, storage, uploads).
- A database-target guard that refuses non-`qura_` databases.

## Delivery timeline (from git history)

| Date | Commit | Summary |
|---|---|---|
| 2026-10-20 | `22d4fd4` | Initial README |
| 2026-10-20 | `1c1a638` | Phases 1–4: FastAPI foundation, schema, auth, core client APIs |
| 2026-10-20 | `0ae39fb` | Security-header + CSRF regression tests; DI-scoped readiness |
| 2026-10-20 | `dc879f4` | Avatar/KYC uploads, RM retrieval, policy storage; kyc_documents migration |

All commits are dated 2026-10-20 in git. The README narrates Phases 1–4; the
latest commit adds upload/extraction/RM work beyond that narration.

## Implemented and verified (L1 — automated tests pass)

Verified by running the suite: **173 tests passed** (`pytest -q`, 2026-10-20)
against the in-memory fake DB layer (`tests/fakes.py`). This does **not** exercise
live PostgreSQL.

- App foundation: envelope, central error handling, health/readiness, CORS,
  security headers, redacting logger, default-deny authorization.
- Auth (Phase 3): signup (invite-only), signin, session bootstrap, signout,
  invite verify, forgot/reset password. Argon2id passwords; opaque signed session
  cookie; double-submit CSRF; enumeration resistance; mass-assignment protection.
- Profile/settings read + update.
- Core client reads/writes (Phase 4): dashboard, policies list/detail, assets
  CRUD, family CRUD, claims (read), transactions (read, paginated), notifications,
  support tickets, master-data/FAQs.
- Policy operations (latest): `extract` (preview, persists nothing),
  `upload` (extract+merge+store with sha256 dedup, user-precedence merge,
  storage/DB compensation), `track`, `confirm`, `download` (ownership-enforced
  stream). `status` is an intentional 501 (no insurer integration).
- Upload primitives: content sniffing by magic bytes, size cap, private storage
  with path-traversal guard (unit-tested in `test_policies_storage.py`).

## Implemented but NOT verified (L0/L1 code only; no runtime check)

- **Avatar upload/download** and **KYC document upload/list/download** — fully
  coded (`app/modules/profile/uploads.py`, `router.py`) but have **no dedicated
  API tests**; the underlying storage/sniffing primitives are unit-tested.
- **RM assignment lookup** (`app/modules/rm/`) — derives the RM from the client's
  most recent support ticket with an assigned RM; **no RM test file**.
- **Real AI extraction path** (OpenAI-compatible call in
  `app/modules/policies/extraction.py`) — not exercised by tests (extraction is
  unconfigured in the suite); only the unavailable/degraded branch is tested.
- **Live PostgreSQL** — no `alembic upgrade head` against a real DB evidenced;
  real constraint/JSONB/UUID behaviour unverified. Migration *structure* is
  checked offline (`test_migration.py`, `test_env_alembic.py`).
- **End-to-end with the frontend** — contract matched and backend-tested, but no
  evidenced run of the SPA against this backend.

## Alembic migrations

1. `20261020_0001_0001_initial_schema` — full initial schema (users, profiles,
   policies incl. `verification_status`, stored_files, claims, assets, family,
   transactions, notifications/announcements, support, reference, audit).
2. `20261020_0002_0002_backfill_policy_verification_status` — idempotent backfill
   for DBs stamped at 0001 before the column existed; downgrade is a no-op.
3. `20261020_0003_0003_kyc_documents` — creates `kyc_documents`
   (unique per user+doc_type, status default `pending`).

## Known limitations / deferred (from README + code)

- Coverage/plan analysis on `/dashboard` is partial (returns `unavailable`).
- Claims are read-only; claim submission + document upload deferred.
- Transaction invoices deferred.
- Policy live status/track against an insurer is a 501 stub (no insurer integration).
- Support RM-assigned view and WebSocket live updates deferred (frontend polls).
- Reference/FAQ data is not seeded (empty tables return empty lists).
- No `sessions` table → revocation is user-level, not per-device.
- Invite creation (admin path) not implemented; email delivery not configured
  (dev returns `debug_token` only).
- PII (`pan_number`, `aadhaar_number`, `date_of_birth`) stored as plaintext
  typed columns; no column-level encryption/masking.

## Outstanding work (next actions)

- Run migrations against a live `qura_*` PostgreSQL and verify schema/constraints (L2).
- Add API tests for avatar + KYC endpoints and for RM lookup.
- Exercise the real extraction path against a configured LLM (test/sandbox).
- Implement claim submission + document upload pipeline.
- Implement transaction invoice generation.
- Add admin invite creation and email delivery.
- Decide on PII-at-rest encryption/masking.
- Integrate end-to-end with the SPA and confirm (L2/L3).

## Environment variables (keys only — no values)

`QURA_ENVIRONMENT`, `QURA_APP_NAME`, `QURA_API_PREFIX`, `QURA_HOST`, `QURA_PORT`,
`QURA_DATABASE_NAME_PREFIX`, `QURA_DATABASE_ECHO`, `QURA_DATABASE_POOL_SIZE`,
`QURA_DATABASE_MAX_OVERFLOW`, `QURA_DATABASE_POOL_TIMEOUT_SECONDS`,
`QURA_SESSION_SECRET`, `QURA_SESSION_COOKIE_NAME`, `QURA_CSRF_COOKIE_NAME`,
`QURA_SESSION_MAX_AGE_SECONDS`, `QURA_PASSWORD_RESET_TTL_SECONDS`,
`QURA_CORS_ALLOW_ORIGINS`, `QURA_CORS_ALLOW_CREDENTIALS`, `QURA_LOG_LEVEL`,
`QURA_LOG_JSON`, `QURA_STORAGE_DIR`, `QURA_UPLOAD_MAX_BYTES`,
`QURA_OPENAI_API_KEY`, `QURA_OPENAI_API_BASE`, `QURA_OPENAI_MODEL_NAME`,
`QURA_OPENAI_TIMEOUT_SECONDS`.
(`QURA_DATABASE_URL` is documented in the README; the DSN itself is a secret and
is not reproduced here.)
