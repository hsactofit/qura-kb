# 03 - Database Schema, Indexing & Migration Strategy

This document details the PostgreSQL database schema for **QURA INSURE CRM**, hosted on Aiven Cloud (`postgres://avnadmin:***@non-prod-server-actofit-57d1.h.aivencloud.com:15898/defaultdb?sslmode=require`).

---

## 🗄 Core Database Entities Summary

The system consists of 20+ core tables using UUID/ULID primary keys:

| Table Name | Primary Purpose | Key Foreign Keys & Indexing |
| :--- | :--- | :--- |
| `users` | Internal CRM users, agents, managers | `email` (Unique), `role` |
| `teams` | Team hierarchy for assignment rules | `manager_user_id` |
| `accounts` | Customer accounts (Individual, Household, Corporate) | `owner_user_id`, `lower(display_name)` |
| `contacts` | Individual contact details & channels | `account_id`, `mobile_e164`, `lower(email)` |
| `contact_channels` | Normalized phone/email endpoints | `contact_id`, `normalized_value` |
| `leads` | Inbound lead intake state machine | `account_id`, `contact_id`, `status`, `assigned_to` |
| `insurance_needs` | Account coverage gap matrix | `account_id`, `category_id`, `state` |
| `policies` | First-class policy objects | `account_id`, `policy_number`, `expiry_date`, `status` |
| `policy_parties` | Policyholder/Insured/Nominee roles | `policy_id`, `contact_id` |
| `policy_assets` | Vehicles, properties, assets linked to policies | `policy_id`, `asset_id` |
| `assets` | Physical/corporate assets insured | `account_id`, `type` |
| `documents` | Private PDF policy documents stored in Cloudflare R2 | `account_id`, `policy_id`, `checksum`, `object_key` |
| `document_extractions` | OCR candidate extractions & review state | `document_id`, `status` (`pending`, `needs_review`, `verified`) |
| `opportunities` | Sales & renewal pipeline opportunities | `account_id`, `contact_id`, `owner`, `stage`, `expected_close_date` |
| `quotes` | Versioned insurer quotes | `opportunity_id`, `insurer_id`, `version` |
| `tasks` | Action queue tasks (Calls, Renewals, Followups) | `owner`, `due_at`, `status`, `priority` |
| `activities` | Timeline log of all customer interactions | `account_id`, `contact_id`, `actor_user_id` |
| `calls` | Smartflo telephony call records | `crm_ref_id`, `smartflo_ref_id`, `smartflo_call_id`, `status` |
| `call_events` | Idempotent telephony webhook event log | `provider_event_id` (Unique hash), `call_id` |
| `dispositions` | Business call outcome taxonomy | `code` (Unique), `requires_next_task` |
| `consents` | Opt-in consent register | `contact_id`, `channel`, `purpose` |
| `suppressions` | DNC and communication suppression list | `contact_id`, `channel`, `expires_at` |
| `grievances` | Complaint & escalation records | `account_id`, `due_at`, `status` |
| `audit_events` | Immutable business & security audit trail | `entity_type`, `entity_id`, `actor_user_id`, `timestamp` |

---

