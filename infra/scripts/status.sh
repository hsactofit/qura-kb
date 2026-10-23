#!/bin/bash
# One-screen health summary of the server.
set -uo pipefail
# shellcheck source=lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

echo "== host: $(hostname -s)  $(uname -sm)  uptime:$(uptime | sed 's/.*up \([^,]*\),.*/ \1/')"
is_macos && colima list 2>/dev/null | tail -n +1
echo; echo "== containers"
docker ps -a --filter label=com.docker.compose.project=qura \
  --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
echo; echo "== memory"
docker stats --no-stream --format 'table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}'
echo; echo "== deployed commits"
while IFS='|' read -r -u 3 name repo branch _; do
  printf '%-16s %-38s live=%s failed=%s\n' "$name" "$repo@$branch" \
    "$(cut -c1-12 "$QURA_STATE_DIR/$name.sha" 2>/dev/null || echo -)" \
    "$(cut -c1-12 "$QURA_STATE_DIR/$name.failed" 2>/dev/null || echo -)"
done 3< <(services)
echo; echo "== latest backups"
ls -1t "$QURA_ROOT/backups/daily" 2>/dev/null | head -4
echo; echo "== last deploy log lines"
tail -5 "$QURA_LOG_DIR/deploy.log" 2>/dev/null
