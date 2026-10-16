#!/usr/bin/env bash
# Usage: scripts/commit.sh "<subject>" ["<paragraph>" ...]
# Regenerates the index files, then commits everything in the vault.
# Each argument becomes one -m paragraph of the commit message.
set -euo pipefail

VAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ $# -ge 1 ] || { echo "usage: scripts/commit.sh \"<subject>\" [\"<paragraph>\" ...]" >&2; exit 2; }

python3 "$VAULT/scripts/build-index.py"

msg=()
for p in "$@"; do msg+=(-m "$p"); done
git -C "$VAULT" add -A
git -C "$VAULT" commit "${msg[@]}"
