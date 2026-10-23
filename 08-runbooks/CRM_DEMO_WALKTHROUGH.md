# QURA INSURE — Internal Insurance CRM Demo & Walkthrough Guide

---

## 1. Executive Summary & Core Platform Overview

**QURA INSURE** is an enterprise-grade Internal Insurance CRM designed specifically for Indian insurance brokers and agency operations. It enables agents, underwriting teams, claims adjudicators, and administrators to track, service, and maintain end-to-end policy lifecycles.

### Architecture Overview
- **Backend (`Qura-crm-server`)**: Node.js (Express + TypeScript + Prisma ORM) connected to Aiven PostgreSQL with SSL/TLS.
- **Frontend (`Qura-crrm-panel`)**: Next.js 16 (App Router + TypeScript + TailwindCSS + Lucide Icons) with security reverse proxy middleware (`middleware.ts`).
- **Integrations**: Cloudflare R2 object storage for policy PDFs, OCR extraction engine, Tata Smartflo Telephony CTI adapter.
- **Single Source of Truth (`Qura-crm-kb`)**: Markdown documentation suite.

---

## 2. Roles

Roles come from the logged-in user (there is no client-side role switcher). Agents see only their own leads, tasks and calls; managers and admins see the whole team and can reassign; only admins open System Settings; managers/compliance read the audit trail.

| Login (password `password123`, dev only) | Role |
| :--- | :--- |
| `agent@qurainsure.com` | Agent (Rohan Verma) |
| `manager@qurainsure.com` | Manager (Priya Sharma) |
| `admin@qurainsure.com` | Super admin |

Reset demo data: `npm run db:reset` in `Qura-crm-server` (deletes all CRM business data, keeps users; non-prod only). `npm run db:seed` alone is idempotent.

---

## 3. Lead Tracking Flow (what to demo)

1. **New Lead** (`/dashboard/leads`): mobile is validated/normalised; a duplicate open lead for the same number is flagged with a link to the existing lead. Every new lead gets an automatic first-contact task (SLA from Admin → SLA rules) in the assignee's **My Day**.
2. **My Day** (`/dashboard/my-day`): overdue first. **Call** opens the dialer; with Smartflo not yet connected the agent dials manually and then **logs the outcome**. Outcomes drive the lead: No answer/Busy → Attempting contact, Interested/Call back → Connected, Quote requested → Quote in progress, Not interested → closed, DNC → closed + number suppressed. Outcomes that need a next step require a follow-up date.
3. **Lead detail** (`/dashboard/leads/:id`): next follow-up, open tasks (Done with note / snooze), notes, full activity timeline, call history, audit trail, status changes (Won/Lost need a reason; Active Opportunity creates a pipeline opportunity). A lead has exactly one open follow-up; rescheduling replaces it.
4. **Reassignment** (managers): open follow-ups move to the new owner and the change is audited.
5. **Analytics**: per-agent overdue follow-ups and open leads with no follow-up scheduled.

## 4. Known Gaps

- **Smartflo click-to-call** is not implemented; calls are logged as manual dials. Webhooks need `SMARTFLO_WEBHOOK_SECRET`.
- **Cloudflare R2** credentials in `.env` are placeholders, so policy/claim uploads return "storage not configured" until real values are set.

## 5. Automated Check

`npm run test:e2e` in `Qura-crm-server` (servers running) exercises the lead → call → follow-up → close lifecycle and the permission rules, and cleans up its own data.
