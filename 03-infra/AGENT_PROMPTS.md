# Prompts for an AI agent (Claude Code) to run infra work

Paste one of these into Claude Code opened in the `qura` workspace. Each one points the
agent at the runbook it must follow, so results stay consistent.

## Set up a new server

> Set up `<user>@<host>` (password `<pw>`) as a Qura backend server. Follow
> `qura-kb/03-infra/runbooks/new-server-setup.md` exactly. Use SSH keys after the first
> login and delete any temporary sudo helper at the end. Give me the deploy keys and the
> Cloudflare login URL when you need them. Document the server in
> `qura-kb/03-infra/servers/<host>.md` and the CHANGELOG.

## Deploy a new backend service

> Add `<owner/repo>` (branch `main`) as a new service `<name>` on `<server>`. It
> `<needs | doesn't need>` a Postgres DB and should be public at `<hostname>`. Follow
> `qura-kb/03-infra/runbooks/add-new-service.md`. Write
> `qura-kb/03-infra/services/<name>.md`, update the inventory + CHANGELOG, and verify it is
> healthy and auto-deploys.

## Health check / incident

> Check the health of `<server>` with `infra/scripts/status.sh` and the logs
> (`qura-kb/03-infra/runbooks/operations.md`). Report what is down and why, and fix anything
> safe. Ask me before restoring data.

## Restore

> Restore `<db>` on `<server>` to the backup from `<date/time>` following
> `qura-kb/03-infra/runbooks/restore-backup.md`.

## Move a service between servers

> Move `<service>` from `<server A>` to `<server B>`: set up B if needed, restore the latest
> dump of its DB there, switch the tunnel hostname, verify, then stop it on A. Record it in
> `05-migrations/`.

Rules for the agent (also in each runbook): never commit secrets; secrets live only in
`~/qura-server/env/*.env` on the server; always take a backup before touching data; record
every infra change in `03-infra/CHANGELOG.md`.
