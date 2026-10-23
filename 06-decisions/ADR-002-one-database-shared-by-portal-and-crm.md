# ADR-002 — One database shared by the client portal and the CRM

Status: **Accepted** (2026-10-23) · Supersedes the "one database per service" part of [ADR-001](ADR-001-self-host-backends-on-mac-mini.md)

## Context

The client portal (customers) and the CRM (sales, ops, claims) serve the same product from two angles.
A policy a client uploads must reach an advisor for review; a policy an advisor adds must appear in the
client's portal; renewals, call backs, questions and claims flow both ways. Two separate databases
would need a message bus or point-to-point APIs to stay in step.

Both apps define tables with the same names (`users`, `policies`, `claims`, `documents`), each has
its own migration tool (Alembic vs `prisma db push`), and `prisma db push` drops tables it doesn't know.

## Decision

- One Postgres database, **`qura_main`**, with one **schema per app**:
  `client` (owned by role `qura_client`, Alembic) and `crm` (owned by `qura_crm`, Prisma `?schema=crm`).
- Each app **writes only its own schema** and has **read-only** access to the other's
  (grants + default privileges in `infra/postgres/shared-db.sql`).
- Each app runs a small **state-based sync loop** that reads the other schema and imports what it
  doesn't have yet (link columns decide "already imported"; nothing is event-based, so restarts lose nothing).
  Details: [02-architecture/PORTAL_CRM_SYNC.md](../02-architecture/PORTAL_CRM_SYNC.md).
- Files: the portal's upload volume is mounted read-only into the CRM (one copy). Files the CRM stores
  (local volume, or R2 when configured) reach the portal through a token-protected internal endpoint on
  the Docker network.

## Consequences

- One backup and one restore unit (`qura_main`) for the whole product; cross-schema reporting is plain SQL.
- Each side's sync code knows a few of the other side's column names; changing a linked column needs a
  coordinated release (listed in PORTAL_CRM_SYNC.md).
- Neither app can corrupt the other's data (no cross-schema write grants).
- The legacy per-service databases `qura_client` and `qura_crm` on hs-minim1 hold only pre-launch test
  data and can be dropped (INFRA-16).
