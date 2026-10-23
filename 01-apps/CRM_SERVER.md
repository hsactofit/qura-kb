# Qura-crm-server — Repository Status

Internal CRM backend API.

Last verified: 2026-10-23

- Remote: `github.com/hsactofit/Qura-crm-server`. **Note**: on 2026-10-23 the laptop's GitHub
  credentials got "Repository not found" for this repo (renamed, transferred or access changed?), while
  the other repos fetched fine. Needs confirming.
- Branch: `main` (latest `5051242`, 2026-10-07)
- Stack: Node 22, Express 5, TypeScript, Prisma 5 (PostgreSQL), JWT (HttpOnly cookie), multer, pdf-parse, exceljs, AWS S3 SDK (Cloudflare R2)
- Runtime: hs-minim1 → [03-infra/services/crm-server.md](../03-infra/services/crm-server.md)
- Spec docs: [02-architecture/crm/](../02-architecture/crm/)

## Purpose

The "Insurance Revenue Operating System" for agents, managers, compliance and admins: leads, accounts,
contacts, policies, claims, opportunities, renewals, tasks/My Day, calls/dispositions, compliance,
audit, analytics, settings.

## Modules (from `src/routes`, `src/services`)

Routes: `auth, users, accounts, leads, policies, documents, claims, opportunities, renewals, tasks,
telephony, compliance, analytics, search, settings`.
Services: `leadImport` (Excel), `leadTracking`, `pdfExtractor` (OpenAI, with text-rule fallback),
`r2Storage`, `smartfloAdapter`, `settings`.
Prisma models (19): User, Account, Contact, Lead, Policy, Claim, ServicingTicket, Document,
DocumentExtraction, Opportunity, Quote, Task, Activity, Call, Disposition, Grievance, AuditEvent,
SystemSetting.

## Delivery timeline (git)

| Date | Commit | Summary |
|---|---|---|
| 2026-10-01 | `b10c576` | Backend with Prisma, Aiven, R2, PDF parser, Smartflo |
| 2026-10-01 | `4fa6863`, `18ccfb6`, `01a9dcc`, `2370188`, `22942b3` | Renewals, opportunities, compliance, claims, bulk leads, opportunity stage, reassign + follow-up tasks |
| 2026-10-06 | `73133b3` … `0b78b14` | Users/settings routes, Smartflo improvements, Render deploy fixes |
| 2026-10-07 | `5051242` | Excel lead/policy import, OpenAI PDF extraction, R2 env names |

## Verification

- L2 (2026-10-23): builds from source and runs healthy on Postgres 16 (`prisma db push`, 18 tables) on hs-minim1.
- `npm run test:e2e` (lead → call → follow-up → close + permissions) exists. Not yet run against hs-minim1.
- No unit tests.

## Known gaps / risks

- Hardcoded JWT fallback secret in `src/config.ts` when `JWT_SECRET` is unset.
- `db:migrate` is `prisma db push`, so there is no migration history.
- `dist/` is committed (the infra Dockerfile rebuilds it).
- The seed script resets seeded users' passwords to `password123`. Never run it on production.
- Smartflo click-to-call isn't live (manual dial + outcome logging). R2 uploads need real credentials.
- `Qura-crm-kb/05` task tracker is stale: tasks are unchecked though the code exists.
