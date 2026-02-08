# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **devcontainer template** for running Claude Code in an isolated Docker environment. It is not a standalone application — it provides the infrastructure (Dockerfile, devcontainer config, MCP servers, helper scripts, custom agents) that other projects fork or copy to get a pre-configured Claude Code development environment.

The container runs as the `node` user with full sudo access (privileged mode, `--shm-size=8g`).

## Environment

- **Runtime:** Node.js 20 (base image), Java 25 (OpenJDK 25.0.2), Maven 3.9.9
- **Shell:** zsh (default, with oh-my-zsh + powerlevel10k), bash available
- **Browser automation:** Playwright with Chromium pre-installed
- **Working directory:** `/workspace`
- **User:** `node` (non-root, passwordless sudo)
- **Editors:** nano (default `$EDITOR`), vim also available

## MCP Servers

Three MCP servers are configured in `.mcp.json`:
- **vaadin** — Vaadin framework documentation search (HTTP, `mcp.vaadin.com`)
- **playwright** — Browser automation via `@playwright/mcp@latest`
- **vaadin-directory** — Vaadin addon/component directory search (HTTP, `vaadin.com/directory/mcp`)

Note: `vaadin-directory` is defined in `.mcp.json` but not listed in `enabledMcpjsonServers` in `.claude/settings.local.json`. It requires manual approval or adding to the enabled list.

## Custom Agents

Twelve custom agents are defined in `.claude/agents/`:

| Agent | Purpose | When to use |
|-------|---------|-------------|
| **agents-manager** | Discovers tech stack, injects project-specific patterns into all other agents | On `/init`, after CLAUDE.md changes, or when switching projects |
| **architecture-guard** | Checks structural compliance, import violations, module boundaries | After adding new classes or refactoring |
| **code-reviewer** | Fast code review of a diff (no builds/tests) | DURING development for quick feedback |
| **dependency-auditor** | Audits dependencies for CVEs, outdated versions, license issues | Periodically or before releases |
| **devcontainer-auditor** | Audits devcontainer setup: Dockerfiles, devcontainer.json, compose, infrastructure | When container setup changes |
| **housekeeper** | Keeps CLAUDE.md accurate, cleans up temp files and processes | Before committing or after larger changes |
| **migration-auditor** | Audits database migrations for safety | Before committing new migrations |
| **performance-auditor** | Static analysis for N+1 queries, memory leaks, rendering issues | When performance is a concern |
| **qa-tester** | Full QA: code review + build + tests + responsive checks | BEFORE committing (comprehensive) |
| **requirements-reviewer** | Reviews feature requirements and implementation plans | BEFORE implementing |
| **security-reviewer** | Deep security review: auth, access control, injection, secrets, HTTP headers | For security-sensitive changes |
| **ui-explorer** | Live browser-based visual testing via Playwright | To verify visual changes at both viewports |

**Important agent relationships:**
- `code-reviewer` and `qa-tester` are mutually exclusive — do not run both on the same changes
- `agents-manager` should be run on first project setup to populate project-specific sections in all other agents; also supports a "review mode" (when explicitly asked) to propose agent additions/removals

## Test Server Scripts

Use these scripts when testing a Spring Boot application locally. They are pre-approved in `.claude/settings.local.json`.

| Script | Purpose |
|---|---|
| `./server-start.sh` | Starts Spring Boot on port 8081 (kills existing, waits 25s for startup, uses `./mvnw`) |
| `./server-stop.sh` | Stops server by PID file or process name |
| `./print-server-logs.sh` | Shows last 500 lines; `-f` for follow mode; `-state` for state-related lines |

Logs are written to `/tmp/claude-server.log`, PID stored in `/tmp/claude-server.pid`.

## Build Commands

This template repo has no application code. These commands apply to **projects that fork this template**. Forked projects should use the Maven wrapper (`./mvnw`); bare `mvn` is available as fallback.

```bash
./mvnw compile                       # Compile
./mvnw clean install                 # Full build
./mvnw test                          # Unit tests
./mvnw spotless:apply                # Format code (auto-fix)
./mvnw spotless:check                # Format check (verify-only, no changes)
./mvnw verify                        # Full verification
./mvnw failsafe:integration-test     # Integration tests
npx playwright test                  # Playwright browser tests
./server-start.sh                    # Run app (preferred over mvnw spring-boot:run)
```

## Key Files

- `.devcontainer/Dockerfile` — Container image definition (Java, Maven, Playwright, Claude Code)
- `.devcontainer/devcontainer.json` — Devcontainer config (mounts, env vars, extensions, privileged mode)
- `.devcontainer/init-firewall.sh` — Optional iptables firewall script (whitelist-based, blocks non-essential outbound traffic)
- `.mcp.json` — MCP server definitions
- `.claude/settings.local.json` — Pre-approved commands and MCP permissions
- `.claude/agents/` — Custom agent definitions (see Custom Agents section)

## Container Mounts

Defined in `.devcontainer/devcontainer.json`:

| Mount | Target | Type | Purpose |
|-------|--------|------|---------|
| Named volume | `/commandhistory` | volume | Persists shell history across rebuilds |
| Named volume | `/home/node/.claude` | volume | Persists Claude Code config across rebuilds |
| `~/.vaadin` | `/home/node/.vaadin` | bind, readonly | Shares Vaadin config/license from host |
| `~/.claude_transfer` | `/home/node/transfer` | bind, readonly | File sharing when clipboard paste is unreliable |
| Workspace folder | `/workspace` | bind | The project source code |

## File Sharing

The host's `~/.claude_transfer` is mounted read-only at `~/transfer` inside the container. Use this to share screenshots or other files with Claude when clipboard paste doesn't work reliably in the devcontainer.
