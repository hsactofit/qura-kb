# ADR-001 — Self-host backends on a Mac mini behind Cloudflare Tunnel

- Status: Accepted (2026-10-23, requested by Himanshu)
- Scope: `qura-client-server`, `Qura-crm-server`, Postgres. Frontends stay on Vercel.

## Context

Backends were spread across Render (CRM API), an undeployed FastAPI service
(client API, Dockerfile only) and a shared non-prod Aiven Postgres. A spare
Mac mini M1 (8 GB) is available as an always-on server.

## Decision

| Concern | Choice | Why |
|---|---|---|
| Runtime | Docker via **Colima** (VZ VM, 4 CPU / 3 GB / 60 GB) | Lightest free Docker on macOS; the same compose file runs on any Linux box, so moving off the Mac is a copy-paste. Docker Desktop is heavier and licensed. |
| Database | One **Postgres 16** container, named volume, one DB + role per service | One instance fits the 8 GB budget; per-service roles isolate data. |
| Ingress | **Cloudflare Tunnel** (cloudflared container) | No open ports or static IP; TLS + DDoS at the edge. |
| Boot | **launchd LaunchDaemons** (run before login) | Survives reboot/power loss without anyone logging in. |
| CD | **Pull-based deployer** polling `main` every 60 s | No inbound webhooks, no GitHub secrets, no runner to maintain. Build → health check → automatic rollback. |
| Backups | Nightly `pg_dump` + upload volumes, plus a dump before every deploy | Recoverable from a bad migration or a broken volume. |
| Infra-as-code | `qura-kb/infra/`, auto-applied from `qura-kb` main | One repo holds both the docs and the scripts they describe. |

## Consequences

- Single machine = single point of failure. Mitigations: auto-restart after power
  loss, the watchdog, nightly dumps. **Off-machine backup copies are still open**
  (see `03-infra/BACKUPS.md`).
- Home/office internet becomes the API's uplink.
- Frontends (Vercel) must reach APIs same-origin via rewrites/proxies (cookie + CSP
  constraints); see `03-infra/services/*`.
