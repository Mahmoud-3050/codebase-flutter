# Shared helpers for release/scripts/deploy.sh.
# shellcheck shell=bash

if [[ -z "${RELEASE_DIR:-}" ]]; then
  RELEASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
if [[ -z "${ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd "${RELEASE_DIR}/.." && pwd)"
fi
export RELEASE_DIR ROOT_DIR

die() {
  echo "error: $*" >&2
  exit 1
}

is_true() {
  case "${1:-false}" in
    true | TRUE | True | yes | YES | 1) return 0 ;;
    *) return 1 ;;
  esac
}

require_keys() {
  local key
  for key in "$@"; do
    if [[ -z "${!key:-}" ]]; then
      die "deploy.config: ${key} is required but empty"
    fi
  done
}

require_file() {
  local key="$1"
  local path="${!key}"
  if [[ "${path}" != /* ]]; then
    path="${RELEASE_DIR}/${path}"
  fi
  [[ -f "${path}" ]] || die "deploy.config: ${key} file not found at ${path}"
}

require_hook_script() {
  local key="$1"
  local relative="${!key:-}"
  [[ -n "${relative}" ]] || return 0

  local path
  if [[ "${relative}" = /* ]]; then
    path="${relative}"
  elif [[ -f "${RELEASE_DIR}/${relative}" ]]; then
    path="${RELEASE_DIR}/${relative}"
  else
    path="${ROOT_DIR}/${relative}"
  fi
  [[ -f "${path}" ]] || die "deploy.config: ${key} file not found at ${path}"
}

load_deploy_config() {
  local config="${RELEASE_DIR}/deploy.config"
  if [[ ! -f "${config}" ]]; then
    die "Missing ${config}. Copy release/deploy.config.example to release/deploy.config and fill in values."
  fi
  set -a
  # shellcheck disable=SC1090
  source "${config}"
  set +a
}

ensure_ruby() {
  if ! command -v ruby >/dev/null 2>&1; then
    die "Ruby is required. Install with:
  sudo apt install ruby-full ruby-bundler
or:
  rbenv install 3.3.6 && rbenv global 3.3.6
then: gem install bundler"
  fi
  if ! command -v bundle >/dev/null 2>&1; then
    die "Bundler is required. Install with: gem install bundler"
  fi
}

ensure_bundle() {
  ensure_ruby
  (
    cd "${RELEASE_DIR}"
    if [[ ! -f Gemfile.lock ]] || ! bundle check >/dev/null 2>&1; then
      echo "Installing Fastlane gems..."
      bundle install
    fi
  )
}

run_fastlane() {
  local platform="$1"
  shift
  (
    cd "${ROOT_DIR}/${platform}"
    BUNDLE_GEMFILE="${RELEASE_DIR}/Gemfile" \
      FASTLANE_SKIP_UPDATE_CHECK=1 \
      bundle exec fastlane --fastfile "${RELEASE_DIR}/fastlane/${platform}/Fastfile" "$@"
  )
}

write_android_key_properties() {
  local keystore="${ANDROID_KEYSTORE_PATH}"
  if [[ "${keystore}" != /* ]]; then
    keystore="${RELEASE_DIR}/${keystore}"
  fi
  [[ -f "${keystore}" ]] || die "Keystore not found: ${keystore}"

  umask 077
  cat >"${ROOT_DIR}/android/key.properties" <<EOF
storePassword=${ANDROID_KEYSTORE_PASSWORD}
keyPassword=${ANDROID_KEY_PASSWORD}
keyAlias=${ANDROID_KEY_ALIAS}
storeFile=${keystore}
EOF
}

validate_google_play_track() {
  case "${GOOGLE_PLAY_TRACK}" in
    internal | production) ;;
    *)
      die "deploy.config: GOOGLE_PLAY_TRACK must be internal or production (got '${GOOGLE_PLAY_TRACK}')"
      ;;
  esac
}

validate_config() {
  require_keys USES_FLAVORS ENTRYPOINT

  if is_true "${USES_FLAVORS}"; then
    require_keys FLAVOR
  fi

  if ! is_true "${SKIP_ANDROID}"; then
    require_keys \
      GOOGLE_PLAY_PACKAGE_NAME \
      GOOGLE_PLAY_JSON_KEY \
      GOOGLE_PLAY_TRACK \
      GOOGLE_PLAY_RELEASE_STATUS \
      ANDROID_KEYSTORE_PATH \
      ANDROID_KEYSTORE_PASSWORD \
      ANDROID_KEY_ALIAS \
      ANDROID_KEY_PASSWORD
    validate_google_play_track
    require_file GOOGLE_PLAY_JSON_KEY
    require_file ANDROID_KEYSTORE_PATH
    require_hook_script ANDROID_PRE_BUILD_SCRIPT
  fi

  # App Store Connect credentials are still required on Linux so the shared
  # build number can see locked App Store versions. Signing material is only
  # required when this machine will archive an IPA.
  if ! is_true "${SKIP_IOS}"; then
    require_keys \
      IOS_BUNDLE_IDENTIFIER \
      ASC_KEY_ID \
      ASC_ISSUER_ID \
      ASC_KEY_PATH
    require_file ASC_KEY_PATH
  fi

  require_hook_script PRE_BUILD_SCRIPT

  if ! ios_build_skipped; then
    require_keys IOS_TEAM_ID
    if is_true "${USES_FLAVORS}"; then
      require_keys IOS_SCHEME IOS_CONFIGURATION
    fi
    require_hook_script IOS_PRE_BUILD_SCRIPT
  fi
}

ios_build_skipped() {
  is_true "${SKIP_IOS:-false}" || is_true "${SKIP_IOS_BUILD:-false}"
}

skip_ios_build_if_not_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "warning: iOS archive/upload requires macOS; skipping iOS build on $(uname -s). App Store version lookup still runs." >&2
    SKIP_IOS_BUILD="true"
    export SKIP_IOS_BUILD
  fi
}

run_preflight() {
  command -v flutter >/dev/null 2>&1 || die "flutter is not on PATH"
  (
    cd "${ROOT_DIR}"
    if is_true "${RUN_ANALYZE:-true}"; then
      echo "Running flutter analyze..."
      flutter analyze
    fi
    if is_true "${RUN_TESTS:-true}"; then
      echo "Running flutter test..."
      flutter test
    fi
  )
}

prepare_version() {
  if ! is_true "${SKIP_ANDROID}"; then
    run_fastlane android prepare_version
  elif ! is_true "${SKIP_IOS}"; then
    run_fastlane ios prepare_version
  else
    die "Both SKIP_ANDROID and SKIP_IOS are true; nothing to version."
  fi
}

maybe_commit_version() {
  if ! is_true "${COMMIT_VERSION_BUMP:-false}"; then
    return 0
  fi
  (
    cd "${ROOT_DIR}"
    if git diff --quiet -- pubspec.yaml; then
      return 0
    fi
    git add pubspec.yaml
    git commit -m "chore(release): bump version to $(sed -n 's/^version: //p' pubspec.yaml)"
  )
}

maybe_tag_version() {
  if ! is_true "${CREATE_GIT_TAG:-false}"; then
    return 0
  fi
  local version
  version="$(sed -n 's/^version: //p' "${ROOT_DIR}/pubspec.yaml" | tr -d '[:space:]')"
  (
    cd "${ROOT_DIR}"
    git tag -a "v${version}" -m "Release ${version}"
  )
}

deploy() {
  load_deploy_config
  skip_ios_build_if_not_macos
  validate_config
  if is_true "${DRY_RUN:-false}"; then
    echo "DRY_RUN: config is valid. Skipping preflight, version bump, build, and store upload."
    return 0
  fi
  ensure_bundle
  run_preflight
  prepare_version

  if ! is_true "${SKIP_ANDROID}"; then
    write_android_key_properties
    run_fastlane android deploy
  fi

  if ! ios_build_skipped; then
    run_fastlane ios deploy
  fi

  maybe_commit_version
  maybe_tag_version
  echo "Deploy finished (GOOGLE_PLAY_TRACK=${GOOGLE_PLAY_TRACK})."
}
