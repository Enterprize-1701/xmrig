#!/usr/bin/env bash
set -uo pipefail

# Usage:
#   sudo ./hunt_setup_user_creation.sh
#
# Optional overrides:
#   DIRS="/etc /usr/local /opt /srv /root" sudo ./hunt_setup_user_creation.sh
#   USERNAME="setup" sudo ./hunt_setup_user_creation.sh

DIRS="${DIRS:-/etc /usr/local /opt /srv /root}"
USERNAME="${USERNAME:-setup}"

found=0
section() { printf '\n== %s ==\n' "$1"; }

emit_if_any() {
  # $1 = title, rest = command...
  local title="$1"; shift
  local out
  out="$("$@" 2>/dev/null || true)"
  if [[ -n "$out" ]]; then
    section "$title"
    printf '%s\n' "$out"
    found=1
  fi
}

# 1) Exact passwd-style entry anywhere (rare, but quick win)
emit_if_any "exact passwd entry: ^${USERNAME}:" \
  grep -RniE "^(${USERNAME}):" $DIRS

# 2) Commands that explicitly create/modify user 'setup'
emit_if_any "user mgmt commands mentioning ${USERNAME}" \
  grep -RniE --exclude='*console-setup*' --exclude='*keyboard-setup*' --exclude-dir='.git' \
  "(\buseradd\b|\badduser\b|\busermod\b|\bdeluser\b|\bchpasswd\b).*\b${USERNAME}\b" \
  $DIRS

# 3) Direct edits/copies to passwd/shadow (bypass useradd)
emit_if_any "direct edits of passwd/shadow" \
  grep -RniE --exclude-dir='.git' \
  '(>>[[:space:]]*/etc/passwd|>>[[:space:]]*/etc/shadow|tee[[:space:]]+(-a[[:space:]]+)?/etc/passwd|tee[[:space:]]+(-a[[:space:]]+)?/etc/shadow|sed[[:space:]].*/etc/passwd|awk[[:space:]].*/etc/passwd|perl[[:space:]].*/etc/passwd|cp[[:space:]].*[[:space:]]/etc/passwd|mv[[:space:]].*[[:space:]]/etc/passwd|cp[[:space:]].*[[:space:]]/etc/shadow|mv[[:space:]].*[[:space:]]/etc/shadow)' \
  $DIRS

# 4) Mentions of setup in privileged/auth-related configs
emit_if_any "mentions of ${USERNAME} in sudo/ssh/pam/systemd/security" \
  grep -RniE --exclude-dir='.git' "\b${USERNAME}\b" \
  /etc/sudoers /etc/sudoers.d /etc/ssh /etc/pam.d /etc/security /etc/systemd 2>/dev/null

# 5) systemd-sysusers (declarative user creation)
emit_if_any "sysusers.d (declarative user creation)" \
  grep -RniE "^\s*u\s+${USERNAME}\b|\b${USERNAME}\b" /etc/sysusers.d /usr/lib/sysusers.d

# 6) Generic user-management commands anywhere (no username filter)
emit_if_any "any user-management commands (useradd/adduser/...)" \
  grep -RniE --exclude-dir='.git' '\b(useradd|adduser|usermod|deluser|chpasswd)\b' \
  $DIRS

# 7) If filestat_exporter exists, show only lines about passwd/shadow/setup
if [[ -d /opt/exporters/filestat_exporter ]]; then
  emit_if_any "filestat_exporter mentions passwd/shadow/${USERNAME}" \
    grep -RniE "\b(passwd|shadow|${USERNAME})\b" /opt/exporters/filestat_exporter
fi

# Exit quietly if nothing found
if [[ "$found" -eq 0 ]]; then
  exit 0
fi
