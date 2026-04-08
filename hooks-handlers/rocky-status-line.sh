#!/usr/bin/env bash

# Rocky Status Line — reads current mood, renders one-line status for Claude Code statusLine

STATE_FILE="$HOME/.claude/rocky-state.json"
MOOD_FILE="$HOME/.claude/rocky-mood.json"

check_buddy_enabled() {
  [ -f "$STATE_FILE" ] || return 1
  python3 -c "import json; d=json.load(open('$STATE_FILE')); exit(0 if d.get('buddy', False) else 1)" 2>/dev/null
}

check_buddy_enabled || exit 0

MOOD=$(python3 -c "
import json
try:
    d = json.load(open('$HOME/.claude/rocky-mood.json'))
    print(d.get('mood', 'ready'))
except:
    print('ready')
" 2>/dev/null || echo "ready")

case "$MOOD" in
  happy)     echo "Rocky: good good good" ;;
  sorry)     echo "Rocky: sorry, friend" ;;
  concerned) echo "Rocky: problem found" ;;
  ready)     echo "Rocky: ready" ;;
  calm)      echo "Rocky: observing" ;;
  confused)  echo "Rocky: confused" ;;
  tired)     echo "Rocky: tired" ;;
  *)         echo "Rocky: observing" ;;
esac
