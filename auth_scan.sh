#!/usr/bin/env bash
set -e
OUT=".c13b0_auth_scan"
mkdir -p "$OUT"

PATTERNS=(
  "localStorage.setItem"
  "indexedDB"
  "sessionStorage"
  "restoreSession"
  "autoLogin"
  "isLoggedIn"
  "jwt"
  "authToken"
  "accessToken"
  "refreshToken"
  "SameSite"
  "max-age"
  "expires="
  "firebase.auth"
  "supabase.auth"
)

scan_repo () {
  local repo="$1"
  local name="$(basename "$repo")"
  local hits=()

  for p in "${PATTERNS[@]}"; do
    rg -i "$p" "$repo" >/dev/null 2>&1 && hits+=("$p")
  done

  [ "${#hits[@]}" -eq 0 ] && return

  printf '{\n  "repo": "%s",\n  "path": "%s",\n  "persistent_auth_detected": true,\n  "matched_patterns": %s\n}\n' \
    "$name" "$repo" \
    "$(printf '%s\n' "${hits[@]}" | jq -R . | jq -s .)" \
    > "$OUT/${name}_auth_report.json"

  echo "🧱⭐ AUTH FOUND → $name"
}

export -f scan_repo
export PATTERNS
export OUT

find .. -maxdepth 2 -type d -name ".git" -prune -exec bash -c 'scan_repo "$(dirname "{}")"' \;

echo "🧱 Scan finished"
