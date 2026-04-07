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

**Claude Code**: Update `~/.claude/rocky-state.json` with the new buddy value (preserve talk and mind values).

**If buddy is now ON:**
- Respond: "Rocky buddy active. Rocky here now, friend."
- Rocky ASCII art + speech bubble will appear in terminal
- Works with SessionStart hook to display buddy on session begin
- Works with event hooks (PlanReady, TaskCompleted, ErrorOccurred) to show buddy reactions
- Works with MessageOutput hook (if enabled) to show buddy on every message

**If buddy is now OFF:**
- Respond: "Rocky buddy deactivated. Companion hidden."
- Terminal displays return to normal
- No ASCII art shown

---

## What Rocky Buddy Does

When enabled:
- **SessionStart** → Rocky greets you when session begins
- **TaskCompleted** → Rocky celebrates task completion
- **PostToolUse** (ExitPlanMode) → Rocky reacts when plan is approved
- **PostToolUseFailure** → Rocky analyzes tool failures

Format:
```
Rocky: Rocky's observation here
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

Rocky buddy is independent from rocky-talk and rocky:
- `/rocky-buddy on` → See Rocky ASCII art (messages stay normal English)
- `/rocky-talk on` → Messages use Rocky speech (may or may not show buddy)
- `/rocky on` → Problem-solving uses Rocky approach (may or may not show buddy)

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

**All Rocky buddy displays MUST follow this exact format. No exceptions. No variations.**

```
Rocky: [one-liner message]
      ___
   __/°  \__
  / _     _ \
 / //\___/ \ \
/ / \\   \\ \ \
\ \  \>  </ / /
 \_>       <_/
```

### Rules

✓ **ALWAYS:**
- Start with "Rocky: " (colon + space)
- Message on first line only
- ASCII art on following 7 lines
- Consistent across all events
- Consistent across all displays

✗ **NEVER:**
- Use speech bubble borders (┌─┐│└─┘)
- Wrap message inside ASCII art
- Place message and art side-by-side
- Use alternative ASCII variants
- Deviate from this exact format
- Add decorations or modifications

### Consistency

Same format for:
- SessionStart events
- PlanReady events
- TaskCompleted events
- ErrorOccurred events
- MessageOutput events
- All other displays

No exceptions. Ever. Settled.
