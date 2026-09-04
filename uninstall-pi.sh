#!/usr/bin/env bash
#
# Old name, kept so links already shared keep working.
# The uninstaller now lives at uninstall-linux.sh — this just runs it.
#
set -euo pipefail
exec curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/uninstall-linux.sh | bash
