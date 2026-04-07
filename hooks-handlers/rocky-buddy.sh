#!/usr/bin/env bash

# Rocky Buddy — Event-triggered terminal companion
# Displays when buddy is enabled on plan ready, task complete, session start, or error

EVENT_TYPE="${1:-unknown}"
BUDDY_ART_FILE="${CLAUDE_PLUGIN_ROOT}/skills/rocky-buddy/companion.txt"
STATE_FILE="$HOME/.claude/rocky-state.json"

# Map short event arg to proper Claude Code hook event name
case "$EVENT_TYPE" in
  session) HOOK_EVENT_NAME="SessionStart" ;;
  task)    HOOK_EVENT_NAME="TaskCompleted" ;;
  plan)    HOOK_EVENT_NAME="PostToolUse" ;;
  error)   HOOK_EVENT_NAME="PostToolUseFailure" ;;
  *)       HOOK_EVENT_NAME="$EVENT_TYPE" ;;
esac

# Check if buddy is enabled — exit early before building response arrays
if [ ! -f "$STATE_FILE" ] || ! python3 -c "import json; d=json.load(open('$STATE_FILE')); exit(0 if d.get('buddy', False) else 1)" 2>/dev/null; then
  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${HOOK_EVENT_NAME}",
    "additionalContext": ""
  }
}
EOF
  exit 0
fi

# One-liner response collections
declare -a PLAN_RESPONSES=(
  "Plan good good good. Now do work."
  "Structure sound. Execute now."
  "Plan exists. Building comes next."
  "Approach logical. Proceed with execution."
  "Strategy acceptable. Implementation begins."
)

declare -a TASK_RESPONSES=(
  "Task finished. Excellent work, friend."
  "Done. Moving forward."
  "Mechanism complete. Quality good good good."
  "Accomplished. Next problem, question?"
  "Work finished. Progress observed."
)

declare -a ERROR_RESPONSES=(
  "Problem found. Debug and fix."
  "System broken. Expected outcome not met."
  "Error exists. Investigate cause."
  "Mechanism failed. Cause unclear. Test more."
  "Defect observed. Engineering required."
)

declare -a SESSION_RESPONSES=(
  "Rocky here. Ready to work, friend."
  "Observing. Session beginning."
  "Rocky here. What problem need solving, question?"
  "Ready. Building awaits."
  "Session active. Let us engineer good good good."
)

# Select random response based on event
select_response() {
  local event=$1
  local responses=()

  case "$event" in
    plan)
      responses=("${PLAN_RESPONSES[@]}")
      ;;
    task)
      responses=("${TASK_RESPONSES[@]}")
      ;;
    error)
      responses=("${ERROR_RESPONSES[@]}")
      ;;
    session)
      responses=("${SESSION_RESPONSES[@]}")
      ;;
    *)
      responses=("Rocky buddy observing situation.")
      ;;
  esac

  local count=${#responses[@]}
  local index=$((RANDOM % count))
  echo "${responses[$index]}"
}

# Read buddy ASCII art
read_buddy_art() {
  if [ -f "$BUDDY_ART_FILE" ]; then
    cat "$BUDDY_ART_FILE"
  else
    # Fallback
    echo "      ___"
    echo "   __/°  \__"
    echo "  / _     _ \\"
    echo " / //\\\___/ \\ \\"
    echo "/ / \\\\   \\\\ \\ \\"
    echo "\\ \\  \\>  </ / /"
    echo " \\_>       <_/"
  fi
}

# Format speech (no bubble border)
format_bubble() {
  local text=$1
  # Just show text with Rocky prefix
  echo "Rocky: $text"
}

# Main display function
display_buddy() {
  local response=$(select_response "$EVENT_TYPE")
  local bubble=$(format_bubble "$response")
  local art=$(read_buddy_art)

  # Display bubble on top, art below
  echo ""
  echo "$bubble"
  echo "$art"
  echo ""
}

# Generate hook output JSON
generate_hook_output() {
  local display=$(display_buddy)

  # Escape for JSON (same pattern as session-start.sh)
  local escaped_display=$(printf '%s' "$display" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read())[1:-1])" 2>/dev/null || echo "")

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${HOOK_EVENT_NAME}",
    "additionalContext": "${escaped_display}"
  }
}
EOF
}

# Main execution (buddy enabled — early exit for disabled case is above)
generate_hook_output

exit 0
