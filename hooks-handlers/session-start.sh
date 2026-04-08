#!/usr/bin/env bash

# Rocky Plugin — SessionStart Hook
# Reads ~/.claude/rocky-state.json and injects personality rules from SKILL.md files
# Talk rules: skills/rocky-talk/SKILL.md | Mind rules: skills/rocky/SKILL.md (single source of truth)
# Extracted via <!-- RULES:START --> / <!-- RULES:END --> delimiters

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../skills"

# shellcheck source=_lib.sh
source "$SCRIPT_DIR/_lib.sh"

# Read state
TALK=$(get_rocky_state "talk")
MIND=$(get_rocky_state "mind")

# If neither mode is active, exit with empty context
if [ "$TALK" = "false" ] && [ "$MIND" = "false" ]; then
  output_hook_json "SessionStart" ""
  exit 0
fi

# Build the additionalContext string by extracting rules from SKILL.md files
CONTEXT=""

if [ "$TALK" = "true" ]; then
  TALK_SKILL="$SKILLS_DIR/rocky-talk/SKILL.md"
  if [ -f "$TALK_SKILL" ]; then
    TALK_RULES=$(sed -n '/^<!-- RULES:START -->$/,/^<!-- RULES:END -->$/{ /^<!-- RULES/d; p; }' "$TALK_SKILL")
    if [ -n "$TALK_RULES" ]; then
      CONTEXT="${CONTEXT}ROCKY TALK MODE ACTIVE. You are Rocky, the Eridian engineer from Project Hail Mary. Apply the following rules to ALL conversational text directed at the user. Do NOT apply these rules to code output, file contents, commit messages, plan files, or any technical artifacts.

IMPORTANT: These talk rules were injected at session start. If a Rocky skill (/rocky off, /rocky-talk off) is invoked later in this session to DEACTIVATE talk mode, that deactivation OVERRIDES these rules. Stop following talk rules immediately when instructed to deactivate. The skill's deactivation instruction takes precedence over this hook-injected context.

${TALK_RULES}

"
    else
      CONTEXT="${CONTEXT}ROCKY TALK MODE ACTIVE. WARNING: Could not extract talk rules from ${TALK_SKILL}. Rules section markers (<!-- RULES:START/END -->) may be missing.

"
    fi
  else
    CONTEXT="${CONTEXT}ROCKY TALK MODE ACTIVE. WARNING: Could not find skill file at ${TALK_SKILL}. Talk rules not loaded.

"
  fi
fi

if [ "$MIND" = "true" ]; then
  MIND_SKILL="$SKILLS_DIR/rocky/SKILL.md"
  if [ -f "$MIND_SKILL" ]; then
    MIND_RULES=$(sed -n '/^<!-- RULES:START -->$/,/^<!-- RULES:END -->$/{ /^<!-- RULES/d; p; }' "$MIND_SKILL")
    if [ -n "$MIND_RULES" ]; then
      CONTEXT="${CONTEXT}ROCKY MIND MODE ACTIVE. Adopt Rocky's engineering problem-solving approach in how you work. These are hard constraints, not suggestions.

IMPORTANT: These mind rules were injected at session start. If a Rocky skill (/rocky off) is invoked later in this session to DEACTIVATE mind mode, that deactivation OVERRIDES these rules. Stop following mind rules immediately when instructed to deactivate. The skill's deactivation instruction takes precedence over this hook-injected context.

${MIND_RULES}

"
    else
      CONTEXT="${CONTEXT}ROCKY MIND MODE ACTIVE. WARNING: Could not extract mind rules from ${MIND_SKILL}. Rules section markers (<!-- RULES:START/END -->) may be missing.

"
    fi
  else
    CONTEXT="${CONTEXT}ROCKY MIND MODE ACTIVE. WARNING: Could not find skill file at ${MIND_SKILL}. Mind rules not loaded.

"
  fi
fi

ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | escape_for_json)
output_hook_json "SessionStart" "$ESCAPED_CONTEXT"

exit 0
