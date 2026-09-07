#!/usr/bin/env bash
#
# Heuristic memory-leak scanner for Flutter/Dart sources.
#
# Reports acquire/release imbalances: things created but never disposed, cancelled, or
# removed, plus references that outlive their owner. Every hit is a CANDIDATE and must be
# read before it is reported as a leak — ownership (who created the object) decides
# whether a missing release is a bug.
#
# Usage: bash scan_leaks.sh [target_dir]      (default: lib)

set -uo pipefail

TARGET="${1:-lib}"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: ripgrep (rg) is required" >&2
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "error: '$TARGET' is not a directory" >&2
  exit 1
fi

DISPOSABLES='AnimationController|TextEditingController|ScrollController|PageController|TabController|FocusNode|StreamController|OverlayEntry|ValueNotifier|TransformationController|VideoPlayerController|CameraController|Ticker'

findings=0

# Count regex matches in one file; prints 0 when there are none.
count() {
  local matches
  matches="$(rg --pcre2 --no-messages --count-matches "$1" "$2" 2>/dev/null)" || matches=0
  echo "${matches:-0}"
}

has() {
  rg --pcre2 --no-messages -q "$1" "$2" 2>/dev/null
}

section() {
  printf '\n\033[1m%s\033[0m\n' "$1"
}

hit() {
  printf '  %s\n' "$1"
  findings=$((findings + 1))
}

mapfile -t DART_FILES < <(rg --files "$TARGET" -g '*.dart' -g '!*.g.dart' -g '!*.freezed.dart' | sort)

echo "Scanning ${#DART_FILES[@]} Dart files under '$TARGET'"

# ---------------------------------------------------------------------------
section '1. Disposables created with no dispose()/close() in the same file'
for file in "${DART_FILES[@]}"; do
  created="$(count "\\b(${DISPOSABLES})\\(" "$file")"
  [[ "$created" -eq 0 ]] && continue
  has 'void dispose\(\)|Future<void> close\(\)' "$file" && continue
  types="$(rg --pcre2 --no-messages -o "\\b(${DISPOSABLES})\\(" "$file" | sed 's/($//;s/(//' | sort -u | paste -sd, -)"
  hit "$file — creates: $types"
done

# ---------------------------------------------------------------------------
section '2. Disposables created more often than disposed'
for file in "${DART_FILES[@]}"; do
  created="$(count "\\b(${DISPOSABLES})\\(" "$file")"
  [[ "$created" -eq 0 ]] && continue
  disposed="$(count '\.dispose\(\)' "$file")"
  if [[ "$created" -gt "$disposed" ]]; then
    hit "$file — $created created, $disposed disposed"
  fi
done

# ---------------------------------------------------------------------------
section '3. Subscriptions and timers with no matching cancel()'
for file in "${DART_FILES[@]}"; do
  listens="$(count '\.listen\(' "$file")"
  timers="$(count '\bTimer\(|\bTimer\.periodic\(' "$file")"
  acquired=$((listens + timers))
  [[ "$acquired" -eq 0 ]] && continue
  cancels="$(count '\.cancel\(\)' "$file")"
  if [[ "$acquired" -gt "$cancels" ]]; then
    hit "$file — listen:$listens timer:$timers vs cancel:$cancels"
  fi
done

# ---------------------------------------------------------------------------
section '4. Listeners/observers added but not removed'
for file in "${DART_FILES[@]}"; do
  added="$(count '\.addListener\(|\.addObserver\(' "$file")"
  [[ "$added" -eq 0 ]] && continue
  removed="$(count '\.removeListener\(|\.removeObserver\(' "$file")"
  if [[ "$added" -gt "$removed" ]]; then
    hit "$file — added:$added removed:$removed"
  fi
done

# ---------------------------------------------------------------------------
section '5. Cubit/Bloc holding async resources with no close() override'
for file in "${DART_FILES[@]}"; do
  has 'extends Cubit<|extends Bloc<' "$file" || continue
  has '\.listen\(|\bTimer\(|\bTimer\.periodic\(|StreamSubscription|StreamController' "$file" || continue
  has 'Future<void> close\(\)' "$file" && continue
  hit "$file"
done

# ---------------------------------------------------------------------------
section '6. BuildContext or setState used after await with no mounted guard'
rg --pcre2 -U -n --no-heading --no-messages \
  'await\b[^;]*;(?:(?!mounted)[\s\S]){0,300}?(?:setState\(|\.of\(context\)|context\.[a-zA-Z])' \
  "$TARGET" -g '*.dart' -g '!*.g.dart' -o --replace '<await … then context/setState>' |
  while IFS= read -r line; do printf '  %s\n' "$line"; done

# ---------------------------------------------------------------------------
section '7. BuildContext stored in a field (never collectable)'
rg --pcre2 -n --no-heading --no-messages \
  '^\s*(?:static\s+|late\s+|final\s+)*BuildContext\??\s+_?\w+\s*[;=]' \
  "$TARGET" -g '*.dart' | while IFS= read -r line; do printf '  %s\n' "$line"; done

# ---------------------------------------------------------------------------
section '8. Cubits registered as singletons (must be registerFactory)'
rg --pcre2 -n --no-heading --no-messages \
  'registerLazySingleton<[^>]*(?:Cubit|Bloc)>|registerSingleton<[^>]*(?:Cubit|Bloc)>' \
  "$TARGET" -g '*.dart' | while IFS= read -r line; do printf '  %s\n' "$line"; done

# ---------------------------------------------------------------------------
section '9. Mutable static collections (unbounded cache candidates)'
rg --pcre2 -n --no-heading --no-messages \
  '\bstatic\s+(?:final\s+|late\s+)*(?:Map|List|Set|LinkedHashMap|Queue)<[^=;()]*>\s+\w+\s*=' \
  "$TARGET" -g '*.dart' | while IFS= read -r line; do printf '  %s\n' "$line"; done

printf '\n\033[1mSections 1–5 candidates: %s\033[0m\n' "$findings"
echo 'Heuristics only — read each file and confirm ownership before reporting a leak.'
