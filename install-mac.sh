#!/usr/bin/env bash
#
# BackupPetti Box — one-command installer for macOS.
#
# Downloads the right build for your Mac, removes Apple's "downloaded from the
# internet" quarantine flag (so Gatekeeper lets it run), and registers a launchd
# LaunchAgent so the Box starts automatically every time you log in — and restarts
# itself if it ever crashes. No sudo needed: everything lives in your own account.
#
# Run it with:
#   curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/install-mac.sh | bash
#
set -euo pipefail

REPO="datahegemon-dotcom/backuppetti-pc"
LABEL="com.backuppetti.box"
DIR="$HOME/Library/Application Support/BackupPetti"
BIN="$DIR/backuppetti-agent"
AGENTS="$HOME/Library/LaunchAgents"
PLIST="$AGENTS/$LABEL.plist"

# --- pick the build for this Mac ----------------------------------------------
arch="$(uname -m)"
case "$arch" in
  arm64)  asset="backuppetti-agent-macos-arm64" ;;   # Apple Silicon (M1–M4)
  x86_64) asset="backuppetti-agent-macos-amd64" ;;   # Intel Mac
  *) echo "❌ Unsupported Mac architecture: $arch"; exit 1 ;;
esac
URL="https://github.com/$REPO/releases/latest/download/$asset"

echo "Installing BackupPetti Box for this Mac ($arch)…"
mkdir -p "$DIR" "$AGENTS"

# --- download the agent -------------------------------------------------------
curl -fSL "$URL" -o "$BIN"
chmod +x "$BIN"
# Let Gatekeeper run it (it's unsigned): drop the quarantine flag.
xattr -d com.apple.quarantine "$BIN" 2>/dev/null || true

# --- register the login service (launchd LaunchAgent) -------------------------
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$DIR/box.log</string>
    <key>StandardErrorPath</key>
    <string>$DIR/box.log</string>
</dict>
</plist>
PLIST

# (re)load so it starts now and on every login.
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"

echo
echo "✅ Done — BackupPetti Box is running and will start every time you log in."
echo "   Dashboard:  http://localhost:8088"
echo "   Logs:       $DIR/box.log"
echo "   Turn off:   launchctl unload \"$PLIST\" && rm \"$PLIST\""
