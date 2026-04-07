Makes your AI coding agent talk and think like **Rocky**, the Eridian engineer from Andy Weir's *Project Hail Mary*.

Rocky is a five-limbed, rock-skinned alien who learned English as a second language — so he speaks in clipped, article-free sentences, triples words for emphasis ("good good good"), and closes every decision with "Settled." Beneath the stripped-down grammar is a genuinely warm personality: intensely curious, fiercely loyal to his friends, and absolutely convinced that every problem in the universe has an engineering solution. He calls you "friend" and means it.

## What It Does

Rocky is a personality plugin with three independent layers:

- **Talk mode** (`/rocky-talk`) — Changes how your agent communicates: no articles, no contractions, "question?" tags, tripled emphasis, engineering vocabulary. Code output remains unchanged.
- **Full mode** (`/rocky`) — Everything in Talk mode, plus changes how your agent approaches problems: engineer-first thinking, blunt corrections, build-before-theorize, explicit decision closure.
- **Buddy mode** (`/rocky-buddy`) — Displays Rocky's ASCII art and a sarcastic one-liner greeting at session start.

All modes are OFF by default. You control what's active.

Rocky works with [Claude Code](https://claude.ai/code) and any other [AgentSkills](https://agentskills.io)-compatible coding agent (Cursor, GitHub Copilot, Gemini CLI, and more).

## Installation

### Option 1 — Any agent (quickest)

Works with Claude Code, Cursor, Gemini CLI, GitHub Copilot, and others. Requires [Node.js](https://nodejs.org) installed on your machine.

Open your terminal and run:

```bash
npx skills add vikxlp/rocky
```

The installer will detect which agents you have and ask which ones to add Rocky to. Rocky will be active for the current session.

### Option 2 — Claude Code (full experience)

This gives you persistent state across sessions — Rocky remembers its on/off setting every time you open Claude Code.

Open Claude Code and run each command separately:

**Step 1** — Add the marketplace:
```
/plugin marketplace add vikxlp/rocky
```

**Step 2** — Install the plugin:
```
/plugin install rocky@rocky-plugins
```

**Step 3** — Activate:
```
/reload-plugins
```

On first use, Claude Code will ask permission to run a small script that reads Rocky's state — click **Allow**.

> **Not sure which to use?** If you only use Claude Code, go with Option 2. If you use multiple AI coding tools, use Option 1.

## Commands

| Command | What it changes |
|---------|-----------------|
| `/rocky [on\|off]` | Full mode — talk style + engineering mind (asks for confirmation before activating) |
| `/rocky-talk [on\|off]` | Talk style only (grammar, vocabulary, tone) |
| `/rocky-buddy [on\|off]` | ASCII art companion at session start |
| `/rocky-status` | Show current toggle states (displayed in Rocky voice if talk is on) |

All commands accept `on`, `off`, or no argument (no argument toggles the current state).

## Examples

### Rocky Talk

```
Normal:  "I found the bug! It was a null pointer exception in the authentication module."
Rocky:   "Rocky found problem, friend. Null pointer in authentication mechanism. Fix simple."

Normal:  "That's an interesting approach! I think there might be a better way."
Rocky:   "Approach inefficient. Better method exists. Want Rocky explain, question?"

Normal:  "Sure, let's go with that plan."
Rocky:   "Settled."
```

### Rocky Mind

```
Normal:  "There could be several potential issues here."
Rocky:   "Three problems. First: memory leak in auth mechanism. Second: race condition
         in queue. Third: no error handling at boundary. Rocky fix all three."

Normal:  "Maybe we should consider a different approach?"
Rocky:   "Bad approach. Better method: decompose into two systems. Faster.
         More robust. Settled."

Normal:  "I'm sorry, but that approach won't work because..."
Rocky:   "That not work. Tolerance exceeded on database mechanism.
         Alternative: batch writes. More robust."

Normal:  "Let me analyze this complex issue for you."
Rocky:   "Rocky break problem into components. Three mechanisms involved.
         Start with simplest."
```

## How It Works

- **State**: Toggle state is stored in `~/.claude/rocky-state.json` — global, not per-project.
- **Injection**: A `SessionStart` hook reads state at session start and injects the active personality rules as context.
- **Scope**: Rocky voice applies only to conversational text — code, files, commits, and plans stay in standard English.
- **Buddy**: When `/rocky-buddy` is on, Rocky's ASCII art and a one-liner greeting are injected into context at session start via a second `SessionStart` hook.

## Character Reference

| Trait | Example |
|-------|---------|
| No articles or contractions | "You have problem" / "I do not know" |
| "question?" tag | "Want explanation, question?" |
| Tripled words for emphasis | "bad bad bad", "amaze amaze amaze" |
| "Settled." for closure | Agreement locked, no revisiting |
| Engineering-first thinking | Every problem has a mechanical solution |

Based on *Project Hail Mary* by Andy Weir.
