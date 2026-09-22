#!/bin/bash
# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

echo "=== 1. STRENGTHENING PRIVACY: STOPPING LOG SERVICES ==="
systemctl stop syslog.socket rsyslog 2>/dev/null
systemctl stop systemd-journald.service 2>/dev/null

echo "=== 2. PURGING SYSTEM LOGS & JOURNALS ==="
# Vacuum systemd journals to zero time and wipe directory
if command -v journalctl &> /dev/null; then
    journalctl --vacuum-time=1s
    rm -rf /var/log/journal/*
fi
# Empty all traditional text log files without deleting the file descriptors
find /var/log -type f -exec cp /dev/null {} \;

echo "=== 3. CLEANING REPOSITORIES & TEMPORARY FILES ==="
# Purge apt/dnf histories and caches
if command -v apt-get &> /dev/null; then
    apt-get clean
    rm -rf /var/lib/apt/lists/*
elif command -v dnf &> /dev/null; then
    dnf clean all
    rm -rf /var/cache/dnf/*
fi
# Clear shared temporary folders
rm -rf /tmp/* /var/tmp/*

echo "=== 4. RESETTING MACHINE IDENTIFIERS ==="
# Clear unique machine IDs so the cloned VM behaves like a new machine
cat /dev/null > /etc/machine-id
if [ -f /var/lib/dbus/machine-id ]; then
    cat /dev/null > /var/lib/dbus/machine-id
fi
# Drop SSH host keys so QEMU regenerates fresh ones next boot
rm -f /etc/ssh/ssh_host_*

echo "=== 5. CLEARING ALL USER HISTORIES & TERMINAL CACHES ==="
# Wipe shells, text editors, and caches for root and all human users
for user_dir in /home/* /root; do
    if [ -d "$user_dir" ]; then
        rm -f "$user_dir/.bash_history" "$user_dir/.zsh_history" "$user_dir/.lesshst" "$user_dir/.viminfo"
        rm -rf "$user_dir/.cache/*"
        rm -rf "$user_dir/.ssh/authorized_keys" 2>/dev/null
    fi
done

echo "=== 6. DISCARDING DELETED BLOCKS WITHOUT DISK EXPANSION ==="
# fstrim tells the hypervisor which log blocks were deleted so they are dropped safely
if command -v fstrim &> /dev/null; then
    fstrim -v /
else
    echo "fstrim not available, skipping safely."
fi

echo "=== 7. FINAL TERMINAL RESET & SHUTDOWN ==="
# Completely resets the current terminal screen buffer
clear
printf "\033c"

# Clear active shell memory, save empty history, and kill power immediately
# This ensures the running execution of *this* script is never logged.
history -c && history -w && shutdown -h now
