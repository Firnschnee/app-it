#!/bin/bash
# Stop the tiny static servers spawned by app-it-static launchers, plus any open
# wrapper windows. file:// apps have no server — only a window to close.
#
# Reads scripts/app-it.config.json (app-it-static schema). The static server is
# a single Python process (no re-parenting children), so cleanup is simpler than
# app-it's dev-server case — but we still port-sweep defensively.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${APP_IT_PROJECT_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CONFIG_FILE="$SCRIPT_DIR/app-it.config.json"

# Record per app: name|slug|serve_mode|preferred_port
APPS=()
if [ -f "$CONFIG_FILE" ]; then
    while IFS= read -r line; do
        [ -n "$line" ] && APPS+=("$line")
    done < <(/usr/bin/python3 - "$CONFIG_FILE" <<'PY'
import json, re, sys
with open(sys.argv[1]) as f:
    cfg = json.load(f)
for a in cfg.get("apps", []):
    name = a.get("name", "")
    slug = a.get("slug") or re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    print(f'{name}|{slug}|{a.get("serve_mode","server")}|{a.get("port","") or ""}')
PY
)
else
    echo "ERROR: scripts/app-it.config.json not found." >&2
    exit 1
fi

if [ "${#APPS[@]}" -eq 0 ]; then
    echo "ERROR: no apps configured." >&2
    exit 1
fi

kill_tree() {
    local pid=$1
    [ -z "$pid" ] && return
    kill -0 "$pid" 2>/dev/null || return
    for child in $(pgrep -P "$pid" 2>/dev/null); do
        kill_tree "$child"
    done
    kill -TERM "$pid" 2>/dev/null || true
}

sweep_port() {
    local pid_file="$1"
    local port="$2"
    [ -z "$port" ] && return 0
    if [ -f "$pid_file" ]; then
        kill_tree "$(cat "$pid_file")"
        CLOSED_ANY=1
    fi
    for p in $(lsof -ti tcp:"$port" 2>/dev/null); do
        kill_tree "$p"
        CLOSED_ANY=1
    done
    if lsof -ti tcp:"$port" >/dev/null 2>&1; then
        for _ in 1 2 3; do
            [ -z "$(lsof -ti tcp:"$port" 2>/dev/null)" ] && break
            sleep 0.5
        done
        for p in $(lsof -ti tcp:"$port" 2>/dev/null); do
            kill -KILL "$p" 2>/dev/null || true
            CLOSED_ANY=1
        done
    fi
    return 0
}

CLOSED_ANY=0
for entry in "${APPS[@]}"; do
    IFS='|' read -r APP_NAME APP_SLUG SERVE_MODE PREFERRED_PORT <<<"$entry"
    [ "$SERVE_MODE" = "file" ] && continue   # no server to stop
    STATE_DIR="$HOME/Library/Application Support/app-it/$APP_SLUG"
    PID_FILE="$STATE_DIR/server.pid"
    PORT_FILE="$STATE_DIR/server.port"
    PORT="$(cat "$PORT_FILE" 2>/dev/null || true)"
    [ -z "$PORT" ] && PORT="$PREFERRED_PORT"
    sweep_port "$PID_FILE" "$PORT"
    if [ -n "$PREFERRED_PORT" ] && [ "$PORT" != "$PREFERRED_PORT" ]; then
        sweep_port "" "$PREFERRED_PORT"
    fi
    rm -f "$PID_FILE" "$PORT_FILE"
done

# Native WebKit wrapper windows (both modes). Match the ASCII bundle-path
# fragment, then confirm via the app name in argv (URL may be http:// or file://).
for entry in "${APPS[@]}"; do
    IFS='|' read -r APP_NAME _ _ _ <<<"$entry"
    for p in $(pgrep -f "MacOS/wrapper " 2>/dev/null); do
        cmdline="$(ps -o command= -p "$p" 2>/dev/null || true)"
        # Anchor on the bundle dir ("<AppName>.app/Contents/MacOS/wrapper") so an
        # app named "Fjord" can't also match "Fjord Studio". The .app/Contents/
        # MacOS/wrapper tail is ASCII; only the bundle name may carry non-ASCII.
        if echo "$cmdline" | grep -qF "$APP_NAME.app/Contents/MacOS/wrapper"; then
            kill -TERM "$p" 2>/dev/null || true
            CLOSED_ANY=1
        fi
    done
done

if [ "$CLOSED_ANY" = "1" ]; then
    echo "Stopped any running servers and open windows."
else
    echo "Nothing to stop."
fi
