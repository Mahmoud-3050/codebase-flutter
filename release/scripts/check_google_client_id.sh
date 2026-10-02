#!/usr/bin/env bash
set -euo pipefail

# Standalone CI guard for GOOGLE_SERVER_CLIENT_ID.
# Can be run directly as a step in CI workflows or release scripts.
#
# Usage:
#   bash release/scripts/check_google_client_id.sh [--enforce]
#
# Exit codes:
#   0: Guard passed (or disabled)
#   1: Guard failed (enforced and GOOGLE_SERVER_CLIENT_ID is empty)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ENFORCE_FLAG="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --enforce | -e)
      ENFORCE_FLAG="true"
      ;;
    -h | --help)
      echo "Usage: bash release/scripts/check_google_client_id.sh [--enforce]"
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

ENV_CLIENT_ID="${GOOGLE_SERVER_CLIENT_ID:-}"

# Load deploy.config if present
if [[ -f "${RELEASE_DIR}/deploy.config" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${RELEASE_DIR}/deploy.config"
  set +a
fi

if [[ -n "${ENV_CLIENT_ID}" && -z "${GOOGLE_SERVER_CLIENT_ID:-}" ]]; then
  GOOGLE_SERVER_CLIENT_ID="${ENV_CLIENT_ID}"
fi

if [[ "${ENFORCE_FLAG}" == "true" ]]; then
  ENFORCE_GOOGLE_SERVER_CLIENT_ID="true"
fi

is_guard_enabled() {
  case "${ENFORCE_GOOGLE_SERVER_CLIENT_ID:-false}" in
    true | TRUE | True | yes | YES | 1) return 0 ;;
  esac
  case "${CHECK_GOOGLE_SERVER_CLIENT_ID:-false}" in
    true | TRUE | True | yes | YES | 1) return 0 ;;
  esac
  case "${GUARD_GOOGLE_SERVER_CLIENT_ID:-false}" in
    true | TRUE | True | yes | YES | 1) return 0 ;;
  esac
  return 1
}

if ! is_guard_enabled; then
  echo "CI guard: GOOGLE_SERVER_CLIENT_ID check is disabled (default)."
  exit 0
fi

CLIENT_ID="${GOOGLE_SERVER_CLIENT_ID:-}"
if [[ -z "${CLIENT_ID// /}" ]]; then
  echo "error: CI guard failed: GOOGLE_SERVER_CLIENT_ID is required but empty or not set." >&2
  echo "Please set GOOGLE_SERVER_CLIENT_ID in release/deploy.config or as an environment variable." >&2
  exit 1
fi

echo "CI guard: GOOGLE_SERVER_CLIENT_ID is present (${#CLIENT_ID} characters)."
exit 0
