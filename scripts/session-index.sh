#!/usr/bin/env bash
# Claude Code SessionStart hook: prints the wiki index for the repo the session
# is in, so it lands in the agent's context. Read-only.
#   ~/tiket-workspaces/<REPO>/...  → wiki/repos/<REPO>/<slug>-index.md
#   ~/tiket-workspaces, the vault, or a repo with no wiki → root index.md
#   anywhere else → nothing
set -uo pipefail

VAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS="$HOME/tiket-workspaces"
dir="${CLAUDE_PROJECT_DIR:-$PWD}"

# Print a file without its YAML frontmatter.
body() { awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{f=0;next} !f' "$1"; }

header() {
  echo "# tiket wiki"
  echo "Vault: \"$VAULT\" (quote the path). Schema: CLAUDE.md in the vault; read it before your first write."
  echo "$1"
  echo
}

case "$dir/" in
  "$VAULT"/*)
    header "This is the vault root index."
    body "$VAULT/index.md" ;;
  "$WS"/)
    header "This is the vault root index."
    body "$VAULT/index.md" ;;
  "$WS"/*)
    repo="${dir#"$WS"/}"; repo="${repo%%/*}"
    idx=$(ls "$VAULT/wiki/repos/$repo/"*-index.md 2>/dev/null | head -1)
    if [ -n "$idx" ]; then
      header "Index for $repo, the repo this session is in. Paths and \`find\` below are relative to the vault."
      body "$idx"
    else
      header "There is no wiki for $repo yet. The vault root index follows."
      body "$VAULT/index.md"
    fi ;;
  *) ;;
esac
exit 0
