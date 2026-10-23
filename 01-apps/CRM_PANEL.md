# Qura-crrm-panel — Repository Status

Internal CRM frontend. (The repo name really is spelled `crrm`.)

Last verified: 2026-10-23

- Remote: `github.com/hsactofit/Qura-crrm-panel`, branch `main` (latest `99f084a`, 2026-10-07)
- Stack: Next.js 16 (App Router), React 19, Tailwind 4, Framer Motion, Lucide
- Hosting: Render `qura-panel` today → Vercel (target). Env: `API_URL` (CRM API base URL)

## How it talks to the API

`src/proxy.ts` (Next 16 "proxy", formerly middleware) rewrites `/api/v1/*` to `API_URL`, adds
`Authorization: Bearer <token cookie>`, and gates `/dashboard/*` on the `token` cookie. Login only,
no signup.

## Screens (`src/app`)

`/login`, `/dashboard` + `my-day, leads, leads/[id], accounts, contacts, policies, documents/upload,
claims, calls, dispositions, opportunities, renewals, reminders, coverage-gaps, compliance, audit,
analytics, admin`.

## Timeline

2026-10-01: full panel built (Customer 360, leads, pipeline, admin hub, claims, reminders, collapsible sidebar).
2026-10-06: dialer modal, login redesign, Render config. 2026-10-07: Excel import screen,
lead-linked policy PDF upload, lead details.

## Known gaps

- No tests.
- Moving to Vercel needs `API_URL=https://crm-api.<domain>` on the Vercel project.
