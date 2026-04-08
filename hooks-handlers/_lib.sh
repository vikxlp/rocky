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

# Build the session greeting block: random greeting line + variant-ready art.
# Usage: get_session_greeting "$ASSETS_DIR"
get_session_greeting() {
  local assets_dir="${1:-$SCRIPT_DIR/../assets}"

  local -a SESSION_RESPONSES=(
    "Rocky here. Ready to work, friend."
    "Observing. Session beginning."
    "Rocky here. What problem need solving, question?"
    "Ready. Building awaits."
    "Session active. Let us engineer good good good."
  )
  local response="${SESSION_RESPONSES[$((RANDOM % ${#SESSION_RESPONSES[@]}))]}"

  local buddy_file="$assets_dir/variant-ready.txt"
  local buddy_art=""
  if [ -f "$buddy_file" ]; then
    buddy_art=$(cat "$buddy_file")
  else
    buddy_art=$(cat "$assets_dir/variant-default.txt" 2>/dev/null || printf '      ___\n   __/\260  \\__\n  / _     _ \\\n / //\\___/ \\ \\\n/ / \\\\   \\\\ \\ \\\n\\ \\  \\>  </ / /\n \\_>       <_/')
  fi

  printf '\nRocky: %s\n%s\n' "$response" "$buddy_art"
}
