# Qura Ecosystem — Architecture Overview

High-level architecture and the relationships between the Qura repositories.

Last verified: 2026-10-20

## Repositories in the workspace

| Repository | Role | Stack | Tracking boundary |
|---|---|---|---|
| `qura-client-server/` | Client-portal backend API | Python 3.12, FastAPI, SQLAlchemy 2.x (async + asyncpg), Alembic, PostgreSQL, Pydantic | Inspect only |
| `Qura-client-panel/` | Client-portal frontend SPA | React 18, Vite, TypeScript, Tailwind, shadcn/ui, Vitest | Inspect only |
| `qura-kb/` | Knowledge-base service + project tracking (this repo) | TBD (service not yet implemented) | Project-management docs live here |
| `arham-secure-server/` | Reference backend (prior project) | — | Strictly read-only reference; do NOT modify |

`qura-client-server` is a dedicated Qura service, independent of
`arham-secure-server`. Per its README it never connects to an Arham database and
has its own configuration, database and secrets.

## System relationships

```
                 ┌──────────────────────────┐
                 │   Qura-client-panel (SPA) │
                 │   React + Vite + TS       │
                 └────────────┬─────────────┘
                              │  HTTPS, session cookie (httpOnly)
                              │  + CSRF double-submit header
                              │  base path: /api/client
                              ▼
                 ┌──────────────────────────┐
                 │   qura-client-server      │
                 │   FastAPI                 │
                 │   {success,message,data}  │
                 └────┬───────────┬──────────┘
                      │           │
          async SQLA  │           │  multipart uploads → private filesystem
                      ▼           ▼          storage (avatar / kyc / policy docs)
          ┌───────────────┐   ┌──────────────────────┐
          │ PostgreSQL     │   │ OpenAI-compatible LLM │  (policy field extraction;
          │ (qura_* DB)    │   │ Chat Completions      │   optional, off when no key)
          │ Alembic schema │   └──────────────────────┘
          └───────────────┘

   qura-kb (this repo): standalone KB service — architecture + project tracking
   only so far; no runtime wiring to the portal yet.

   arham-secure-server: separate reference project. No live connection from
   the Qura services. Read-only.
```

## Integration contract (frontend ↔ backend)

- **Base path**: the SPA targets `/api/client` (dev default
  `http://127.0.0.1:8787/api/client`); Vite dev server proxies to the backend.
- **Envelope**: every backend response uses `{success, message, data}`.
- **Auth**: opaque, HMAC-signed session cookie `qura_client_session`
  (HttpOnly, SameSite=Lax). The current user is derived only from the validated
  session, never from a client-supplied id.
- **CSRF**: double-submit. JS-readable cookie `qura_client_csrf` echoed as
  `X-CSRF-Token` on mutating requests; verified in constant time.
- **Demo toggle (frontend)**: `VITE_DEMO_MODE=true` serves the identical feature
  code from an in-browser fixture adapter (`src/demo/demoApi.ts`) instead of the
  real backend. Default/dev config uses the real backend.

## Data and file storage

- **Schema authority**: Alembic is the sole schema authority on the backend; the
  app never creates or migrates the schema at startup and never auto-seeds.
- **DB guard**: refuses any DSN that is not the async driver or whose database
  name does not start with `qura_`; never falls back to another project's DB.
- **File storage**: uploads (avatar, KYC, policy documents) are stored on a
  private filesystem under a configured storage dir, with non-guessable keys and
  a path-traversal guard. No public URLs; downloads are ownership-checked streams.

## qura-kb positioning

`qura-kb` is intended to be a standalone knowledge-base service for the Qura
ecosystem. Its current, agreed scope is architecture definition and project
tracking (this documentation set). Implementing insurance knowledge features is
explicitly deferred. There is no runtime integration between `qura-kb` and the
portal yet; see `01-apps/QURA_KB.md` and `ROADMAP.md`.

## Cross-repository dependencies (summary)

- The frontend depends on the backend's `/api/client` contract (routes, envelope,
  cookie and CSRF names). Any backend contract change ripples to the SPA.
- End-to-end delivery depends on a live `qura_*` PostgreSQL database and applied
  Alembic migrations — not yet exercised.
- Policy AI extraction depends on an OpenAI-compatible endpoint + API key; absent
  the key the feature degrades honestly (manual entry), it does not fabricate.
- `qura-kb` service work depends on decisions still owed by the senior (scope,
  stack, and whether/how it integrates with the portal).

See `PROJECT_GIST.md` for the consolidated status and `BLOCKERS_AND_RISKS.md`
for open decisions.
