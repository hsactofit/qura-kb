# 04 - API Contracts & Endpoint Specification

All backend endpoints are scoped under `/api/v1/` and return consistent JSON structures.

---

## 📩 Standard API Response Envelopes

### Success Response (`HTTP 200 / 201`)

```json
{
  "success": true,
  "data": {
    "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "display_name": "Acme Logistics Pvt Ltd",
    "type": "COMPANY"
  },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
```

### Error Envelope (`HTTP 400 / 401 / 403 / 404 / 500`)

```json
{
  "success": false,
  "error": {
    "code": "TELEPHONY_TEMPORARILY_UNAVAILABLE",
    "message": "Calling is temporarily unavailable. Your task has been preserved.",
    "request_id": "req-9812401",
    "retryable": true,
    "details": []
  }
}
```

---

## 🛣 Core REST Endpoint Groups

### 🔑 Auth & Session APIs
- `POST /api/v1/auth/login`: Authenticate internal user (Email + Password) -> Sets HTTP-only JWT cookie & returns user object.
- `GET /api/v1/auth/me`: Get currently logged-in user profile & role permissions.
- `POST /api/v1/auth/logout`: Clear session cookies.

### 🏢 Account & Customer 360 APIs
- `GET /api/v1/accounts`: List accounts (with filters, pagination, search).
- `POST /api/v1/accounts`: Create new account.
- `GET /api/v1/accounts/:id`: Get complete Customer 360 profile (policies, contacts, activities, coverage gap matrix).
- `PATCH /api/v1/accounts/:id`: Update account details.

### 👤 Contact & Channel APIs
- `GET /api/v1/contacts`: List contacts.
- `POST /api/v1/contacts`: Create contact linked to an account.

### 🎯 Lead Lifecycle APIs
- `GET /api/v1/leads`: List leads with status state filter.
- `POST /api/v1/leads`: Intake lead (applies duplicate matching service).
- `PATCH /api/v1/leads/:id/status`: Advance lead status state machine (`NEW` -> `ATTEMPTING_CONTACT` -> `CONNECTED` -> `ACTIVE_OPPORTUNITY`, etc.).

### 📜 Policy Intelligence & Document APIs
- `GET /api/v1/policies`: List policies (with expiry date filters).
- `POST /api/v1/policies`: Create policy manually.
- `POST /api/v1/documents/upload`: Upload policy PDF document (saves to Cloudflare R2 & enqueues OCR extraction).
- `GET /api/v1/documents/:id/extractions`: Fetch OCR extraction candidate fields and confidence scores.
- `POST /api/v1/documents/:id/verify`: Human verification endpoint (approves extracted policy fields and creates/verifies policy object).

### ⚡ Tasks & My Day Queue APIs
- `GET /api/v1/tasks/my-day`: Get prioritized task list for logged-in agent (overdue callbacks, urgent renewals, new leads first-contact SLA).
- `PATCH /api/v1/tasks/:id/complete`: Complete task with mandatory completion reason / activity link.

### 📞 Telephony & Smartflo Integration APIs
- `POST /api/v1/telephony/click-to-call`: Initiate outbound click-to-call.
- `POST /api/v1/integrations/smartflo/webhooks`: Smartflo asynchronous webhook receiver (handles `AGENT_RINGING`, `CONNECTED`, `ENDED`, `DISPOSITION_PENDING`).
- `POST /api/v1/calls/:id/disposition`: Save business disposition after call completion (creates next task or updates opportunity stage).

---

## 📞 Example Outbound Click-to-Call Request

`POST /api/v1/telephony/click-to-call`
Headers: `Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000`

```json
{
  "contact_id": "b3e1c667-27e1-450f-90e6-b6033878b19a",
  "related_type": "opportunity",
  "related_id": "a1f2c3d4-e5f6-7890-abcd-ef1234567890",
  "purpose": "RENEWAL_SERVICE"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "crm_call_id": "call-77123-uuid",
    "status": "REQUESTED",
    "message": "Call initiated. Ringing agent leg..."
  }
}
```
