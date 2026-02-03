#!/bin/bash
set -euo pipefail

log(){ echo "[+] $*"; }

[[ $EUID -eq 0 ]] || { echo "Run this script as root"; exit 1; }

# 1. Stop running miners and background screen sessions
log "Stopping yam/yamd processes and background screen sessions"
pkill -9 -f 'yamd' 2>/dev/null || true
pkill -9 -f '/usr/bin/yam' 2>/dev/null || true

if command -v screen >/dev/null 2>&1; then
    screen -ls 2>/dev/null |
        awk '/Detached/ {print $1}' |
        while read -r entry; do
            if screen -S "$entry" -Q info 2>/dev/null | grep -q 'yamd'; then
                screen -S "$entry" -X quit
            fi
        done
fi

# 2. Remove the watchdog cron job
cleanup_file="/etc/cron.hourly/cleanup"
if [[ -f $cleanup_file && $(grep -q 'yamd' "$cleanup_file"; echo $?) -eq 0 ]]; then
    log "Removing $cleanup_file"
    rm -f "$cleanup_file"
fi

# helper to drop immutable flag before deleting files
unprotect(){
    for f in "$@"; do
        [[ -e $f ]] && chattr -i "$f" 2>/dev/null || true
    done
}

# 3. Delete binaries, archive, and config
log "Removing /usr/bin/yam*, /usr/bin/c, and /etc/yam"
unprotect /usr/bin/yam /usr/bin/yamd /usr/bin/c /etc/yam
rm -f /usr/bin/yam /usr/bin/yamd /usr/bin/c /etc/yam

# 4. Remove backdoor user “setup”
sysfiles=(/etc/passwd /etc/shadow /etc/group /etc/gshadow)
unprotect "${sysfiles[@]}"

if id setup >/dev/null 2>&1; then
    log "Deleting root user 'setup'"
    if userdel -rf setup 2>/dev/null; then
        log "User 'setup' removed via userdel"
    else
        log "userdel failed, removing 'setup' entries manually"
        sed -i '/^setup:/d' /etc/passwd
        sed -i '/^setup:/d' /etc/shadow
        sed -i '/^setup:/d' /etc/group
        sed -i '/^setup:/d' /etc/gshadow
        rm -rf /var/setup 2>/dev/null || true
        groupdel setup 2>/dev/null || true
    fi
fi

# 5. Clean malicious blocks from bash rc files
clean_shell_rc() {
    local target="$1"
    [[ -f $target ]] || return 0

    local tmp
    tmp=$(mktemp) || return 0

    # run perl safely; if it fails – just return
    perl -0pe '
        s/\nif \[\[\s*\$\(id -u\)[^\n]*\n\s*for i in \$\(find \/var\/log[^;]*; do cat \/dev\/null > \$i; done\n\s*fi\n/\n/s;
        s/\nif \[\[\s*\$\(w -h[^\]]*]]\s*;\s*then.*?fi\n/\n/s;
        s/\n?for i in \$\(find \/var\/log[^\n]*cat \/dev\/null > \$i; done\n?//s;
        s/\nif \[\[\s*\$\(id -u\)[^\n]*\n\s*fi\n/\n/s;
        s/fiif/fi\nif/g;
    ' "$target" > "$tmp" || { rm -f "$tmp"; return 0; }

    # cmp in if is safe under set -e
    if ! cmp -s "$target" "$tmp"; then
        local backup="${target}.bak.$(date +%s)"
        cp "$target" "$backup" || true
        log "Cleaned injected blocks in $target (backup $backup)"
        mv "$tmp" "$target"
    else
        rm -f "$tmp"
    fi
}

clean_shell_rc /etc/bash.bashrc
clean_shell_rc /etc/bashrc

# 6. Remove malicious preload library
preload="/etc/ld.so.preload"
badlib="/usr/lib/libmetadata.so"

if [[ -f $badlib || -s $preload ]]; then
    log "Cleaning custom preload library and ld.so.preload"
    unprotect "$badlib" "$preload"
    [[ -f $badlib ]] && rm -f "$badlib"
    if [[ -s $preload ]]; then
        cp "$preload" "${preload}.bak.$(date +%s)"
        : > "$preload"
    fi
    ldconfig
fi

# 7. Quick sanity check
log "Ensuring no miner processes or connections remain"
ps -eo pid,cmd,%cpu --sort=-%cpu | head
ss -tp | grep 141.11.93.64 || true

log "Done. Change passwords/keys, review IPMI access, and patch the system."
