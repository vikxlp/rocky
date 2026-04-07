#!/usr/bin/env bash

# Rocky Buddy — Toggle terminal companion display
# Manages buddy state in ~/.claude/rocky-state.json

STATE_FILE="$HOME/.claude/rocky-state.json"
ACTION="${1:-toggle}"

# Determine current state
TALK=false
MIND=false
BUDDY=false

if [ -f "$STATE_FILE" ]; then
  TALK=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(str(d.get('talk', False)).lower())" 2>/dev/null || echo "false")
  MIND=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(str(d.get('mind', False)).lower())" 2>/dev/null || echo "false")
  BUDDY=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(str(d.get('buddy', False)).lower())" 2>/dev/null || echo "false")
fi

# Determine new buddy state based on action
case "$ACTION" in
  on|true|enable|activate)
    BUDDY="true"
    ;;
  off|false|disable|deactivate)
    BUDDY="false"
    ;;
  toggle|*)
    if [ "$BUDDY" = "true" ]; then
      BUDDY="false"
    else
      BUDDY="true"
    fi
    ;;
esac

# Update state file
BUDDY_PYTHON=$([ "$BUDDY" = "true" ] && echo "True" || echo "False")

python3 << EOF
import json
import os

state_file = os.path.expanduser("~/.claude/rocky-state.json")

# Read existing state or create new
if os.path.exists(state_file):
  with open(state_file, 'r') as f:
    state = json.load(f)
else:
  state = {}

# Update buddy value, preserve talk and mind
state['talk'] = state.get('talk', False)
state['mind'] = state.get('mind', False)
state['buddy'] = $BUDDY_PYTHON

# Write state back
with open(state_file, 'w') as f:
  json.dump(state, f)
  f.write("\n")
EOF

# Generate response
if [ "$BUDDY" = "true" ]; then
  cat << 'EOF'
Rocky buddy active. Rocky here now, friend.
EOF
else
  cat << 'EOF'
Rocky buddy deactivated. Companion hidden.
EOF
fi

exit 0
