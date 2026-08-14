#!/usr/bin/env bash
#
# BackupPetti Box — one-command installer for Raspberry Pi / Linux.
#
# It downloads the right agent for your machine, installs it to /opt/backuppetti,
# and registers a systemd service so the Box starts automatically on every boot
# (survives power cuts — no need to log in or start anything by hand).
#
# Run it with:
#   curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/install-pi.sh | sudo bash
#
set -euo pipefail

REPO="datahegemon-dotcom/backuppetti-pc"
INSTALL_DIR="/opt/backuppetti"
BIN="$INSTALL_DIR/backuppetti-agent"
SERVICE="/etc/systemd/system/backuppetti.service"

# --- pick the build for this machine ------------------------------------------
arch="$(uname -m)"
case "$arch" in
  aarch64|arm64) asset="backuppetti-agent-linux-arm64" ;;   # Raspberry Pi (64-bit OS)
  x86_64|amd64)  asset="backuppetti-agent-linux-amd64" ;;   # Linux PC (Intel/AMD)
  *) echo "❌ Unsupported CPU architecture: $arch"; exit 1 ;;
esac
BIN_URL="https://github.com/$REPO/releases/latest/download/$asset"

# --- needs root to write /opt and the systemd unit ----------------------------
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run with sudo, e.g.:"
  echo "  curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/install-pi.sh | sudo bash"
  exit 1
fi

# --- which account should own the Box (its config + the mounted USB drive) ----
RUN_USER="${SUDO_USER:-$(logname 2>/dev/null || true)}"
if [ -z "${RUN_USER:-}" ] || ! id "$RUN_USER" >/dev/null 2>&1; then
  echo "❌ Could not work out your username (got '${RUN_USER:-}'). Re-run with: sudo bash install-pi.sh"
  exit 1
fi

echo "Installing BackupPetti Box for user '$RUN_USER'  (arch: $arch)…"
mkdir -p "$INSTALL_DIR"

# --- download the agent -------------------------------------------------------
if command -v curl >/dev/null 2>&1; then
  curl -fSL "$BIN_URL" -o "$BIN"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$BIN" "$BIN_URL"
else
  echo "❌ Need 'curl' or 'wget' installed to download."; exit 1
fi
chmod +x "$BIN"
chown -R "$RUN_USER":"$RUN_USER" "$INSTALL_DIR"

# --- register the boot service ------------------------------------------------
cat > "$SERVICE" <<UNIT
[Unit]
Description=BackupPetti Box — backup agent for the BackupPetti phone app
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$RUN_USER
ExecStart=$BIN
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now backuppetti.service

# --- done ---------------------------------------------------------------------
ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
echo
echo "✅ Done — BackupPetti Box is running and will start on every boot."
echo "   Dashboard (on the Pi):  http://localhost:8088"
[ -n "$ip" ] && echo "   From your phone:        http://$ip:8088"
echo
echo "   Check it:   sudo systemctl status backuppetti"
echo "   See logs:   journalctl -u backuppetti -e"
echo "   Turn off:   sudo systemctl disable --now backuppetti"
