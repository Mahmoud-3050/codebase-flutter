#!/usr/bin/env bash
set -euo pipefail

# Build and upload using keys in release/deploy.config.
# Usage:
#   bash release/scripts/deploy.sh [google|ios|both] [--skip-build] [--skip-deploy]
# Examples:
#   bash release/scripts/deploy.sh
#   bash release/scripts/deploy.sh google
#   bash release/scripts/deploy.sh ios --skip-build
#   bash release/scripts/deploy.sh --skip-deploy   # build AAB/IPA, no store upload

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
deploy "$@"
