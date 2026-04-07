#!/usr/bin/env bash

# Rocky Buddy — Event-triggered terminal companion
# Displays on plan ready, task complete, or error with sarcastic one-liner

EVENT_TYPE="${1:-unknown}"
BUDDY_ART_FILE="${CLAUDE_PLUGIN_ROOT}/skills/rocky-buddy/companion.txt"

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
  "I am here. What problem need solving, question?"
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

# Format speech bubble
format_bubble() {
  local text=$1
  local width=35
  local padding=2

  # Pad text to width
  local padded="$text"
  local text_len=${#text}
  if [ $text_len -lt $((width - padding)) ]; then
    local spaces=$((width - text_len - padding))
    padded="$text$(printf ' %.0s' $(seq 1 $spaces))"
  fi

  # Speech bubble
  echo "┌─────────────────────────────────────┐"
  echo "│ $padded │"
  echo "└─────────────────────────────────────┘"
}

# Main display function
display_buddy() {
  local response=$(select_response "$EVENT_TYPE")
  local bubble=$(format_bubble "$response")
  local art=$(read_buddy_art)

  # Display bubble and buddy side by side
  echo ""
  echo "$bubble     $art" | head -7
  echo ""
}

# Generate hook output JSON
generate_hook_output() {
  local response=$(select_response "$EVENT_TYPE")
  local display=$(display_buddy)

  # Escape for JSON
  local escaped_display=$(printf '%s' "$display" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read())[1:-1])" 2>/dev/null || echo "$display")

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${EVENT_TYPE}",
    "buddyResponse": "${response}",
    "displayOutput": "${escaped_display}"
  }
}
EOF
}

# Execute
generate_hook_output
exit 0
