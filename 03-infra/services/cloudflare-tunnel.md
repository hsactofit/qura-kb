# Service — Cloudflare Tunnel

| | |
|---|---|
| Tunnel | `qura-<hostname>` (for hs-minim1: `qura-hs-minim1`), locally managed |
| Runs as | compose service `cloudflared` (profile `tunnel`), `mem_limit 128m` |
| Config | `~/qura-server/cloudflared/config.yml`, rendered from `infra/servers/<host>/tunnel.conf` |
| Credentials | `~/qura-server/cloudflared/credentials.json` (tunnel secret) + `~/.cloudflared/cert.pem` (account cert used to create tunnels and DNS records) |
| Login | One-time `cloudflared tunnel login` by a human with access to the Cloudflare zone |

## Hostname map (hs-minim1)

| Hostname | → | Service |
|---|---|---|
| `quraapi.leadrizz.com` | | `client-server:8787` |
| `quracrmapi.leadrizz.com` | | `crm-server:4000` |

Anything not listed returns 404 at the tunnel.

## Change hostnames

Edit `infra/servers/<host>/tunnel.conf`, push, then run `infra/scripts/tunnel-setup.sh` on the
server. It creates or updates the CNAMEs (`--overwrite-dns`) and restarts cloudflared.

## Hardening to consider

- Cloudflare WAF and rate-limit rules on `*/auth/*` paths.
- Cloudflare Access (SSO) in front of any admin-only hostname. Not for the public APIs.
