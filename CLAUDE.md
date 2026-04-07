# Rocky — Claude Code Plugin

A Claude Code personality plugin that makes Claude talk and think like Rocky, the Eridian engineer from *Project Hail Mary*. Two modes: **Talk** (communication style only) and **Full** (talk + engineering mind together).

## Architecture

Rocky works through a **self-contained skills** design:

- **Talk skill** (`skills/rocky-talk/SKILL.md`) — contains toggle logic AND full talk rules inline. Single source of truth for talk rules.
- **Full skill** (`skills/rocky/SKILL.md`) — contains toggle logic AND full mind rules inline. Delegates to `/rocky-talk` for talk rules. Single source of truth for mind rules.
- **Buddy skill** (`skills/rocky-buddy/SKILL.md`) — ASCII art terminal companion that appears on `SessionStart`. Independent from talk and mind modes.
- **SessionStart hook** (`hooks-handlers/session-start.sh`) — reads state from `~/.claude/rocky-state.json` and extracts rules from the skill files (via `<!-- RULES:START/END -->` delimiters) to inject as `additionalContext`. This is the persistence layer.

The hook handles persistence across sessions; the skills handle in-session toggling; the SKILL.md files are the single source of truth.

## Key Design Rules

1. **Single source of truth** — Talk rules live in `skills/rocky-talk/SKILL.md`. Mind rules live in `skills/rocky/SKILL.md`. Both between `<!-- RULES:START -->` and `<!-- RULES:END -->` markers. The hook extracts from these same files. Never duplicate rules elsewhere.
2. **Conversational text only** — Rocky personality applies only to conversational text. Code output, file contents, commit messages, and plan files always stay in standard English.
3. **Self-contained skills** — Each skill includes everything an agent needs. No runtime file reads required. Cross-agent compatible.

## File Map

| File | Purpose |
|------|---------|
| `skills/rocky-talk/SKILL.md` | **CANONICAL** — Talk toggle + inline talk rules (single source of truth for talk) |
| `skills/rocky/SKILL.md` | **CANONICAL** — Full mode toggle + inline mind rules (single source of truth for mind) |
| `skills/rocky-buddy/SKILL.md` | Buddy toggle — ASCII art companion on SessionStart |
| `skills/rocky-buddy/companion.txt` | Rocky ASCII art |
| `skills/rocky-buddy/rocky-buddy.sh` | Buddy state toggle handler |
| `skills/rocky-status/SKILL.md` | `/rocky-status` — show current state |
| `hooks-handlers/session-start.sh` | Engine — reads state, extracts rules from SKILL.md files, injects context |
| `hooks-handlers/rocky-buddy.sh` | Buddy display handler — fires on SessionStart when buddy is enabled |
| `hooks/hooks.json` | Registers the SessionStart hook (personality + buddy) |
| `.claude-plugin/plugin.json` | Plugin manifest (name, version, author) |

## Editing Rules

To change Rocky's personality, edit the rules section in the skill files:

- Talk style → edit rules between `<!-- RULES:START/END -->` in `skills/rocky-talk/SKILL.md`
- Engineering mindset → edit rules between `<!-- RULES:START/END -->` in `skills/rocky/SKILL.md`

No propagation needed. The hook extracts from these same files via the delimiter markers.

## State File

State is stored globally at `~/.claude/rocky-state.json`:

```json
{ "talk": false, "mind": false, "buddy": false }
```

Defaults to both `false` if the file is missing. Parsed using `python3` in the hook (Claude Code will prompt to allow this on first run — approve it).

## Testing Changes

Skills (`SKILL.md`) take effect immediately on next invocation. Hook changes (`session-start.sh`) require a **new Claude Code session** to take effect.

To test end-to-end:
1. Enable a mode: `/rocky-talk on`
2. Start a new session to verify the hook injects the rule correctly
3. Check `/rocky-status` shows expected state
4. Verify conversational responses match Rocky style but code output remains normal English

To test buddy:
1. `/rocky-buddy on`
2. Start a new session — Rocky ASCII art + greeting should appear via `additionalContext`
3. `/rocky-buddy off` — no ASCII art on next session start
