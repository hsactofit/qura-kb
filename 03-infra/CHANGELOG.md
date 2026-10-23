# Infra changelog

Newest first. One line per change: date — server/scope — what — who.

## 2026-10-23

- hs-minim1 — Fresh macOS host turned into the backend server: Homebrew, Colima (4 CPU / 3 GB / 60 GB),
  Docker, compose, cloudflared; power policy set to never sleep and to restart after power loss. — Claude Code for Himanshu
- hs-minim1 — Postgres 16 with `qura_client` and `qura_crm` (separate owner roles); secrets generated into `~/qura-server/env/`.
- hs-minim1 — client-server (`0b7db11`) and crm-server (`5051242`) built and healthy. First live Alembic run
  (0001→0003) and first `prisma db push` on the new DB.
- hs-minim1 — launchd daemons installed: boot, auto-deploy every 60 s, nightly backup at 02:30. Boot path and
  backup/restore verified.
- hs-minim1 — Read-only deploy keys created for qura-kb, qura-client-server and Qura-crm-server (pending: adding them on GitHub).
- qura-kb — `infra/` added (compose, Dockerfiles, scripts, launchd and systemd units). KB restructured into numbered
  folders; Qura-crm-kb content imported.
- Fixes found during setup: the client-server repo Dockerfile omits `alembic/` (the infra Dockerfile includes it);
  an empty `QURA_CORS_ALLOW_ORIGINS=` crashes settings parsing (it is now left unset).
