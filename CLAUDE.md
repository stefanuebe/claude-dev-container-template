# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **devcontainer template** for running Claude Code in an isolated Docker environment. It is not a standalone application — it provides the infrastructure (Dockerfile, devcontainer config, MCP servers, helper scripts) that other projects fork or copy to get a pre-configured Claude Code development environment.

The container runs as the `node` user with full sudo access and no firewall restrictions (privileged mode).

## Environment

- **Runtime:** Node.js 20 (base image), Java 25 (OpenJDK), Maven 3.9.9
- **Shell:** zsh (default), bash available
- **Browser automation:** Playwright with Chromium pre-installed
- **Working directory:** `/workspace`
- **User:** `node` (non-root, passwordless sudo)

## MCP Servers

Three MCP servers are configured in `.mcp.json`:
- **vaadin** — Vaadin framework documentation search
- **playwright** — Browser automation via `@playwright/mcp`
- **vaadin-directory** — Vaadin addon/component directory search

## Test Server Scripts

Use these scripts when testing a Spring Boot application locally. They are pre-approved in `.claude/settings.local.json`.

| Script | Purpose |
|---|---|
| `./server-start.sh` | Starts Spring Boot on port 8081 (kills existing, waits 25s for startup) |
| `./server-stop.sh` | Stops server by PID file or process name |
| `./print-server-logs.sh` | Shows last 500 lines; `-f` for follow mode; `-state` for state-related lines |

Logs are written to `/tmp/claude-server.log`, PID stored in `/tmp/claude-server.pid`.

## Build Commands

These use Maven directly (no wrapper in this template repo, but `./mvnw` is expected in projects using this template):

```bash
mvn compile                          # Compile
mvn clean install                    # Full build
mvn test                             # Unit tests
mvn spring-boot:run                  # Run app (prefer server-start.sh instead)
./mvnw spotless:apply                # Format code
./mvnw verify                        # Full verification
./mvnw failsafe:integration-test     # Integration tests
npx playwright test                  # Playwright browser tests
```

## Key Files

- `.devcontainer/Dockerfile` — Container image definition (Java, Maven, Playwright, Claude Code)
- `.devcontainer/devcontainer.json` — Devcontainer config (mounts, env vars, extensions, runtime args)
- `.mcp.json` — MCP server definitions
- `.claude/settings.local.json` — Pre-approved commands and MCP permissions
- `CLAUDE_CONTAINER_README.md` — User-facing documentation (used instead of README.md to avoid conflicts when forking)

## File Sharing

The host's `~/.claude_transfer` is mounted read-only at `~/transfer` inside the container. Use this to share screenshots or other files with Claude when clipboard paste doesn't work reliably in the devcontainer.
