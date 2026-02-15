#!/usr/bin/env bash
set -uo pipefail

# Usage:
#   sudo HASH='$1$VnGTay6k$3XIp42c9zDvQy///g/r7w0' ./find_hash.sh
# or edit HASH_DEFAULT below.

HASH_DEFAULT='$1$VnGTay6k$3XIp42c9zDvQy///g/r7w0'
HASH="${HASH:-$HASH_DEFAULT}"

DIRS="${DIRS:-/etc /usr/local /opt /srv /root /var}"

found=0
section() { printf '\n== %s ==\n' "$1"; }

# Print only file paths that contain the hash
out="$(sudo grep -RIlF --binary-files=without-match --exclude-dir=.git "$HASH" $DIRS 2>/dev/null | sort -u || true)"
if [[ -n "$out" ]]; then
  section "files containing hash"
  printf '%s\n' "$out"
  found=1
fi

# Also check common backup locations explicitly
out2="$(sudo grep -RIlF --binary-files=without-match "$HASH" /etc /var/backups 2>/dev/null | sort -u || true)"
if [[ -n "$out2" ]]; then
  section "files containing hash (etc + var/backups)"
  printf '%s\n' "$out2"
  found=1
fi

[[ "$found" -eq 0 ]] && exit 0
