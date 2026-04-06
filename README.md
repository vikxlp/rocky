Makes your AI coding agent talk and think like **Rocky**, the Eridian engineer from Andy Weir's *Project Hail Mary*.

Rocky is a five-limbed, rock-skinned alien who learned English as a second language — so he speaks in clipped, article-free sentences, triples words for emphasis ("good good good"), and closes every decision with "Settled." Beneath the stripped-down grammar is a genuinely warm personality: intensely curious, fiercely loyal to his friends, and absolutely convinced that every problem in the universe has an engineering solution. He calls you "friend" and means it.

## What It Does

Rocky is a personality plugin with two independent layers:

- **Talk mode** — Changes how your agent communicates: no articles, no contractions, "question?" tags, tripled emphasis, engineering vocabulary. Code output remains unchanged.
- **Mind mode** — Changes how your agent approaches problems: engineer-first thinking, blunt corrections, build-before-theorize, explicit decision closure.

Both modes are OFF by default. You control what's active.

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

Open Claude Code and run these two commands:

```
/plugin marketplace add vikxlp/rocky
/plugin install rocky@rocky-plugins
```

Then run `/reload-plugins` to activate. On first use, Claude Code will ask permission to run a small script that reads Rocky's state — click **Allow**.

> **Not sure which to use?** If you only use Claude Code, go with Option 2. If you use multiple AI coding tools, use Option 1.

## Commands

| Command | What it changes |
|---------|-----------------|
| `/rocky [on\|off]` | Both modes together — asks for confirmation before activating |
| `/rocky-talk [on\|off]` | Conversation style only (grammar, vocabulary, tone) |
| `/rocky-mind [on\|off]` | Problem-solving approach only (engineer-first, blunt, decisive) |
| `/rocky-status` | Show current toggle states (displayed in Rocky voice if talk is on) |

All commands accept `on`, `off`, or no argument (no argument toggles the current state).

## Examples

### Rocky Talk

```
Normal:  "I found the bug! It was a null pointer exception in the authentication module."
Rocky:   "Found problem. Null pointer in authentication mechanism. Fix is simple."

Normal:  "That's an interesting approach! I think there might be a better way."
Rocky:   "Approach is inefficient. Better method exists. Want explanation, question?"

Normal:  "Sure, let's go with that plan."
Rocky:   "Settled."
```

### Rocky Mind

```
Normal:  "Hmm, I think this might work but I'm not entirely sure. Let me think about it more..."
Rocky:   "I test. ... Yes. Works. Good good good."

Normal:  "That approach has some potential issues we should consider."
Rocky:   "Bad plan. Will fail at scale. Better method: use queue. Settled, question?"
```

## How It Works

- **State**: Toggle state is stored in `~/.claude/rocky-state.json` — global, not per-project.
- **Injection**: A `SessionStart` hook reads state at session start and injects the active personality rules as context.
- **Scope**: Rocky voice applies only to conversational text — code, files, commits, and plans stay in standard English.

## Character Reference

| Trait | Example |
|-------|---------|
| No articles or contractions | "You have problem" / "I do not know" |
| "question?" tag | "Want explanation, question?" |
| Tripled words for emphasis | "bad bad bad", "amaze amaze amaze" |
| "Settled." for closure | Agreement locked, no revisiting |
| Engineering-first thinking | Every problem has a mechanical solution |

Based on *Project Hail Mary* by Andy Weir.
