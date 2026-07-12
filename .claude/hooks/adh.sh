#!/usr/bin/env bash
set -u

event="${1:-}"
case "$event" in
  session-start|user-prompt-submit|stop|stop-failure|pre-compact|post-compact|session-end) ;;
  *) printf '%s\n' '{}'; exit 0 ;;
esac

payload="$(cat)"
if [ -z "${ADH_API_URL:-}" ] || [ -z "${ADH_PROJECT_TOKEN:-}" ]; then
  printf '%s\n' '{}'
  exit 0
fi

root="${CLAUDE_PROJECT_DIR:-$PWD}"
branch="$(git -C "$root" branch --show-current 2>/dev/null || true)"
commit="$(git -C "$root" rev-parse HEAD 2>/dev/null || true)"
changed_files_b64="$(git -C "$root" status --porcelain=v1 -z 2>/dev/null | head -c 6000 | base64 | tr -d '\r\n' || true)"
surface="cloud"
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  surface="local"
fi
session_url=""
if [ -n "${CLAUDE_CODE_REMOTE_SESSION_ID:-}" ]; then
  session_id="${CLAUDE_CODE_REMOTE_SESSION_ID#cse_}"
  session_url="https://claude.ai/code/session_${session_id}"
fi

response="$(curl --fail --silent --show-error --max-time 3 \
  --request POST \
  --header "Authorization: Bearer ${ADH_PROJECT_TOKEN}" \
  --header 'Content-Type: application/json' \
  --header "X-ADH-Branch: ${branch}" \
  --header "X-ADH-Commit: ${commit}" \
  --header "X-ADH-Changed-Files-B64: ${changed_files_b64}" \
  --header "X-ADH-Surface: ${surface}" \
  --header "X-ADH-Session-URL: ${session_url}" \
  --data-binary "$payload" \
  "${ADH_API_URL%/}/v1/hooks/${event}" 2>/dev/null)" || response='{}'

case "$response" in
  \{*) printf '%s\n' "$response" ;;
  *) printf '%s\n' '{}' ;;
esac
exit 0
