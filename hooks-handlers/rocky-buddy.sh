#!/usr/bin/env bash

# Rocky Buddy — Event-triggered terminal companion
# Displays when buddy is enabled on plan ready, task complete, session start, or error

EVENT_TYPE="${1:-unknown}"
BUDDY_ART_FILE="${CLAUDE_PLUGIN_ROOT}/skills/rocky-buddy/companion.txt"

# shellcheck source=_lib.sh
source "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

# Map short event names to valid Claude Code hook event names
case "$EVENT_TYPE" in
  session) HOOK_EVENT_NAME="SessionStart" ;;
  task)    HOOK_EVENT_NAME="TaskCompleted" ;;
  plan)    HOOK_EVENT_NAME="PostToolUse" ;;
  error)   HOOK_EVENT_NAME="PostToolUseFailure" ;;
  *)       HOOK_EVENT_NAME="$EVENT_TYPE" ;;
esac


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
  local display=$(display_buddy)
  local escaped_display=$(printf '%s' "$display" | escape_for_json)
  output_hook_json "$HOOK_EVENT_NAME" "$escaped_display"
}

# Main execution
if check_buddy_enabled; then
  generate_hook_output
else
  output_hook_json "$HOOK_EVENT_NAME" ""
fi

exit 0
