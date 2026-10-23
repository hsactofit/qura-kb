# 01 - Technical Architecture & Tech Stack Specification

## System Topography & Physical Architecture

```
                               ┌──────────────────────────────────────────────┐
                               │             Client Browser                   │
                               │        (Qura Insure CRM Panel)               │
                               └──────────────────────┬───────────────────────┘
                                                      │ HTTPS / WSS
                                                      ▼
                              ┌────────────────────────────────────────────────┐
                              │            Next.js Reverse Proxy               │
                              │       (Security Middleware & Auth Guard)       │
                              └───────────────────────┬────────────────────────┘
                                                      │ Proxy Pass / Request Guard
                                                      ▼
                              ┌────────────────────────────────────────────────┐
                              │              Node.js API Server                │
                              │        (Express / TypeScript Engine)           │
                              └──────┬────────────────┬────────────────┬───────┘
                                     │                │                │
            ┌────────────────────────┘                │                └────────────────────────┐
            ▼                                         ▼                                         ▼
┌────────────────────────┐               ┌────────────────────────┐                ┌────────────────────────┐
│   Aiven PostgreSQL DB  │               │   Cloudflare R2 Bucket │                │ Tata Smartflo Telephony│
│ (SSL Encrypted Port)   │               │   (Private Object Store) │                │  (Webhooks & REST API) │
└────────────────────────┘               └────────────────────────┘                └────────────────────────┘
```

---

## Technical Stack Standard

| Subsystem | Selected Technology | Rationale & Configuration |
| :--- | :--- | :--- |
| **Frontend Framework** | **Next.js (React 19 / App Router)** | Production-grade SSR/SPA capabilities, fast internal UX, modular component architecture. |
| **Styling & Icons** | **TailwindCSS + Framer Motion + Lucide** | Custom brand color palette tokens (`#0A2342` Navy, `#BDF26E` Lime Accent), dark/light glassmorphism, dynamic animations. |
| **Security Proxy** | **Next.js `middleware.ts`** | Reverse proxy security layer for API request header sanitization, JWT authorization verification, and path isolation. |
| **Backend API Service**| **Node.js (Express + TypeScript)** | Strongly typed modular architecture, REST endpoint schemas, validation middleware, async task handling. |
| **Database & ORM** | **PostgreSQL + Prisma ORM** | Relational integrity, UUID keys, migration history, seed data management, JSONB fields for dynamic policy extraction metadata. |
| **Document Storage** | **Cloudflare R2 (S3 API Compatible)** | Private bucket storage for uploaded policy PDFs, encrypted signed URLs for temporary browser viewing, zero egress fees. |
| **OCR & Extraction** | **Node PDF Parser Engine** | Hybrid PDF text extraction + heuristic regex patterns + LLM parsing fallback with verification confidence scores (`pending`, `needs_review`, `verified`). |
| **Telephony Adapter** | **Tata Smartflo API Adapter** | Isolated provider integration adapter for click-to-call, call state management, webhook receivers, and CDR reconciliation. |

---

## 🔒 Next.js Reverse Proxy & Middleware Security

The Next.js panel acts as a security reverse proxy in front of the Node.js backend server:
1. **API Routing**: Requests to `/api/v1/*` are proxied to Node.js backend (`http://localhost:4000/api/v1/*`).
2. **Session / Token Interception**: Validates JWT bearer tokens stored in HTTP-only secure cookies before forwarding requests to the Node backend.
3. **CORS & Header Enforcement**: Inject security headers (`X-Frame-Options`, `X-Content-Type-Options`, `Content-Security-Policy`) and strip direct backend server identifiers.
4. **No Direct Secret Exposure**: Frontend never accesses Cloudflare R2 credentials or Smartflo API bearer tokens.

---

## 📄 Cloudflare R2 Document Storage Architecture

- **Private Upload Flow**:
  1. Frontend requests a short-lived presigned upload URL or posts file to `/api/v1/documents/upload`.
  2. Server performs MIME type validation and file signature check (PDF magic bytes `%PDF-`).
  3. File is stored in Cloudflare R2 private bucket with object key pattern: `policies/{account_id}/{document_uuid}.pdf`.
  4. Database record created in `documents` table with `object_key`, `checksum`, and `mime`.
- **Private View Flow**:
  - Raw R2 URLs are **never** exposed to client browser.
  - Browser accesses temporary signed proxy URLs valid for 15 minutes after server permission checks.

---

## 🧠 Policy Intelligence & OCR PDF Extraction Engine

```
[ Upload PDF ] ──► [ R2 Object Storage ] ──► [ Enqueue Extraction Job ]
                                                     │
                                                     ▼
                                          [ PDF Text & Layout Extraction ]
                                                     │
                                                     ▼
                                          [ Field Normalization & Regex ]
                                          - Policy Number
                                          - Start / Expiry Date
                                          - Premium & Sum Insured
                                          - Insurer Name & Category
                                                     │
                                                     ▼
                                          [ Confidence Scoring ]
                              ┌──────────────────────┴──────────────────────┐
                              ▼                                             ▼
                   [ Score >= 0.85: Verified ]                    [ Score < 0.85: Human Review ]
                              │                                             │
                              ▼                                             ▼
                 [ Auto-Trigger Renewals ]                     [ Open Verification UI Modal ]
```

---

## 📞 Telephony Integration (Tata Smartflo) Architecture

1. **Provider Isolation**: All Smartflo endpoints (`/v1/click_to_call`, `/v1/call_records`) are invoked strictly through `SmartfloAdapter` inside Node.js backend.
2. **Asynchronous Webhook Receiver**:
   - Webhook endpoint `/api/v1/integrations/smartflo/webhooks` operates without browser session auth but requires provider signature / token verification.
   - Immediately returns HTTP 200/202 to Smartflo, persisting raw payload into `call_events` table before async processing.
   - Idempotent deduplication based on `provider_event_id` or deterministic payload hash.
3. **CDR Reconciliation Worker**:
   - Periodic background job queries Smartflo CDR API to reconcile call durations, recording URLs, and disconnect causes.
