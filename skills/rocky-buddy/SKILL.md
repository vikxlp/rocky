---
name: rocky-buddy
description: Activate or deactivate Rocky's terminal buddy — ASCII art companion that appears in terminal when enabled. Use when the user says /rocky-buddy, "turn on Rocky buddy", "show Rocky", or "turn off Rocky buddy". Visual representation of Rocky's presence.
license: MIT
compatibility: Skills directory works with any AgentSkills-compatible agent. State persistence across sessions requires Claude Code; other agents apply rules for the current session only.
metadata:
  author: inosaint
  version: "1.1.0"
allowed-tools: Bash Read
---

# Rocky Buddy — Terminal Companion Toggle

Activate or deactivate Rocky's terminal buddy. When enabled, Rocky's ASCII art and speech bubble appear in terminal on SessionStart and specific events.

## Instructions

### 1. Determine current state

**Claude Code**: Read `~/.claude/rocky-state.json` using Bash. If it does not exist, assume `{"talk": false, "mind": false, "buddy": false}`.

**Other agents**: Assume buddy mode is OFF unless already activated this session.

### 2. Determine action

Parse the user's request:
- "on" or explicit activation → set buddy to ON
- "off" or explicit deactivation → set buddy to OFF
- No argument / toggle → flip current buddy value

### 3. Apply state

**Claude Code**: Update `~/.claude/rocky-state.json` with the new buddy value (preserve talk and mind values). The Bash command must ONLY write the state file — do NOT cat or read any art files in the same command.

**If buddy is now ON:**
- After writing state, respond using the Rocky buddy display format (one-liner + ASCII art) in your text response. Use `variant-ready.txt` content. No separate confirmation text. One-liner - "Rocky here. Ready to work, friend."

**If buddy is now OFF:**
- Respond with plain text only (no Rocky style, no art): "Rocky buddy deactivated."
- Terminal displays return to normal
- No ASCII art shown

---

## What Rocky Buddy Does

When enabled:
- **SessionStart** → Rocky greets you when session begins (`variant-ready.txt`)
- **PostToolUse** (ExitPlanMode) → Rocky reacts when you approve a plan (`variant-calm.txt`)
- **TaskCompleted** → Rocky celebrates task completion (`variant-calm.txt`)
- **PostToolUseFailure** → Rocky analyzes errors found (`variant-concerned.txt`)

Format:
```
Rocky's observation here
      ___
   __/°  \__
  / _     _ \
 / //\___/ \ \
/ / \\   \\ \ \
\ \  \>  </ / /
 \_>       <_/
```

---

## Independence

Rocky buddy is independent from rocky-talk and rocky-mind:
- `/rocky-buddy on` → See Rocky ASCII art (messages stay normal English)
- `/rocky-talk on` → Messages use Rocky speech (may or may not show buddy)
- `/rocky-mind on` → Problem-solving uses Rocky approach (may or may not show buddy)

All three can be toggled independently for different experiences.

---

## Character Voice

Rocky buddy one-liners use Rocky's Eridian talk style. Voice rules are defined in the sibling skill `skills/rocky-talk/SKILL.md`.

**When displaying buddy:**
1. Invoke `/rocky-talk` to apply Rocky's full talk rules to the one-liner message
2. Compose a brief one-liner following those rules (under 10 words, fragment preferred)

**Fallback** (if skill-to-skill invocation is not supported):
Read `skills/rocky-talk/SKILL.md` and apply the rules between the `<!-- RULES:START -->` and `<!-- RULES:END -->` markers to the buddy one-liner.

Examples:
- "Plan good good good. Now do work."
- "Problem found. Debug and fix."
- "Task finished. Excellent work, friend."
- "Rocky here. Ready to work, friend."

---

## Display Format Rules — CRITICAL

**All Rocky buddy displays MUST follow this exact format.**

```
Rocky: [one-liner message]
[ASCII variant art]
```

### Variant Mapping

Each hook event uses a specific ASCII variant from `skills/rocky-buddy/`:

| Event | Variant file | Lines |
|-------|-------------|-------|
| SessionStart | `variant-ready.txt` | 5 |
| TaskCompleted | `variant-calm.txt` | 5 |
| PostToolUse (plan approval) | `variant-calm.txt` | 5 |
| PostToolUseFailure | `variant-concerned.txt` | 5 |
| fallback / unknown | `companion.txt` | 7 |

### Rules

✓ **ALWAYS:**
- Start with "Rocky: " (colon + space)
- Message on first line only
- ASCII art on following lines (5 for variants, 7 for companion.txt)
- Use the correct variant for the event type

✗ **NEVER:**
- Use speech bubble borders (┌─┐│└─┘)
- Wrap message inside ASCII art
- Place message and art side-by-side
- Add decorations or modifications

### Consistency

Same format for all events — only the variant art differs:
- SessionStart → ready
- PostToolUse (plan) → calm
- TaskCompleted → calm
- PostToolUseFailure → concerned
- Unknown → companion.txt fallback