## 📐 Complete SQL DDL Schema Definition

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users & Teams
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'AGENT', -- ADMIN, SUPER_ADMIN, AGENT, MANAGER, COMPLIANCE
    smartflo_agent_id VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL, -- INDIVIDUAL, HOUSEHOLD, COMPANY
    display_name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    gstin VARCHAR(50),
    owner_user_id UUID REFERENCES users(id),
    lifecycle_status VARCHAR(50) NOT NULL DEFAULT 'PROSPECT',
    source_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    mobile_e164 VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    designation VARCHAR(100),
    preferred_language VARCHAR(50) DEFAULT 'English',
    is_primary BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source VARCHAR(100) NOT NULL,
    account_id UUID REFERENCES accounts(id),
    contact_id UUID REFERENCES contacts(id),
    status VARCHAR(50) NOT NULL DEFAULT 'NEW', -- NEW, ATTEMPTING_CONTACT, CONNECTED, NEED_DISCOVERY, POLICY_REQUESTED, POLICY_RECEIVED, FUTURE_RENEWAL, ACTIVE_OPPORTUNITY, WON, LOST, DNC
    product_interest VARCHAR(100),
    assigned_to UUID REFERENCES users(id),
    captured_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    converted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE policies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    insurer_id VARCHAR(100) NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    policy_number VARCHAR(100),
    category_id VARCHAR(50) NOT NULL, -- MOTOR, HEALTH, LIFE, PROPERTY, MARINE, GROUP_HEALTH
    business_type VARCHAR(50) DEFAULT 'EXTERNAL_EXISTING', -- EXTERNAL_EXISTING, QURA_ISSUED, IMPORTED_LEGACY
    start_date DATE,
    expiry_date DATE,
    premium NUMERIC(12,2),
    currency VARCHAR(10) DEFAULT 'INR',
    sum_insured NUMERIC(14,2),
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- draft, active, expired, cancelled, lapsed
    owner_user_id UUID REFERENCES users(id),
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    policy_id UUID REFERENCES policies(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'POLICY_PDF',
    object_key VARCHAR(500) NOT NULL,
    mime VARCHAR(100) NOT NULL,
    size_bytes BIGINT NOT NULL,
    checksum VARCHAR(100),
    uploaded_by UUID REFERENCES users(id),
    classification VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE document_extractions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
    extractor_version VARCHAR(50) NOT NULL,
    raw_json JSONB,
    normalized_json JSONB,
    confidence_json JSONB,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, needs_review, verified, rejected
    reviewed_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE opportunities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id),
    type VARCHAR(50) NOT NULL DEFAULT 'NEW', -- NEW, RENEWAL, CROSS_SELL
    category_id VARCHAR(50) NOT NULL,
    stage VARCHAR(50) NOT NULL DEFAULT 'QUALIFICATION',
    owner_user_id UUID REFERENCES users(id),
    expected_close_date DATE,
    estimated_premium NUMERIC(12,2),
    source_policy_id UUID REFERENCES policies(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL, -- CALL, CALLBACK, POLICY_DOCUMENT_FOLLOWUP, QUOTE_PREPARE, RENEWAL_ACTION
    subject VARCHAR(255) NOT NULL,
    due_at TIMESTAMP WITH TIME ZONE NOT NULL,
    owner_user_id UUID REFERENCES users(id),
    related_type VARCHAR(50), -- account, contact, lead, policy, opportunity
    related_id UUID,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, IN_PROGRESS, COMPLETED, CANCELLED, OVERDUE
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL', -- LOW, NORMAL, HIGH, URGENT
    completed_at TIMESTAMP WITH TIME ZONE,
    completion_reason VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE calls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    direction VARCHAR(20) NOT NULL, -- OUTBOUND, INBOUND
    provider VARCHAR(50) DEFAULT 'SMARTFLO',
    crm_ref_id VARCHAR(100) UNIQUE NOT NULL,
    smartflo_ref_id VARCHAR(100),
    smartflo_call_id VARCHAR(100),
    account_id UUID REFERENCES accounts(id),
    contact_id UUID REFERENCES contacts(id),
    user_id UUID REFERENCES users(id),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    answered_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL DEFAULT 'REQUESTED', -- REQUESTED, ACCEPTED, AGENT_RINGING, CUSTOMER_RINGING, CONNECTED, ENDED, MISSED_CUSTOMER, RECONCILED, DISPOSITION_PENDING, COMPLETE
    disposition_code VARCHAR(100),
    duration_sec INT DEFAULT 0,
    recording_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE, UPLOAD, EXPORT, DISPOSITION
    actor_user_id UUID REFERENCES users(id),
    source VARCHAR(50) DEFAULT 'USER', -- USER, SYSTEM, SMARTFLO, IMPORT
    request_id VARCHAR(100),
    field_diff JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

## ⚡ Mandatory Database Indexes

```sql
CREATE INDEX idx_contacts_mobile ON contacts(mobile_e164);
CREATE INDEX idx_contacts_email ON contacts(lower(email));
CREATE INDEX idx_accounts_name ON accounts(lower(display_name));
CREATE INDEX idx_policies_number ON policies(policy_number);
CREATE INDEX idx_policies_expiry ON policies(expiry_date, status);
CREATE INDEX idx_opportunities_owner ON opportunities(owner_user_id, stage);
CREATE INDEX idx_tasks_owner_due ON tasks(owner_user_id, status, due_at);
CREATE INDEX idx_calls_crm_ref ON calls(crm_ref_id);
CREATE INDEX idx_calls_smartflo_id ON calls(smartflo_call_id);
CREATE INDEX idx_audit_entity ON audit_events(entity_type, entity_id);
```

---

## 🚀 Migration & Seed Data Workflow

- **Migration Command**: `npm run db:migrate` (Executes Prisma / SQL migration scripts against Aiven DB).
- **Seed Command**: `npm run db:seed` (Populates initial roles, demo admin/agent users, insurance product catalog, sample leads, policies, and My Day tasks).
