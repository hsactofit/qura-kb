# Server — hs-minim1 (Mac mini M1)

| | |
|---|---|
| Role | Production backend host: client API, CRM API, Postgres, Cloudflare Tunnel |
| Hardware | Mac mini M1, 8 CPU, 8 GB RAM, 228 GB SSD |
| OS | macOS 13.7.8 (Ventura), arm64 |
| Hostname | `hs-minim1` (LAN name `minim1`) |
| Access | `ssh minim1` (user `himanshushukla`, key-based; key `~/.ssh/id_ed25519_minim1` on Himanshu's laptop). Tailscale is installed for off-LAN access |
| Set up | 2026-10-23 by Claude Code, following `../runbooks/new-server-setup.md` |

## Layout on disk

```
~/qura-server/
├── compose.env            # QURA_ROOT, QURA_INFRA, COMPOSE_PROFILES, TAG_<SERVICE> (live image per service)
├── env/                   # secrets, chmod 600: postgres.env, client-server.env, crm-server.env
├── repos/
│   ├── qura-kb/           # this repo; infra/ is what runs
│   ├── client-server/     # deploy checkouts (managed by deploy.sh; don't edit)
│   └── crm-server/
├── backups/{daily,predeploy}/
├── cloudflared/           # config.yml + credentials.json (tunnel)
├── logs/                  # deploy.log, boot.log, backup.log, colima.log, …
└── state/                 # <svc>.sha (live commit), <svc>.failed, deploy.lock
~/.ssh/qura_deploy_*       # read-only GitHub deploy keys (one per repo), aliases github-<svc>
~/.cloudflared/cert.pem    # Cloudflare account cert (from `tunnel login`)
```

## Runtime

| Component | Setting |
|---|---|
| Homebrew | `/opt/homebrew`; colima 0.10.3, docker CLI + compose 5.6.1 + buildx, cloudflared 2026.10.3 |
| Colima VM | VZ + virtiofs, 4 CPU / 3 GB RAM / 60 GB disk (memory is a cap; idle use is far lower) |
| Containers (idle) | client-server ~66 MB, crm-server ~58 MB, postgres ~44 MB |
| launchd (`/Library/LaunchDaemons`, run as `himanshushukla`, no login needed) | `com.qura.boot` (at boot), `com.qura.deploy` (every 60 s), `com.qura.backup` (02:30 daily) |
| Power (`pmset`) | sleep 0, disksleep 0, autorestart 1 (boots after power loss), womp 1 |

## Verified (2026-10-23)

- Both APIs build from `main` and run healthy against Postgres 16. Client API ran Alembic
  0001→0003 on a live DB; CRM ran `prisma db push` (18 tables).
- Boot path: VM fully stopped → `com.qura.boot` fired through launchd in the system context →
  all 3 containers healthy in 72 s, with no user session.
- Backup → restore round trip on `qura_crm` (18 tables before and after, service healthy again).
- **Not yet done**: a physical reboot test. It was skipped because a GUI Chrome session was open.

## Pending (needs a human)

- [ ] Add the 3 read-only deploy keys on GitHub (qura-kb, qura-client-server, Qura-crm-server)
- [ ] Cloudflare: `tunnel login` and confirm the domain, then `tunnel-setup.sh`
- [ ] Real secrets in `env/crm-server.env` (R2, OpenAI, Smartflo) and `env/client-server.env` (OpenAI)
- [ ] Off-site backup target (`BACKUP_RCLONE_REMOTE`)
- [ ] A physical reboot test

## Tips

- Close Chrome on the mini when nobody is using it. It is the largest memory user outside the VM.
- macOS updates can reboot the machine. The stack comes back on its own, but schedule updates anyway.
