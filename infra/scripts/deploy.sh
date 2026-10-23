#!/bin/bash
# Continuous deployer. Run every 60 s by launchd/systemd.
#
#   deploy.sh                 deploy every service whose branch has a new commit
#   deploy.sh <service>       only that service
#   deploy.sh <service> --force   rebuild + redeploy even if the commit is unchanged
#
# Per new commit: build image tagged with the commit -> dump the service DB ->
# swap the container -> wait for healthy -> keep, or roll back to the previous
# image and remember the bad commit so it isn't retried every minute.
# Also self-updates infra from qura-kb and restarts unhealthy containers.
#
# Everything is inside main() so a self-update of this file mid-run is safe.

main() {
  set -uo pipefail
  QURA_LOG_TAG=deploy
  # shellcheck source=lib.sh
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

  local only="" force=0 arg
  for arg in "$@"; do
    if [ "$arg" = "--force" ]; then force=1; else only="$arg"; fi
  done

  local lock="$QURA_STATE_DIR/deploy.lock"
  mkdir -p "$QURA_STATE_DIR"
  if ! mkdir "$lock" 2>/dev/null; then
    # A lock older than 30 min is from a crashed run.
    if [ -n "$(find "$lock" -maxdepth 0 -mmin +30 2>/dev/null)" ]; then
      rm -rf "$lock"; mkdir "$lock"
    else
      return 0
    fi
  fi
  trap 'rm -rf "$lock"' EXIT

  ensure_docker || { log "ERROR docker unavailable"; return 1; }

  [ -z "$only" ] && update_infra

  local name repo branch db
  while IFS='|' read -r -u 3 name repo branch db; do
    [ -n "$only" ] && [ "$only" != "$name" ] && continue
    deploy_service "$name" "$repo" "$branch" "$db" "$force"
  done 3< <(services)

  [ -z "$only" ] && watchdog
  return 0
}

update_infra() {
  local kb="$QURA_ROOT/repos/qura-kb"
  [ -d "$kb/.git" ] || return 0
  git -C "$kb" fetch -q origin main 2>>"$QURA_LOG_DIR/deploy.log" || { log "WARN cannot fetch qura-kb"; return 0; }
  local head remote
  head="$(git -C "$kb" rev-parse HEAD)"; remote="$(git -C "$kb" rev-parse origin/main)"
  [ "$head" = "$remote" ] && return 0
  local changed
  changed="$(git -C "$kb" diff --name-only "$head" "$remote" -- infra/)"
  git -C "$kb" reset -q --hard "$remote"
  if [ -n "$changed" ]; then
    log "infra updated to ${remote:0:12}: $(echo "$changed" | tr '\n' ' ')"
    apply_stack >> "$QURA_LOG_DIR/deploy.log" 2>&1 || log "WARN apply_stack failed after infra update"
    echo "$changed" | grep -q '^infra/launchd/\|^infra/systemd/' \
      && log "NOTICE service unit templates changed; re-run scripts/bootstrap.sh to reinstall them"
  fi
}

deploy_service() {
  local name="$1" repo="$2" branch="$3" db="$4" force="$5"
  local dir="$QURA_ROOT/repos/$name"
  local url="git@github-$name:$repo.git"

  if [ ! -d "$dir/.git" ]; then
    # A non-git folder here is a hand-copied source tree (first-time setup); replace it.
    rm -rf "$dir"
    log "$name: cloning $repo"
    git clone -q -b "$branch" "$url" "$dir" 2>>"$QURA_LOG_DIR/deploy.log" \
      || { log "$name: ERROR clone failed (deploy key added on GitHub?)"; return; }
  fi
  git -C "$dir" fetch -q origin "$branch" 2>>"$QURA_LOG_DIR/deploy.log" \
    || { log "$name: WARN fetch failed"; return; }

  local remote current failed
  remote="$(git -C "$dir" rev-parse "origin/$branch")"
  current="$(cat "$QURA_STATE_DIR/$name.sha" 2>/dev/null || true)"
  failed="$(cat "$QURA_STATE_DIR/$name.failed" 2>/dev/null || true)"
  if [ "$force" != 1 ]; then
    [ "$remote" = "$current" ] && return
    [ "$remote" = "$failed" ] && return
  fi

  local tag="${remote:0:12}" tv prev
  tv="$(tag_var "$name")"
  prev="$(get_var "$tv")"
  log "$name: deploying $tag ($(git -C "$dir" log -1 --format='%an: %s' "$remote"))"

  git -C "$dir" checkout -qf --detach "$remote" && git -C "$dir" clean -qfdx

  if ! ( export "$tv=$tag"; compose build "$name" ) >> "$QURA_LOG_DIR/deploy.log" 2>&1; then
    log "$name: FAILED build $tag (kept ${prev:-nothing}); see logs/deploy.log"
    echo "$remote" > "$QURA_STATE_DIR/$name.failed"
    return
  fi

  if [ "$db" != "-" ] && [ -n "$prev" ]; then
    "$QURA_INFRA/scripts/backup.sh" predeploy "$db" >> "$QURA_LOG_DIR/deploy.log" 2>&1 \
      || { log "$name: ABORT pre-deploy backup of $db failed"; return; }
  fi

  set_var "$tv" "$tag"
  compose up -d --no-build --no-deps "$name" >> "$QURA_LOG_DIR/deploy.log" 2>&1

  if wait_healthy "$name" 240; then
    echo "$remote" > "$QURA_STATE_DIR/$name.sha"
    rm -f "$QURA_STATE_DIR/$name.failed"
    log "$name: OK $tag is live"
    prune_images "$name" "$tag" "$prev"
  else
    log "$name: FAILED health for $tag; last logs:"
    compose logs --tail 40 "$name" >> "$QURA_LOG_DIR/deploy.log" 2>&1
    echo "$remote" > "$QURA_STATE_DIR/$name.failed"
    if [ -n "$prev" ]; then
      set_var "$tv" "$prev"
      compose up -d --no-build --no-deps "$name" >> "$QURA_LOG_DIR/deploy.log" 2>&1
      log "$name: ROLLED BACK to $prev"
    fi
  fi
}

wait_healthy() {
  local name="$1" timeout="$2" waited=0 cid status
  while [ "$waited" -lt "$timeout" ]; do
    cid="$(compose ps -q "$name" 2>/dev/null)"
    status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$cid" 2>/dev/null)"
    [ "$status" = "healthy" ] && return 0
    sleep 5; waited=$((waited + 5))
  done
  return 1
}

prune_images() {
  local name="$1" keep1="$2" keep2="$3" t
  for t in $(docker images "qura/$name" --format '{{.Tag}}'); do
    [ "$t" = "$keep1" ] || [ "$t" = "$keep2" ] || docker rmi -f "qura/$name:$t" >/dev/null 2>&1
  done
  docker image prune -f >/dev/null 2>&1
  docker builder prune -f --filter until=168h >/dev/null 2>&1
}

watchdog() {
  local cid
  for cid in $(docker ps -q --filter label=com.docker.compose.project=qura --filter health=unhealthy); do
    log "watchdog: restarting unhealthy $(docker inspect -f '{{.Name}}' "$cid")"
    docker restart "$cid" >/dev/null
  done
  # Recreates anything that should be running but isn't (no-op when all is up).
  apply_stack >/dev/null 2>&1 || log "WARN watchdog apply_stack failed"
}

main "$@"
exit $?
