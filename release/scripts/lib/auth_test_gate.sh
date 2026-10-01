# Auth coverage and risk-test gate. Sourced by common.sh.

auth_line_coverage_percent() {
  local lcov="$1"
  python3 - "${lcov}" <<'PY'
import sys
path = sys.argv[1]
current = None
include = False
lh = lf = 0
total_lh = total_lf = 0
with open(path, encoding="utf-8") as handle:
    for raw in handle:
        line = raw.strip()
        if line.startswith("SF:"):
            current = line[3:]
            include = current.startswith("lib/features/auth/") and not current.endswith(
                ".g.dart"
            )
            lh = lf = 0
        elif include and line.startswith("LH:"):
            lh = int(line[3:])
        elif include and line.startswith("LF:"):
            lf = int(line[3:])
        elif line == "end_of_record" and include:
            total_lh += lh
            total_lf += lf
if total_lf == 0:
    sys.exit("auth coverage file has no lib/features/auth records")
print(f"{(100 * total_lh / total_lf):.2f}")
PY
}

require_auth_risk_tests() {
  local root="$1"
  local list="${root}/release/auth_risk_tests.txt"
  local missing=0
  local name
  while IFS= read -r name || [[ -n "${name}" ]]; do
    name="${name%%#*}"
    name="${name#"${name%%[![:space:]]*}"}"
    name="${name%"${name##*[![:space:]]}"}"
    [[ -z "${name}" ]] && continue
    if ! grep -R -F -q --include='*_test.dart' -e "${name}" "${root}/test"; then
      echo "missing auth risk test: ${name}" >&2
      missing=1
    fi
  done < "${list}"
  [[ "${missing}" -eq 0 ]]
}

enforce_auth_coverage() {
  local lcov="$1"
  local minimum="${2:-90}"
  local percent
  percent="$(auth_line_coverage_percent "${lcov}")"
  echo "Auth line coverage: ${percent}% (minimum ${minimum}%)"
  python3 -c 'import sys; sys.exit(0 if float(sys.argv[1]) >= float(sys.argv[2]) else 1)' \
    "${percent}" "${minimum}"
}

run_auth_test_gate() {
  local root="${ROOT_DIR:?ROOT_DIR is required}"
  require_auth_risk_tests "${root}"
  (
    cd "${root}"
    flutter test --coverage \
      test/features/auth \
      test/core/di/auth_data_scope_lease_test.dart \
      test/core/api/api_interceptors_test.dart
  )
  enforce_auth_coverage "${root}/coverage/lcov.info" 90
}
