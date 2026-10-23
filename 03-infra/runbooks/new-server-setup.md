# Runbook — Set up a new server (Mac or Linux)

Turns a fresh macOS (Apple Silicon) or Debian/Ubuntu machine into a Qura backend
host: Docker, Postgres, all services from `infra/services.conf`, Cloudflare
Tunnel, boot autostart, auto-deploy, nightly backups. Takes ~20 minutes, plus
download time. `hs-minim1` was built exactly this way (see `servers/hs-minim1.md`).

## What the operator (human) must do

1. Give SSH access: `user@host` + password **once** (it's replaced by a key).
2. Add the read-only **deploy keys** printed by bootstrap on GitHub.
3. Open the **Cloudflare login URL** printed by `tunnel-setup.sh`, choose the zone.

Everything else is scripted.

## Steps

### 0. SSH key access (from your laptop)

```bash
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519_<host>
ssh-copy-id -i ~/.ssh/id_ed25519_<host>.pub user@<host>   # password asked once
# ~/.ssh/config:  Host <alias> / HostName <host> / User <user> / IdentityFile ~/.ssh/id_ed25519_<host> / IdentitiesOnly yes
```

### 1. Base tooling

- **macOS**: install Homebrew (`NONINTERACTIVE=1`; it also installs the Xcode CLT).
  For non-interactive sudo over SSH, use a temporary `SUDO_ASKPASS` script
  (chmod 700) and **delete it at the end**.
- **Linux**: nothing; bootstrap installs Docker via get.docker.com.

### 2. Put this repo on the server

Until the server's `qura-kb` deploy key exists, push the files from the laptop:

```bash
ssh <alias> 'mkdir -p ~/qura-server/repos/qura-kb'
rsync -a --delete --exclude .git ~/…/qura-kb/ <alias>:qura-server/repos/qura-kb/
```

### 3. Bootstrap

```bash
ssh <alias> 'SUDO_ASKPASS=~/.askpass bash ~/qura-server/repos/qura-kb/infra/scripts/bootstrap.sh'
```

Idempotent. Installs the runtime, creates `~/qura-server/{env,repos,backups,logs,state,cloudflared}`,
generates every secret (`env/*.env`, chmod 600), creates one deploy key per repo, starts
Docker + Postgres, and installs the boot/deploy/backup units. It also sets the macOS
power policy (no sleep, restart after power loss).

### 4. Deploy keys → GitHub

For each line it printed: `https://github.com/<repo>/settings/keys` → *Add deploy key* →
read-only. Then switch the KB copy to git so infra self-updates:

```bash
cd ~/qura-server/repos/qura-kb && git init -q && git remote add origin git@github-qura-kb:hsactofit/qura-kb.git \
  && git fetch -q origin main && git reset -q --hard origin/main && git branch -q -u origin/main 2>/dev/null; git checkout -q -B main origin/main
```

### 5. Fill real secrets

Edit `~/qura-server/env/<service>.env` (R2, OpenAI, Smartflo, CORS origins…).
`*.env.example` in `infra/env/` lists every key.

### 6. First deploy

```bash
~/qura-server/repos/qura-kb/infra/scripts/deploy.sh          # clones + builds + starts everything
~/qura-server/repos/qura-kb/infra/scripts/status.sh
```

### 7. Tunnel

1. Create `infra/servers/<hostname -s>/tunnel.conf` (copy `hs-minim1`'s) with real hostnames.
2. Run `infra/scripts/tunnel-setup.sh`: open the URL it prints, log in, and pick the domain.
3. It creates tunnel `qura-<host>`, the DNS records and the config, then starts cloudflared.

### 8. Verify

- `curl https://<client-api-host>/api/client/health` and `https://<crm-api-host>/health`
- `sudo reboot`, wait 3 min, and run `status.sh`. Everything must be up **without logging in**.
- Push a trivial commit to a service's `main`: `logs/deploy.log` shows `OK … is live` within ~5 min.
- `infra/scripts/backup.sh daily` → files in `backups/daily/`.

### 9. Clean up and document

- `rm ~/.askpass` (or whatever the temporary sudo helper was called).
- Add `03-infra/servers/<host>.md` and a CHANGELOG line.
