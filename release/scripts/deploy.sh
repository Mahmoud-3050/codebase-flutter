#!/usr/bin/env bash
set -euo pipefail

# Build and upload using keys in release/deploy.config.
# Set GOOGLE_PLAY_TRACK to internal or production.
# Usage: bash release/scripts/deploy.sh

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
deploy
