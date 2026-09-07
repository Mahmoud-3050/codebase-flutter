#!/usr/bin/env bash
# Config-validation tests for release/scripts/lib/common.sh
set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_ROOT="$(cd "${TEST_DIR}/.." && pwd)"
COMMON="${RELEASE_ROOT}/scripts/lib/common.sh"

failures=0
passes=0

pass() {
  echo "  PASS  $1"
  passes=$((passes + 1))
}

fail() {
  echo "  FAIL  $1"
  failures=$((failures + 1))
}

expect_error() {
  local name="$1"
  local needle="$2"
  shift 2
  local output
  if output="$("$@" 2>&1)"; then
    fail "${name} (expected failure, command succeeded)"
    return
  fi
  if grep -Fq "${needle}" <<<"${output}"; then
    pass "${name}"
  else
    fail "${name} (expected '${needle}' in: ${output})"
  fi
}

expect_ok() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "${name}"
  else
    fail "${name}"
  fi
}

set_config_key() {
  local file="$1"
  local key="$2"
  local value="$3"
  python3 -c "
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
key, value = sys.argv[2], sys.argv[3]
text = re.sub(
    r'^{}=.*$'.format(re.escape(key)),
    '{}=\"{}\"'.format(key, value),
    path.read_text(),
    count=1,
    flags=re.M,
)
path.write_text(text)
" "${file}" "${key}" "${value}"
}

make_fixture() {
  local dir="$1"
  rm -rf "${dir}/../build"
  mkdir -p "${dir}/secrets" "${dir}/../android"
  cat >"${dir}/deploy.config" <<'EOF'
USES_FLAVORS="true"
FLAVOR="live"
ENTRYPOINT="lib/main_live.dart"
IOS_SCHEME="live"
IOS_CONFIGURATION="Release-live"
GOOGLE_PLAY_TRACK="internal"
GOOGLE_PLAY_PACKAGE_NAME="com.base.app"
GOOGLE_PLAY_JSON_KEY="secrets/play.json"
GOOGLE_PLAY_RELEASE_STATUS="draft"
ANDROID_KEYSTORE_PATH="secrets/upload.jks"
ANDROID_KEYSTORE_PASSWORD="secret"
ANDROID_KEY_ALIAS="upload"
ANDROID_KEY_PASSWORD="secret"
IOS_BUNDLE_IDENTIFIER="com.base.app"
IOS_TEAM_ID="ABCDE12345"
ASC_KEY_ID="KEYID"
ASC_ISSUER_ID="00000000-0000-0000-0000-000000000000"
ASC_KEY_PATH="secrets/AuthKey.p8"
TESTFLIGHT_GROUPS=""
RUN_ANALYZE="false"
RUN_TESTS="false"
SKIP_ANDROID="false"
SKIP_IOS="false"
DEPLOY_TARGET="both"
SKIP_BUILD_IF_EXISTS="false"
PRE_BUILD_SCRIPT=""
ANDROID_PRE_BUILD_SCRIPT=""
IOS_PRE_BUILD_SCRIPT=""
DRY_RUN="false"
EOF
  printf '{}' >"${dir}/secrets/play.json"
  printf 'jks' >"${dir}/secrets/upload.jks"
  printf 'p8' >"${dir}/secrets/AuthKey.p8"
}

run_in_fixture() {
  local dir="$1"
  shift
  env \
    RELEASE_DIR="${dir}" \
    ROOT_DIR="$(dirname "${dir}")" \
    bash -c "
      set -euo pipefail
      source '${COMMON}'
      load_deploy_config
      skip_ios_build_if_not_macos
      $*
    "
}

workdir="$(mktemp -d "${TMPDIR:-/tmp}/release-config-XXXXXX")"
fixture="${workdir}/release"
mkdir -p "${fixture}"
trap 'rm -rf "${workdir}"' EXIT

echo "config validation"
make_fixture "${fixture}"
expect_ok "valid fixture passes validate_config" \
  run_in_fixture "${fixture}" validate_config

