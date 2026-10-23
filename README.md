# qura-kb — Qura knowledge base

The single source of truth for the whole Qura ecosystem: products, apps, architecture,
infrastructure, tracking, decisions. It replaces `Qura-crm-kb`, whose content now lives here.
It also holds `infra/`, the code that runs the servers.

## The ecosystem in one table

| Product | Frontend | Backend | Runs on |
|---|---|---|---|
| **Client portal** (customers) | `Qura-client-panel` (React/Vite) | `qura-client-server` (FastAPI) | Vercel + hs-minim1 |
| **CRM** (internal agents/managers) | `Qura-crrm-panel` (Next.js) | `Qura-crm-server` (Express/Prisma) | Vercel + hs-minim1 (moving off Render/Aiven) |
| **Marketing site** | `qura-insure-site` (Next.js) | — | TBD |

## Map

| Folder | What's in it |
|---|---|
| [00-overview/](00-overview/) | [PROJECT_GIST](00-overview/PROJECT_GIST.md) (start here), [STATUS_RULES](00-overview/STATUS_RULES.md) (status values and verification levels L0–L3) |
| [01-apps/](01-apps/) | One page per repo: [client-server](01-apps/CLIENT_SERVER.md), [client-panel](01-apps/CLIENT_PANEL.md), [crm-server](01-apps/CRM_SERVER.md), [crm-panel](01-apps/CRM_PANEL.md), [insure-site](01-apps/INSURE_SITE.md), [qura-kb](01-apps/QURA_KB.md) |
| [02-architecture/](02-architecture/) | [Ecosystem overview](02-architecture/ARCHITECTURE_OVERVIEW.md); [crm/](02-architecture/crm/) (CRM architecture, DB schema, API contracts) |
| [03-infra/](03-infra/) | Servers, services, deploy pipeline, backups, runbooks, changelog. **[Start at 03-infra/README](03-infra/README.md)** |
| [04-tracking/](04-tracking/) | [Issue register](04-tracking/ISSUE_REGISTER.md), [roadmap](04-tracking/ROADMAP.md), [completion log](04-tracking/COMPLETION_LOG.md), [blockers and risks](04-tracking/BLOCKERS_AND_RISKS.md), [CRM task tracker](04-tracking/CRM_TASK_TRACKER.md) |
| [05-migrations/](05-migrations/) | Planned and in-flight moves (hosting, DBs, data) |
| [06-decisions/](06-decisions/) | ADRs: why each architecture or infra call was made |
| [07-design/](07-design/) | [Brand guidelines and design system](07-design/BRAND_GUIDELINES.md) |
| [08-runbooks/](08-runbooks/) | Product runbooks ([CRM demo walkthrough](08-runbooks/CRM_DEMO_WALKTHROUGH.md)). Infra runbooks are in `03-infra/runbooks/` |
| [infra/](infra/) | Executable infra: compose, Dockerfiles, scripts, launchd/systemd units, service registry |

## Conventions

- Evidence-based entries (git, code, tests, runtime checks). Inferred items are marked **provisional**.
- No secrets, credentials or customer data, ever. Use env-var **names** only.
- Tracking IDs: `CS-` client-server, `CP-` client-panel, `CRM-` CRM server/panel, `SITE-` marketing site,
  `INFRA-` infrastructure, `KB-` this repo, `X-` cross-repo.
- Infra changes: edit `infra/` and add a line to `03-infra/CHANGELOG.md`. Pushes to `main` are applied to
  servers automatically.

Last verified: 2026-10-23
