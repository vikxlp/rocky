#!/usr/bin/env bash

# Rocky Buddy — Event-triggered terminal companion
# Displays when talk or mind mode is active on plan ready, task complete, or error

EVENT_TYPE="${1:-unknown}"
VARIANTS_DIR="${CLAUDE_PLUGIN_ROOT}/assets"

# shellcheck source=_lib.sh
source "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

# Map short event names to valid Claude Code hook event names
case "$EVENT_TYPE" in
  task)  HOOK_EVENT_NAME="TaskCompleted" ;;
  plan)  HOOK_EVENT_NAME="PostToolUse" ;;
  error) HOOK_EVENT_NAME="PostToolUseFailure" ;;
  *)     HOOK_EVENT_NAME="$EVENT_TYPE" ;;
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
    *)
      responses=("Rocky observing situation.")
      ;;
  esac

  local count=${#responses[@]}
  local index=$((RANDOM % count))
  echo "${responses[$index]}"
}

# Select ASCII variant based on event type
select_variant() {
  local event=$1
  local variant_file=""

  case "$event" in
    task|plan)
      variant_file="$VARIANTS_DIR/variant-calm.txt"
      ;;
    error)
      variant_file="$VARIANTS_DIR/variant-concerned.txt"
      ;;
    *)
      variant_file="$VARIANTS_DIR/variant-default.txt"
      ;;
  esac

  if [ -f "$variant_file" ]; then
    cat "$variant_file"
  else
    cat "$VARIANTS_DIR/variant-default.txt" 2>/dev/null || echo "      ___
   __/o  \__
  / _  oo _ /
 /_/ \.__/
 \>   ' '"
  fi
}

# Main execution
if check_rocky_active; then
  response=$(select_response "$EVENT_TYPE")
  art=$(select_variant "$EVENT_TYPE")

  raw=$(printf '\nRocky: %s\n%s\n' "$response" "$art")
  escaped=$(printf '%s' "$raw" | escape_for_json)
  output_hook_json "$HOOK_EVENT_NAME" "$escaped"
fi

exit 0
