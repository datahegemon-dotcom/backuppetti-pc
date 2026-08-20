#!/usr/bin/env bash
#
# BackupPetti Box — uninstaller for macOS.
#
# Stops the Box, removes its login item, and deletes the installed agent, logs,
# and saved settings (drive choice + paired phones). Files you've already backed
# up are NOT touched. No sudo needed — everything lives in your own account.
#
# Run it with:
#   curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/uninstall-mac.sh | bash
#
set -euo pipefail

LABEL="com.backuppetti.box"
DIR="$HOME/Library/Application Support/BackupPetti"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

echo "Removing BackupPetti Box…"

# --- stop the login item (ignore if not loaded) and remove it -----------------
launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST"

# --- delete the installed agent, logs, and saved settings ---------------------
rm -rf "$DIR"

echo
echo "✅ BackupPetti Box removed. Your backed-up files are untouched."
