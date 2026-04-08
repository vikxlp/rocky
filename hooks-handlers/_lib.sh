#!/usr/bin/env bash

# Rocky Plugin — Shared Hook Utilities
# Sourced by session-start.sh and rocky-buddy.sh

STATE_FILE="${STATE_FILE:-$HOME/.claude/rocky-state.json}"

# Read a boolean key from rocky state file.
# Usage: get_rocky_state "talk"  →  prints "true" or "false"
get_rocky_state() {
  local key=$1
  if [ ! -f "$STATE_FILE" ]; then
    echo "false"
    return
  fi
  python3 -c "import json; d=json.load(open('$STATE_FILE')); print(str(d.get('$key', False)).lower())" 2>/dev/null || echo "false"
}

# Check if rocky is active (talk or mind). Exit 0 = yes, exit 1 = no.
check_rocky_active() {
  if [ ! -f "$STATE_FILE" ]; then
    return 1
  fi
  python3 -c "import json; d=json.load(open('$STATE_FILE')); exit(0 if d.get('talk', False) or d.get('mind', False) else 1)" 2>/dev/null
  return $?
}

# Escape stdin for embedding in a JSON string value.
# Usage: printf '%s' "$text" | escape_for_json
escape_for_json() {
  python3 -c "import sys,json; print(json.dumps(sys.stdin.read())[1:-1])" 2>/dev/null
}

# Output hook result JSON with additionalContext.
# Usage: output_hook_json "SessionStart" "$escaped_context"
output_hook_json() {
  local event_name=$1
  local context=$2
  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${event_name}",
    "additionalContext": "${context}"
  }
}
EOF
}
