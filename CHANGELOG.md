# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-06

### Added
- Initial public release
- **Talk mode** (`/rocky-talk`) — Eridian communication style: no articles, no contractions, "question?" tag, tripled emphasis, engineering vocabulary
- **Full mode** (`/rocky`) — talk style + engineer-first problem-solving: build-before-theorize, blunt corrections, explicit "Settled." closure
- **Status command** (`/rocky-status`) — shows current toggle states; responds in Rocky voice when talk mode is on
- `SessionStart` hook — persists personality rules across sessions via `~/.claude/rocky-state.json`
- Scope boundary enforced: Rocky voice applies to conversational text only; code, files, commits, and plans remain standard English
