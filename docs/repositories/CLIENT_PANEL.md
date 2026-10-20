# Qura-client-panel — Repository Status

Client-portal frontend SPA.

Last verified: 2026-10-20

- Remote: `github.com/hsactofit/Qura-client-panel`
- Current branch inspected: `phase-6-7-testing-and-db-integration` (ahead of `origin/main`)
- Stack: React 18, Vite, TypeScript, Tailwind, shadcn/ui, Vitest
- Tracking boundary: **inspect only — not modified**

## Purpose and responsibilities

The customer-facing single-page app for the Qura client portal: auth, dashboard,
policies (incl. upload/preview/download), claims, support, notifications,
transactions, profile, settings, FAQs, an insurance marketplace purchase funnel,
and an admin user-management console. It talks to `qura-client-server` over
`/api/client` using the shared `{success, message, data}` envelope, session
cookie, and CSRF header.

## Architecture

- A single transport client `src/lib/api.ts` (`APIClient`) is the one chokepoint
  for all HTTP. It sends `credentials: 'include'`, attaches `X-CSRF-Token` on
  mutations, and classifies session-auth errors for global sign-out.
- `src/constants/apiRoutes.ts` is the full backend route map + base-URL
  normalization (coerces to end in `/api/client`).
- Typed service wrappers: `insurance.service.ts` (purchase funnel + policy
  upload/extract/track/confirm/download + assets), `notification.service.ts`,
  and `document.service.ts` (unused legacy localStorage store).
- `src/contexts/AuthContext.tsx` manages auth; it does **not** cache the user in
  localStorage (a deliberate security fix).
- **Demo toggle**: `DEMO_MODE = import.meta.env.VITE_DEMO_MODE === 'true'`. When
  true, the identical feature code is served by `src/demo/demoApi.ts` fixtures
  (fail-closed 503 for unmapped routes). When false (dev default), all features
  hit the real backend.

## Delivery timeline (from git history)

| Date | Commit | Summary |
|---|---|---|
| 2026-09-10 | `0979a87` | Initial commit |
| 2026-09-10 | `58baa37` | Create Qura frontend demo (full UI, ~163 files) |
| 2026-09-10 | `5d400ff` | Refine demo login presentation |
| 2026-10-20 | `98725d6` | Phase 5: integrate frontend with Qura backend (dev proxy, env config) |
| 2026-10-20 | `0c22201` | Integrate policy upload/preview/download + insurance service with backend |

## Implemented and verified (L1 — automated tests pass)

Verified by running the suite: **27 tests passed** across 4 files
(`vitest run`, 2026-10-20), in `jsdom` with stubbed `fetch`:
- `src/lib/api.test.ts` — transport client: session-auth error classification,
  global sign-out, credentials + CSRF header on mutations.
- `src/services/insurance.service.test.ts` — `isMotorProduct` classifier.
- `src/demo/demoApi.test.ts` — demo adapter lifecycle, fail-closed 503, no real
  contact data.
- `src/test/example.test.ts` — sample.

Tests cover the transport and the demo adapter; they do **not** exercise the
feature screens end-to-end against a live backend.

## Implemented and integrated (L0 — wired to backend, not runtime-verified here)

With `VITE_DEMO_MODE=false` all of these route to the real backend via `api` +
`API_ROUTES` (no evidenced live end-to-end run in this analysis):
- Auth (email/password), dashboard, policies list.
- Policy **upload** (`UploadPolicyModal` → `extractPolicy` then `uploadPolicy`),
  **preview** (`PolicyPreviewModal` → `/policies/{id}` + download),
  **download** (`DownloadPolicyModal` → `downloadPolicy` blob stream),
  **status polling + confirm** (`insurance/PolicyStatus.tsx`).
- Claims, support (incl. WebSocket routes), notifications, transactions, profile,
  settings, FAQs, assets CRUD, family CRUD, master data.
- Marketplace funnel (quotes → KYC → proposal → payment) and admin user
  management are wired to routes in `API_ROUTES`.

## Known gaps / stubs

- **Google sign-in** is an explicit stub: `signInWithGoogle` returns
  `Error("Google Sign In not implemented")`.
- **Nominees** in `PeopleManagement.tsx` are derived client-side from policy
  fields (hardcoded 100% share, empty DOB); in-file comment notes "backend
  doesn't return this yet". Family CRUD itself is a real backend resource.
- **`document.service.ts`** is a localStorage-backed demo store with **no
  callers** — legacy/dead code; real document flows go through
  `insurance.service`.
- The demo path (`demoApi.ts`) is by-design fictional data; it must not be
  mistaken for live behaviour.
- Several marketplace/insurer routes (plans, quotes, KYC, proposals, payments,
  PAN verify, vehicle lookup) exist in `API_ROUTES` on the frontend; their
  backend counterparts are **out of scope / not implemented** in
  `qura-client-server` (which documents marketplace/insurer features as deferred).
  This is a frontend-ahead-of-backend gap to confirm.

## Outstanding work (next actions)

- Run the SPA against the live backend + live PostgreSQL and verify core flows (L2).
- Reconcile frontend `API_ROUTES` (marketplace/insurer/KYC/payments) against
  backend availability; mark truly unsupported routes clearly.
- Implement Google sign-in or remove the stub.
- Decide whether nominees need a dedicated backend resource.
- Remove or repurpose the unused `document.service.ts`.

## Environment variables (keys only — no values)

`VITE_API_BASE_URL`, `VITE_DEMO_MODE`.
(Dev/demo variants live in `.env.development` and `.env.demo`.)

## Notes

The repo README still describes the app as a frontend-only demo with fictional
session data; the code has since been wired to the real backend behind the
`VITE_DEMO_MODE` toggle. The README is therefore stale relative to the Phase 5 /
integration commits — flagged in `BLOCKERS_AND_RISKS.md`.
