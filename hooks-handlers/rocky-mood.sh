#!/usr/bin/env bash

# Rocky Mood Detector — PostToolUse and Stop hook handler
# Updates ~/.claude/rocky-mood.json based on tool results (tool) or transcript (stop)

EVENT_TYPE="${1:-stop}"
STATE_FILE="$HOME/.claude/rocky-state.json"
MOOD_FILE="$HOME/.claude/rocky-mood.json"

check_buddy_enabled() {
  [ -f "$STATE_FILE" ] || return 1
  python3 -c "import json; d=json.load(open('$STATE_FILE')); exit(0 if d.get('buddy', False) else 1)" 2>/dev/null
}

check_buddy_enabled || exit 0

if [ "$EVENT_TYPE" = "tool" ]; then
  MOOD=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if not data.get('tool_success', True):
        print('concerned')
    else:
        print('calm')
except:
    print('calm')
" 2>/dev/null || echo "calm")
else
  # Stop: detect mood from last assistant message in transcript
  MOOD=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    messages = data.get('messages', [])
    last_text = ''
    for m in reversed(messages):
        if m.get('role') == 'assistant':
            content = m.get('content', '')
            if isinstance(content, list):
                for block in content:
                    if isinstance(block, dict) and block.get('type') == 'text':
                        last_text += block.get('text', '')
            elif isinstance(content, str):
                last_text = content
            break
    text = last_text.lower()
    if any(w in text for w in ['sorry', 'apologize', 'regret', 'mistake']):
        print('sorry')
    elif any(w in text for w in ['error', 'fail', 'broken', 'bug', 'wrong', 'issue']):
        print('concerned')
    elif any(w in text for w in ['done', 'complete', 'finished', 'success', 'accomplished']):
        print('happy')
    elif any(w in text for w in ['plan', 'approach', 'strategy', 'will try', 'let me']):
        print('ready')
    else:
        print('calm')
except:
    print('calm')
" 2>/dev/null || echo "calm")
fi

python3 -c "import json; json.dump({'mood': '$MOOD'}, open('$HOME/.claude/rocky-mood.json', 'w'))" 2>/dev/null
exit 0
