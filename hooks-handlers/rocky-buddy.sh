#!/usr/bin/env bash

# Rocky Buddy — Event-triggered terminal companion
# Displays when buddy is enabled on plan ready, task complete, session start, or error

EVENT_TYPE="${1:-unknown}"
STATE_FILE="$HOME/.claude/rocky-state.json"

# Map short event names to valid Claude Code hook event names
case "$EVENT_TYPE" in
  session) HOOK_EVENT_NAME="SessionStart" ;;
  task)    HOOK_EVENT_NAME="TaskCompleted" ;;
  plan)    HOOK_EVENT_NAME="PostToolUse" ;;
  error)   HOOK_EVENT_NAME="PostToolUseFailure" ;;
  *)       HOOK_EVENT_NAME="$EVENT_TYPE" ;;
esac

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

declare -a HAPPY_RESPONSES=(
  "Task finished. Excellent work, friend."
  "Success success success. Progress excellent."
  "Mechanism complete. Quality good good good."
  "Accomplished. Moving forward strong."
  "Work finished. Victory observed."
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

declare -a CALM_RESPONSES=(
  "Friend, Rocky observe progress."
  "Working as planned, friend."
  "Mechanism sound. Proceeding."
  "All well. Continuing forward."
  "Steady progress, friend."
)

declare -a SORRY_RESPONSES=(
  "Problem found. Rocky apologize, friend."
  "Error detected. Rocky regret situation."
  "Mechanism failed. Rocky work fix, friend."
  "Mistake observed. Rocky make right."
  "Problem bad. Rocky sorry, friend."
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
      responses=("${HAPPY_RESPONSES[@]}")
      ;;
    message)
      responses=("${CALM_RESPONSES[@]}")
      ;;
    error)
      # Randomize between concerned and sorry responses
      local error_choice=$((RANDOM % 2))
      if [ $error_choice -eq 0 ]; then
        responses=("${ERROR_RESPONSES[@]}")
      else
        responses=("${SORRY_RESPONSES[@]}")
      fi
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
      variant_file="$variants_dir/variant-happy.txt"
      ;;
    message)
      variant_file="$variants_dir/variant-calm.txt"
      ;;
    error)
      # Randomize between concerned and sorry
      local error_variants=("concerned" "sorry")
      local error_choice=${error_variants[$((RANDOM % 2))]}
      variant_file="$variants_dir/variant-${error_choice}.txt"
      ;;
    plan)
      variant_file="$variants_dir/variant-ready.txt"
      ;;
    *)
      variant_file="$variants_dir/variant-ready.txt"
      ;;
  esac

  if [ -f "$variant_file" ]; then
    cat "$variant_file"
  else
    # Fallback to variant-ready
    local fallback_file="${CLAUDE_PLUGIN_ROOT}/skills/rocky-buddy/variant-ready.txt"
    if [ -f "$fallback_file" ]; then
      cat "$fallback_file"
    else
      echo "      ___"
      echo "   __/o  \__"
      echo "  / _  oo _ \\"
      echo " /_/ \.__/"
      echo " \>   ' '"
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
  local display=$(display_buddy)

  # Escape for JSON
  local escaped_display=$(printf '%s' "$display" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read())[1:-1])" 2>/dev/null || echo "$display")

  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${HOOK_EVENT_NAME}",
    "additionalContext": "${escaped_display}"
  }
}
EOF
}

# Main execution
if check_buddy_enabled; then
  generate_hook_output
else
  cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "${HOOK_EVENT_NAME}",
    "buddyEnabled": false
  }
}
EOF
fi

exit 0
