#!/usr/bin/env bash

# Rocky Buddy — Event-triggered terminal companion
# Displays when buddy is enabled on plan ready, task complete, session start, or error

EVENT_TYPE="${1:-unknown}"
BUDDY_ART_FILE="${CLAUDE_PLUGIN_ROOT}/skills/rocky-buddy/companion.txt"
STATE_FILE="$HOME/.claude/rocky-state.json"

# Check if buddy is enabled
check_buddy_enabled() {
  if [ ! -f "$STATE_FILE" ]; then
    return 1
  fi

  python3 -c "import json; d=json.load(open('$STATE_FILE')); exit(0 if d.get('buddy', False) else 1)" 2>/dev/null
  return $?
}

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

declare -a MESSAGE_RESPONSES=(
  "Rocky observing."
  "Engineering perspective applied."
  "Analysis complete."
  "Work continues good good good."
  "Rocky present. Monitoring progress."
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
    message)
      responses=("${MESSAGE_RESPONSES[@]}")
      ;;
    *)
      responses=("Rocky buddy observing situation.")
      ;;
  esac

  local count=${#responses[@]}
  local index=$((RANDOM % count))
  echo "${responses[$index]}"
}

# Select ASCII variant based on event type
select_variant() {
  local event=$1
  local variants_dir="${CLAUDE_PLUGIN_ROOT}/skills/rocky-buddy"
  local variant_file=""

  case "$event" in
    session)
      variant_file="$variants_dir/variant-ready.txt"
      ;;
    task)
      variant_file="$variants_dir/variant-calm.txt"
      ;;
    error)
      variant_file="$variants_dir/variant-concerned.txt"
      ;;
    plan)
      variant_file="$variants_dir/variant-calm.txt"
      ;;
    message)
      # Rotate variants for message events
      local rand=$((RANDOM % 3))
      case $rand in
        0) variant_file="$variants_dir/variant-ready.txt" ;;
        1) variant_file="$variants_dir/variant-calm.txt" ;;
        2) variant_file="$variants_dir/variant-concerned.txt" ;;
      esac
      ;;
    *)
      variant_file="$variants_dir/companion.txt"
      ;;
  esac

  if [ -f "$variant_file" ]; then
    cat "$variant_file"
  else
    # Fallback to original
    if [ -f "$BUDDY_ART_FILE" ]; then
      cat "$BUDDY_ART_FILE"
    else
      echo "      ___"
      echo "   __/°  \__"
      echo "  / _     _ \\"
      echo " / //\\\___/ \\ \\"
      echo "/ / \\\\   \\\\ \\ \\"
      echo "\\ \\  \>  </ / /"
      echo " \\_>       <_/"
    fi
  fi
}

# Read buddy ASCII art (uses variant selection)
read_buddy_art() {
  select_variant "$EVENT_TYPE"
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

# Main execution
if check_buddy_enabled; then
  generate_hook_output
else
  # Buddy disabled, return empty hook output
  # For message events, silent when disabled
  # For other events, still return structured response
  if [ "$EVENT_TYPE" = "message" ]; then
    # Silent - no output
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${EVENT_TYPE}",
    "buddyEnabled": false
  }
}
EOF
  else
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${EVENT_TYPE}",
    "buddyEnabled": false
  }
}
EOF
  fi
fi

exit 0
