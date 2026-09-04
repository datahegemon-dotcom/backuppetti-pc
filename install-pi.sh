#!/usr/bin/env bash
#
# Old name, kept so links already shared keep working.
# The installer now lives at install-linux.sh — this just runs it.
#
set -euo pipefail
exec curl -fsSL https://datahegemon-dotcom.github.io/backuppetti-pc/install-linux.sh | bash
