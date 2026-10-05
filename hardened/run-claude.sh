#!/usr/bin/env bash
# Start Claude Code through a local OmniRoute, for THIS command only.
# Nothing is exported to your shell or written to settings.json, so normal
# Claude Code sessions keep talking to Anthropic.
#   usage: OMNIROUTE_KEY=sk-... ./run-claude.sh [claude args]
set -euo pipefail
: "${OMNIROUTE_KEY:?set OMNIROUTE_KEY to the API key created in the OmniRoute dashboard}"
URL="${OMNIROUTE_URL:-http://127.0.0.1:20128}"   # no /v1 suffix, per upstream docs
case "$URL" in
  http://127.0.0.1:*|http://localhost:*) ;;
  *) echo "Refusing non-loopback OMNIROUTE_URL: $URL" >&2; exit 1 ;;
esac
ANTHROPIC_BASE_URL="$URL" ANTHROPIC_AUTH_TOKEN="$OMNIROUTE_KEY" exec claude "$@"
