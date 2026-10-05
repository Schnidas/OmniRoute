#!/usr/bin/env bash
# Prepare a hardened local OmniRoute data dir. Does not start the server.
# UNTESTED by the author of this file: read it before you run it.
set -euo pipefail

PINNED=23a11484862b3bb589a55e85b00e4ac53ffeb234   # the commit that was reviewed
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
export DATA_DIR="${DATA_DIR:-$HOME/.omniroute-hardened}"

command -v openssl >/dev/null || { echo "openssl is required" >&2; exit 1; }
command -v node >/dev/null || { echo "node is required (see package.json engines)" >&2; exit 1; }

# Refuse to run on code that is not the reviewed commit unless told to.
HEAD_SHA="$(git -C "$REPO" rev-parse HEAD 2>/dev/null || echo unknown)"
if [ "$HEAD_SHA" != "$PINNED" ] && [ "${ALLOW_UNREVIEWED:-0}" != "1" ]; then
  echo "HEAD ($HEAD_SHA) is not the reviewed commit $PINNED." >&2
  echo "Review: git -C $REPO diff $PINNED..HEAD --stat , then re-run with ALLOW_UNREVIEWED=1." >&2
  exit 1
fi

mkdir -p "$DATA_DIR"; chmod 700 "$DATA_DIR"
ENV_FILE="$DATA_DIR/.env"
if [ -e "$ENV_FILE" ]; then
  echo "$ENV_FILE already exists, leaving it alone." >&2
  exit 0
fi

rnd() { openssl rand -hex 32; }
sed -e "s/CHANGEME_JWT/$(rnd)/" \
    -e "s/CHANGEME_API/$(rnd)/" \
    -e "s/CHANGEME_STORAGE/$(rnd)/" \
    -e "s/CHANGEME_PASSWORD/$(openssl rand -base64 18 | tr -d '/+=')/" \
    "$HERE/env.template" > "$ENV_FILE"
chmod 600 "$ENV_FILE"

cat <<MSG
Wrote $ENV_FILE (mode 600). It contains your generated secrets and dashboard password.
Next, from $REPO:
  npm ci && npm run build
  DATA_DIR="$DATA_DIR" node bin/omniroute.mjs
Then open http://127.0.0.1:20128 , add FREE providers only (never your Claude login),
and create an API key in the dashboard for run-claude.sh.
To remove everything: stop the server and delete $DATA_DIR
MSG
