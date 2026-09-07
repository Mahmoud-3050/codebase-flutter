#!/usr/bin/env bash
set -euo pipefail

# Run release-automation tests. Does not talk to Google Play or App Store.
# Usage: bash release/scripts/test.sh

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RELEASE_DIR="${ROOT}/release"
failed=0

echo "== bash syntax =="
bash -n "${RELEASE_DIR}/scripts/deploy.sh"
bash -n "${RELEASE_DIR}/scripts/lib/common.sh"
bash -n "${RELEASE_DIR}/scripts/hooks/pre_build.example.sh"
bash -n "${RELEASE_DIR}/test/config_test.sh"
echo "  PASS  bash -n"

echo
echo "== config validation =="
if ! bash "${RELEASE_DIR}/test/config_test.sh"; then
  failed=1
fi

echo
echo "== ruby unit tests =="
if ! command -v ruby >/dev/null 2>&1; then
  echo "  SKIP  ruby is not installed (sudo apt install ruby-full)"
else
  if ! ruby -I"${RELEASE_DIR}/test" -e "
    Dir['${RELEASE_DIR}/test/*_test.rb'].sort.each { |file| require file }
  "; then
    failed=1
  fi
fi

if [[ "${failed}" -ne 0 ]]; then
  echo
  echo "release tests failed"
  exit 1
fi

echo
echo "release tests passed"
