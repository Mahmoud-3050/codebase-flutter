#!/usr/bin/env bash
set -euo pipefail

# Example pre-build hook. Copy and point PRE_BUILD_SCRIPT (or
# ANDROID_PRE_BUILD_SCRIPT / IOS_PRE_BUILD_SCRIPT) at your real script.
#
# Usage: bash pre_build.example.sh internal|production android|ios
# Working directory: Flutter project root.
# Extra env: DEPLOY_TRACK, DEPLOY_PLATFORM, plus every key from deploy.config.

track="${1:-}"
platform="${2:-}"

echo "pre-build: track=${track} platform=${platform}"
# Example: swap Firebase plist, generate code, download a config file, …
# exit 1 to abort the AAB/IPA build.