set_config_key "${fixture}/deploy.config" GOOGLE_PLAY_TRACK beta
expect_error "rejects invalid GOOGLE_PLAY_TRACK" "must be internal or production" \
  run_in_fixture "${fixture}" validate_config
make_fixture "${fixture}"

set_config_key "${fixture}/deploy.config" ANDROID_KEYSTORE_PASSWORD ""
expect_error "empty keystore password" "ANDROID_KEYSTORE_PASSWORD is required" \
  run_in_fixture "${fixture}" validate_config
make_fixture "${fixture}"

set_config_key "${fixture}/deploy.config" FLAVOR ""
expect_error "flavored without FLAVOR" "FLAVOR is required" \
  run_in_fixture "${fixture}" validate_config
make_fixture "${fixture}"

rm -f "${fixture}/secrets/play.json"
expect_error "missing Play JSON file" "GOOGLE_PLAY_JSON_KEY file not found" \
  run_in_fixture "${fixture}" validate_config
make_fixture "${fixture}"

set_config_key "${fixture}/deploy.config" PRE_BUILD_SCRIPT "hooks/missing.sh"
expect_error "missing pre-build script" "PRE_BUILD_SCRIPT file not found" \
  run_in_fixture "${fixture}" validate_config
make_fixture "${fixture}"

mkdir -p "${fixture}/hooks"
printf '#!/bin/bash\n' >"${fixture}/hooks/ok.sh"
set_config_key "${fixture}/deploy.config" PRE_BUILD_SCRIPT "hooks/ok.sh"
expect_ok "existing pre-build script passes" \
  run_in_fixture "${fixture}" validate_config
make_fixture "${fixture}"

set_config_key "${fixture}/deploy.config" DEPLOY_TARGET ios
set_config_key "${fixture}/deploy.config" ANDROID_KEYSTORE_PASSWORD ""
expect_ok "ios target does not require Android keys" \
  run_in_fixture "${fixture}" 'apply_deploy_target; validate_config'
make_fixture "${fixture}"

set_config_key "${fixture}/deploy.config" DEPLOY_TARGET google
set_config_key "${fixture}/deploy.config" IOS_TEAM_ID ""
set_config_key "${fixture}/deploy.config" ASC_KEY_ID ""
expect_ok "google target does not require App Store keys" \
  run_in_fixture "${fixture}" 'apply_deploy_target; validate_config'
make_fixture "${fixture}"

set_config_key "${fixture}/deploy.config" DEPLOY_TARGET windows
expect_error "rejects invalid DEPLOY_TARGET" "must be google, ios, or both" \
  run_in_fixture "${fixture}" apply_deploy_target
make_fixture "${fixture}"

mkdir -p "${fixture}/../build/app/outputs/bundle/liveRelease"
printf 'aab' >"${fixture}/../build/app/outputs/bundle/liveRelease/app-live-release.aab"
expect_ok "skip-build reuses existing flavored AAB" \
  run_in_fixture "${fixture}" '
    SKIP_BUILD_IF_EXISTS=true
    SKIP_ANDROID=false
    SKIP_IOS=true
    if will_build_android; then
      exit 1
    fi
    existing_android_aab
  '
make_fixture "${fixture}"

expect_ok "skip-build still builds when AAB is missing" \
  run_in_fixture "${fixture}" '
    SKIP_BUILD_IF_EXISTS=true
    SKIP_ANDROID=false
    will_build_android
  '
make_fixture "${fixture}"

expect_error "missing deploy.config" "Missing" \
  env RELEASE_DIR="${workdir}/empty" ROOT_DIR="${workdir}" \
  bash -c "set -euo pipefail; mkdir -p '${workdir}/empty'; source '${COMMON}'; load_deploy_config"

if [[ "$(uname -s)" != "Darwin" ]]; then
  if run_in_fixture "${fixture}" true 2>&1 | grep -Fq "skipping iOS build"; then
    pass "Linux warns and skips iOS build"
  else
    fail "Linux should warn about skipping iOS build"
  fi
fi

echo
echo "${passes} passed, ${failures} failed"
if [[ "${failures}" -ne 0 ]]; then
  exit 1
fi
