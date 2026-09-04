#!/usr/bin/env bash
#
# BackupPetti Box — uninstaller for Linux.
#
# Stops the Box, removes its boot service, deletes the installed agent, and
# forgets your settings (drive choice + paired phones). Files already backed up
# on the USB drive are NOT touched.
#
# Run it with:
#   curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/uninstall-linux.sh | sudo bash
#
set -euo pipefail

INSTALL_DIR="/opt/backuppetti"
SERVICE="/etc/systemd/system/backuppetti.service"

# --- needs root to remove the systemd unit and /opt files ---------------------
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run with sudo, e.g.:"
  echo "  curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/uninstall-linux.sh | sudo bash"
  exit 1
fi

echo "Removing BackupPetti Box…"

# --- stop and remove the boot service (ignore if it isn't there) --------------
systemctl disable --now backuppetti.service 2>/dev/null || true
rm -f "$SERVICE"
systemctl daemon-reload

# --- delete the installed agent -----------------------------------------------
rm -rf "$INSTALL_DIR"

# --- forget saved settings for the owner account ------------------------------
RUN_USER="${SUDO_USER:-$(logname 2>/dev/null || true)}"
if [ -n "${RUN_USER:-}" ]; then
  HOME_DIR="$(getent passwd "$RUN_USER" | cut -d: -f6 || true)"
  [ -n "${HOME_DIR:-}" ] && rm -rf "$HOME_DIR/.config/BackupPetti"
fi

echo
echo "✅ BackupPetti Box removed. Your backed-up files on the drive are untouched."
