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

# Homebrew Ruby's gem home (/opt/homebrew/lib/ruby/gems) is not user-writable,
# so Bundler must install into release/vendor/bundle instead of the system dir.
# Do not export GEM_HOME/GEM_PATH: they leak into Flutter → Homebrew `pod` and
# make CocoaPods look broken ("installed but not working").
bundle_env() {
  export BUNDLE_GEMFILE="${RELEASE_DIR}/Gemfile"
  export BUNDLE_PATH="${RELEASE_DIR}/vendor/bundle"
}

ensure_bundle() {
  ensure_ruby
  (
    cd "${RELEASE_DIR}"
    bundle_env
    bundle config set --local path 'vendor/bundle'
    bundle config set --local disable_shared_gems 'true'
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
    cd "${RELEASE_DIR}"
    bundle_env
    FASTLANE_SKIP_UPDATE_CHECK=1 \
      bundle exec fastlane "${platform}" "$@"
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

usage() {
  cat <<'EOF'
Usage: bash release/scripts/deploy.sh [google|ios|both] [--skip-build]

  google         Play Store only
  ios            TestFlight only
  both           Google Play and TestFlight (default)
  --skip-build   Skip flutter build when the AAB/IPA already exists
  --no-skip-build
  -h, --help

Config defaults: DEPLOY_TARGET and SKIP_BUILD_IF_EXISTS in release/deploy.config.
EOF
}

parse_deploy_args() {
  CLI_DEPLOY_TARGET=""
  CLI_SKIP_BUILD=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      google | android | play)
        CLI_DEPLOY_TARGET="google"
        ;;
      ios | apple | testflight)
        CLI_DEPLOY_TARGET="ios"
        ;;
      both | all)
        CLI_DEPLOY_TARGET="both"
        ;;
      --skip-build)
        CLI_SKIP_BUILD="true"
        ;;
      --no-skip-build)
        CLI_SKIP_BUILD="false"
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        die "unknown argument: $1
$(usage)"
        ;;
    esac
    shift
  done
}

apply_deploy_target() {
  local target="${DEPLOY_TARGET:-}"
  [[ -n "${target}" ]] || return 0
  case "${target}" in
    google | android | play)
      SKIP_ANDROID="false"
      SKIP_IOS="true"
      DEPLOY_TARGET="google"
      ;;
    ios | apple | testflight)
      SKIP_ANDROID="true"
      SKIP_IOS="false"
      DEPLOY_TARGET="ios"
      ;;
    both | all)
      SKIP_ANDROID="false"
      SKIP_IOS="false"
      DEPLOY_TARGET="both"
      ;;
    *)
      die "DEPLOY_TARGET must be google, ios, or both (got '${target}')"
      ;;
  esac
  export SKIP_ANDROID SKIP_IOS DEPLOY_TARGET
}

infer_deploy_target() {
  if [[ -n "${DEPLOY_TARGET:-}" ]]; then
    return 0
  fi
  if is_true "${SKIP_ANDROID:-false}" && is_true "${SKIP_IOS:-false}"; then
    DEPLOY_TARGET="none"
  elif is_true "${SKIP_ANDROID:-false}"; then
    DEPLOY_TARGET="ios"
  elif is_true "${SKIP_IOS:-false}"; then
    DEPLOY_TARGET="google"
  else
    DEPLOY_TARGET="both"
  fi
  export DEPLOY_TARGET
}

export_cli_overrides() {
  export CLI_SKIP_ANDROID="${SKIP_ANDROID:-false}"
  export CLI_SKIP_IOS="${SKIP_IOS:-false}"
  export CLI_SKIP_IOS_BUILD="${SKIP_IOS_BUILD:-false}"
  export CLI_SKIP_BUILD_IF_EXISTS="${SKIP_BUILD_IF_EXISTS:-false}"
  export CLI_DEPLOY_TARGET="${DEPLOY_TARGET:-both}"
  export SKIP_BUILD_IF_EXISTS="${SKIP_BUILD_IF_EXISTS:-false}"
}

android_aab_path() {
  if is_true "${USES_FLAVORS:-false}"; then
    echo "${ROOT_DIR}/build/app/outputs/bundle/${FLAVOR}Release/app-${FLAVOR}-release.aab"
  else
    echo "${ROOT_DIR}/build/app/outputs/bundle/release/app-release.aab"
  fi
}

existing_android_aab() {
  [[ -f "$(android_aab_path)" ]]
}

existing_ios_ipa() {
  shopt -s nullglob
  local files=("${ROOT_DIR}/build/ios/ipa/"*.ipa)
  shopt -u nullglob
  if [[ ${#files[@]} -gt 0 ]]; then
    return 0
  fi
  [[ -f "${RELEASE_DIR}/Runner.ipa" ]]
}

will_build_android() {
  is_true "${SKIP_ANDROID:-false}" && return 1
  if is_true "${SKIP_BUILD_IF_EXISTS:-false}" && existing_android_aab; then
    return 1
  fi
  return 0
}

will_build_ios() {
  ios_build_skipped && return 1
  if is_true "${SKIP_BUILD_IF_EXISTS:-false}" && existing_ios_ipa; then
    return 1
  fi
  return 0
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
  if ! will_build_android && ! will_build_ios; then
    echo "Skipping version bump (reusing existing AAB/IPA; no Flutter build)."
    return 0
  fi
  if ! is_true "${SKIP_ANDROID}"; then
    run_fastlane android prepare_version
  elif ! is_true "${SKIP_IOS}"; then
    run_fastlane ios prepare_version
  else
    die "Nothing to deploy. Use: bash release/scripts/deploy.sh google|ios|both"
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
  parse_deploy_args "$@"
  load_deploy_config
  if [[ -n "${CLI_DEPLOY_TARGET}" ]]; then
    DEPLOY_TARGET="${CLI_DEPLOY_TARGET}"
  fi
  if [[ -n "${CLI_SKIP_BUILD}" ]]; then
    SKIP_BUILD_IF_EXISTS="${CLI_SKIP_BUILD}"
  fi
  SKIP_BUILD_IF_EXISTS="${SKIP_BUILD_IF_EXISTS:-false}"
  apply_deploy_target
  infer_deploy_target
  skip_ios_build_if_not_macos
  export_cli_overrides
  validate_config
  echo "Deploy target: ${DEPLOY_TARGET} (skip-build-if-exists=${SKIP_BUILD_IF_EXISTS})"
  if is_true "${DRY_RUN:-false}"; then
    echo "DRY_RUN: config is valid. Skipping preflight, version bump, build, and store upload."
    return 0
  fi
  ensure_bundle
  run_preflight
  prepare_version

  if ! is_true "${SKIP_ANDROID}"; then
    if will_build_android; then
      write_android_key_properties
    else
      echo "Reusing existing AAB: $(android_aab_path)"
    fi
    run_fastlane android deploy
  fi

  if ! ios_build_skipped; then
    if ! will_build_ios; then
      echo "Reusing existing IPA"
    fi
    run_fastlane ios deploy
  fi

  maybe_commit_version
  maybe_tag_version
  echo "Deploy finished (target=${DEPLOY_TARGET}, GOOGLE_PLAY_TRACK=${GOOGLE_PLAY_TRACK})."
}
