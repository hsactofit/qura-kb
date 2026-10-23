#!/bin/bash
# One-shot, idempotent server setup (macOS with Colima, or Debian/Ubuntu Linux).
# Safe to re-run: never overwrites existing secrets, keys, data or state.
#
# Precondition: this qura-kb checkout is on the server at
#   $QURA_ROOT/repos/qura-kb   (default QURA_ROOT=$HOME/qura-server)
# Needs sudo once (service units). Full walkthrough:
#   kb/03-infra/runbooks/new-server-setup.md
set -euo pipefail
QURA_LOG_TAG=bootstrap
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

step() { echo; echo "==> $*"; }
SUDO="sudo"; [ -n "${SUDO_ASKPASS:-}" ] && SUDO="sudo -A"

step "1/7 packages"
if is_macos; then
  command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
  # git: the macOS system git is enough (brew would compile it on older macOS).
  brew install colima docker docker-compose docker-buildx cloudflared >/dev/null
  mkdir -p "$HOME/.docker/cli-plugins"
  ln -sfn "$(brew --prefix)/opt/docker-compose/bin/docker-compose" "$HOME/.docker/cli-plugins/docker-compose"
  ln -sfn "$(brew --prefix)/opt/docker-buildx/bin/docker-buildx" "$HOME/.docker/cli-plugins/docker-buildx"
else
  if ! command -v docker >/dev/null; then
    curl -fsSL https://get.docker.com | $SUDO sh
    $SUDO usermod -aG docker "$USER"
    echo "Added $USER to the docker group: log out/in, then re-run this script."; exit 0
  fi
  command -v cloudflared >/dev/null || {
    arch="$(dpkg --print-architecture)"
    curl -fsSL -o /tmp/cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$arch.deb"
    $SUDO dpkg -i /tmp/cloudflared.deb
  }
fi

step "2/7 directories"
mkdir -p "$QURA_ROOT"/{env,repos,backups/daily,backups/predeploy,logs,state,cloudflared}
chmod 700 "$QURA_ROOT/env" "$QURA_ROOT/backups"

step "3/7 secrets (only created when missing)"
render_env() {
  local name="$1" src="$QURA_INFRA/env/$1.env.example" dst="$QURA_ROOT/env/$1.env"
  [ -f "$dst" ] && { echo "keep  env/$name.env"; return; }
  [ -f "$src" ] || { echo "no template for $name"; return; }
  ( set -a; for f in postgres shared; do source "$QURA_ROOT/env/$f.env" 2>/dev/null || true; done; set +a
    perl -pe 'BEGIN{open R,"<","/dev/urandom"} s/__SECRET__/read(R,$b,24);unpack("H*",$b)/ge; s/__(?:PG|SHARED)_(\w+)__/$ENV{$1}/g' "$src" ) > "$dst"
  chmod 600 "$dst"; echo "new   env/$name.env"
}
render_env postgres
render_env shared
while IFS='|' read -r -u 3 name _; do render_env "$name"; done 3< <(services)

step "4/7 GitHub deploy keys (read-only, one per repo)"
mkdir -p "$HOME/.ssh"; chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/config"
ssh-keygen -F github.com >/dev/null 2>&1 || ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
add_key() {
  local name="$1" repo="$2" key="$HOME/.ssh/qura_deploy_$1"
  [ -f "$key" ] || ssh-keygen -q -t ed25519 -N '' -C "qura-deploy-$name@$(hostname -s)" -f "$key"
  grep -q "^Host github-$name\$" "$HOME/.ssh/config" || cat >> "$HOME/.ssh/config" <<EOF

Host github-$name
    HostName github.com
    User git
    IdentityFile $key
    IdentitiesOnly yes
EOF
  echo "  $repo  ->  $(cat "$key.pub")"
}
add_key qura-kb hsactofit/qura-kb
while IFS='|' read -r -u 3 name repo _; do add_key "$name" "$repo"; done 3< <(services)
echo "  Add each key at https://github.com/<repo>/settings/keys (read-only)."

step "5/7 compose.env"
set_var QURA_ROOT "$QURA_ROOT"
set_var QURA_INFRA "$QURA_INFRA"
[ -n "$(get_var COMPOSE_PROFILES)" ] || set_var COMPOSE_PROFILES ""

step "6/7 container runtime"
ensure_docker && docker info --format 'docker {{.ServerVersion}} on {{.OperatingSystem}}, {{.NCPU}} cpu, {{.MemTotal}} bytes'
compose up -d postgres
ensure_db_setup

step "7/7 service units (boot, deploy every 60s, backup 02:30)"
if is_macos; then
  for unit in boot deploy backup; do
    dst="/Library/LaunchDaemons/com.qura.$unit.plist"
    sed -e "s|__USER__|$USER|g" -e "s|__HOME__|$HOME|g" \
        -e "s|__QURA_ROOT__|$QURA_ROOT|g" -e "s|__QURA_INFRA__|$QURA_INFRA|g" \
        "$QURA_INFRA/launchd/com.qura.$unit.plist" | $SUDO tee "$dst" >/dev/null
    $SUDO chown root:wheel "$dst"; $SUDO chmod 644 "$dst"
    $SUDO launchctl bootout system "$dst" 2>/dev/null || true
    [ "$unit" = boot ] && continue   # boot runs at next startup; stack is already up now
    $SUDO launchctl bootstrap system "$dst"
  done
  $SUDO launchctl enable system/com.qura.boot
  # Server power policy: never sleep, restart after power loss.
  $SUDO pmset -a sleep 0 disksleep 0 autorestart 1 womp 1 powernap 0
else
  for f in "$QURA_INFRA"/systemd/*; do
    sed -e "s|__USER__|$USER|g" -e "s|__HOME__|$HOME|g" \
        -e "s|__QURA_ROOT__|$QURA_ROOT|g" -e "s|__QURA_INFRA__|$QURA_INFRA|g" \
        "$f" | $SUDO tee "/etc/systemd/system/$(basename "$f")" >/dev/null
  done
  $SUDO systemctl daemon-reload
  $SUDO systemctl enable qura-boot.service qura-deploy.timer qura-backup.timer
  $SUDO systemctl start qura-deploy.timer qura-backup.timer
fi

echo
echo "Done. Next: add the deploy keys above on GitHub, then run"
echo "  $QURA_INFRA/scripts/tunnel-setup.sh   (Cloudflare tunnel)"
echo "  $QURA_INFRA/scripts/status.sh"
