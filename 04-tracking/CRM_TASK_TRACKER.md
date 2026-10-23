# 05 - Multi-Agent Task Tracker & Development Roadmap

This document serves as the active task tracker and collaboration board for engineering teams and AI agents building **QURA INSURE CRM**.

---

## 📌 Implementation Phase Matrix & Status

| Phase | Description | Deliverables | Status |
| :--- | :--- | :--- | :--- |
| **Phase 0** | **KB & Foundation Setup** | Single source of truth documentation, DB schema, Aiven connection test. | ✅ **COMPLETED** |
| **Phase 1** | **Backend API & Database** | Node.js Express API server, Prisma/SQL migrations, seed data, JWT Auth, Account/Contact/Lead APIs. | 🔄 **IN PROGRESS** |
| **Phase 2** | **Frontend Panel & UI System** | Next.js panel, brand design system tokens, reverse proxy middleware, multi-level sidebar. | 🔄 **IN PROGRESS** |
| **Phase 3** | **Customer 360 & Lead Engine** | Customer 360 view, Lead state machine, My Day task queue. | 📅 **PLANNED** |
| **Phase 4** | **Policy Intelligence & OCR** | PDF upload to Cloudflare R2, document OCR parser, confidence verification workspace. | 📅 **PLANNED** |
| **Phase 5** | **Renewals & Telephony** | Renewal cycle generator (T-120 to T+7), Smartflo click-to-call, webhook receiver & disposition modal. | 📅 **PLANNED** |

---

## 📋 Task List & Progress Log

### Phase 0: Knowledge Base & Specs Architecture
- [x] `TASK-001`: Create `Qura-crm-kb/README.md` master overview.
- [x] `TASK-002`: Write `01-ARCHITECTURE-TECH-STACK.md` (Next.js proxy, Node.js API, Cloudflare R2, OCR, Smartflo).
- [x] `TASK-003`: Write `02-BRAND-GUIDELINES-DESIGN-SYSTEM.md` (Navy `#0A2342`, Lime `#BDF26E`, Inclusive Sans, Zalando Sans Expanded, multi-level sidebar).
- [x] `TASK-004`: Write `03-DATABASE-SCHEMA-MIGRATIONS.md` (Aiven Postgres SQL DDL, indexes, seed spec).
- [x] `TASK-005`: Write `04-API-CONTRACTS-SPECIFICATION.md` (REST envelopes, auth, policy, task, telephony endpoints).
- [x] `TASK-006`: Write `05-TASK-TRACKER-ROADMAP.md` (Multi-agent task tracking board).

### Phase 1: Backend Core (`Qura-crm-server`)
- [ ] `TASK-101`: Initialize Node.js TypeScript project in `Qura-crm-server` with Express, Prisma ORM, CORS, and dotenv.
- [ ] `TASK-102`: Set up Prisma schema targeting Aiven Postgres (`db.txt`).
- [ ] `TASK-103`: Create database migration script (`npm run db:migrate`).
- [ ] `TASK-104`: Create seed data script (`npm run db:seed`) populating admin/agent users, accounts, contacts, leads, policies, and tasks.
- [ ] `TASK-105`: Build JWT Authentication service & login endpoint (`/api/v1/auth/login`, `/api/v1/auth/me`).
- [ ] `TASK-106`: Build Accounts & Customer 360 API routes (`/api/v1/accounts`).
- [ ] `TASK-107`: Build Contacts & Leads state machine API routes (`/api/v1/leads`).
- [ ] `TASK-108`: Build Policy & Document Upload / Cloudflare R2 integration module.
- [ ] `TASK-109`: Build PDF OCR Extraction engine with confidence score scoring (`/api/v1/documents/upload`, `/extractions`).
- [ ] `TASK-110`: Build Tasks & My Day API routes (`/api/v1/tasks/my-day`).
- [ ] `TASK-111`: Build Smartflo Telephony Click-to-Call adapter & Webhook Receiver (`/api/v1/telephony/click-to-call`, `/webhooks`).

### Phase 2: Frontend Panel (`Qura-crrm-panel`)
- [ ] `TASK-201`: Initialize Next.js (App Router, TypeScript, TailwindCSS) in `Qura-crrm-panel`.
- [ ] `TASK-202`: Configure TailwindCSS with exact QURA INSURE brand color tokens (`qura-navy`, `qura-steel`, `qura-lime`, `qura-ice`, `qura-charcoal`).
- [ ] `TASK-203`: Build Next.js security middleware (`middleware.ts`) for API reverse proxy to Node backend (`http://localhost:4000`) and auth guard.
- [ ] `TASK-204`: Build modern high-end branded Login Page (Login only, no signup!).
- [ ] `TASK-205`: Build Multi-Level Collapsible Sidebar & Header layout with active state, search bar, and agent quick stats.
- [ ] `TASK-206`: Build Agent Home / My Day Dashboard view (Overdue callbacks, urgent renewals, lead queue).
- [ ] `TASK-207`: Build Customer 360 View (Accounts, contacts, active policies, activities, coverage gap matrix).
- [ ] `TASK-208`: Build Policy Intelligence Workspace & Drag-and-Drop PDF Upload with OCR side-by-side verification.
- [ ] `TASK-209`: Build Renewals Engine Workspace (T-120 to T+7 queues, automated task generation).
- [ ] `TASK-210`: Build Click-to-Call & Telephony Workspace with live call state indicator and post-call disposition drawer.

---

## 🤖 Multi-Agent Collaboration Protocol

1. **Check Out Tasks**: Update status in this document before taking ownership of a task.
2. **Commit Incremental Changes**: Ensure migrations and code edits compile cleanly before marking tasks complete.
3. **Do Not Overwrite Verified Logic**: Follow non-negotiable rules in `README.md`.
