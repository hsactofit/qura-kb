# QURA INSURE CRM — Knowledge Base & Single Source of Truth

Welcome to the **QURA INSURE Internal Insurance CRM Knowledge Base**. This repository serves as the definitive single source of truth for engineering teams, product managers, and AI coding agents building and extending the QURA INSURE CRM system.

---

## 📌 Executive Summary

QURA INSURE CRM is built as an **Insurance Revenue Operating System**, designed to answer four core operational questions at all times:
1. **Who should be contacted?**
2. **Why should they be contacted now?**
3. **What insurance relationship already exists?**
4. **What is the next compliant operational action?**

Unlike generic contact databases, QURA INSURE CRM treats **Policies**, **Renewals**, **Telephony Interactions**, and **Compliance Suppressions** as first-class domain entities with strict auditability and automation rules.

---

## 📂 Repository Structure & Documentation Index

| File | Description | Key Focus Areas |
| :--- | :--- | :--- |
| [📂 `01-ARCHITECTURE-TECH-STACK.md`](./01-ARCHITECTURE-TECH-STACK.md) | Technical Architecture & System Topography | Next.js Reverse Proxy, Node.js API Service, PostgreSQL, Cloudflare R2, PDF OCR Extractor |
| [📂 `02-BRAND-GUIDELINES-DESIGN-SYSTEM.md`](./02-BRAND-GUIDELINES-DESIGN-SYSTEM.md) | Official Brand & UI Design System | Color Tokens (`#0A2342` Navy, `#BDF26E` Lime Accent), Typography, Components, Multi-Level Sidebar |
| [📂 `03-DATABASE-SCHEMA-MIGRATIONS.md`](./03-DATABASE-SCHEMA-MIGRATIONS.md) | Data Model, Indexing & Seeding Strategy | 20+ Core Entities, UUID Keys, Migration Scripts, Seed Data Specification |
| [📂 `04-API-CONTRACTS-SPECIFICATION.md`](./04-API-CONTRACTS-SPECIFICATION.md) | REST API & Integration Contracts | Endpoints, Error Envelopes, Webhook Receivers, Smartflo Telephony Adapter |
| [📂 `05-TASK-TRACKER-ROADMAP.md`](./05-TASK-TRACKER-ROADMAP.md) | Multi-Agent Task Tracker & Development Roadmap | Phased Milestones, Multi-Agent Collaboration Protocol, Definition of Done |

---

## 🛠 Tech Stack Overview

- **Frontend (`Qura-crrm-panel`)**: Next.js (App Router, React 19, TypeScript), TailwindCSS, Framer Motion, Lucide Icons. Features Next.js Security Middleware & Reverse Proxy.
- **Backend (`Qura-crm-server`)**: Node.js + Express (TypeScript), Prisma ORM / SQL Migrations, JWT Auth, PDF Extraction & Heuristic Parsing engine.
- **Database**: PostgreSQL (Hosted on Aiven Cloud - SSL required).
- **Document & Media Storage**: Cloudflare R2 (S3-compatible Object Storage).
- **Telephony Integration**: Tata Tele Business Services Smartflo API & Asynchronous Webhooks.

---

## 🔐 Environment & Credentials Matrix

| Service | Connection / Credentials Location |
| :--- | :--- |
| **PostgreSQL Database** | `referneces/db.txt` (`postgres://avnadmin:***@non-prod-server-actofit-57d1.h.aivencloud.com:15898/defaultdb?sslmode=require`) |
| **Cloudflare R2 Bucket** | Configured via `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_ENDPOINT`, `R2_BUCKET_NAME` |
| **Node API Port** | `http://localhost:4000` (Proxied via Next.js middleware at `/api/v1/*`) |
| **Next.js Panel Port** | `http://localhost:3000` |

---

## 🛑 Non-Negotiable Engineering Invariants

1. **Policy is a First-Class Domain Object**: Never store an uploaded policy document merely as an attachment on a lead record.
2. **Never Treat 2xx Click-to-Call Response as Connected**: Smartflo telephony is asynchronous; call completion and status originate strictly from webhooks and CDR reconciliation.
3. **No Public Signup**: Internal CRM panel has Login authentication only.
4. **Idempotent Webhooks & Jobs**: Webhook receivers and background renewal generators must be replay-safe with deduplication keys.
5. **Audit History for Mutable Business Fields**: All owner changes, policy date edits, premium changes, and disposition updates must create immutable audit records.
