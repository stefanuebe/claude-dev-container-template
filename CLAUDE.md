# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **devcontainer template** for running Claude Code in an isolated Docker environment. It is not a standalone application — it provides the infrastructure (Dockerfile, devcontainer config, MCP servers, helper scripts, custom agents) that other projects fork or copy to get a pre-configured Claude Code development environment.

The container runs as the `node` user with full sudo access (privileged mode, `--shm-size=8g`).

The primary target for this template are projects written in Vaadin with Spring Boot, 
but it should also work for other types of projects. Don't be surprised, that there is no pom.xml or any other
prebuilt Java/Vaadin structure. That will be added, when the specific project is created or modified.

If you are not building a Vaadin project, you may need to modify the agents.

## Environment

- **Runtime:** Node.js 20 (base image), Java 25 (OpenJDK 25.0.2), Maven 3.9.9
- **Techstack** Vaadin 25+, Spring Boot 4+
- **Shell:** zsh (default, with oh-my-zsh + powerlevel10k), bash available
- **Browser automation:** Playwright with Chromium pre-installed
- **Working directory:** `/workspace`
- **User:** `node` (non-root, passwordless sudo)
- **Editors:** nano (default `$EDITOR`), vim also available

## MCP Servers

Two MCP servers are configured in `.mcp.json` (both enabled via `enableAllProjectMcpServers` in settings):
- **vaadin** — Vaadin framework documentation search (HTTP, `mcp.vaadin.com`)
- **playwright** — Browser automation via `@playwright/mcp@latest`

## Task Delegation

**When you receive a non-trivial task, always delegate it to the `agents-manager` first.** The agents-manager knows all available custom agents and will assign the best-fitting one (or handle it itself). You do not need to know which agent to pick — just pass the task to the agents-manager and let it decide. This applies to any task that could plausibly be handled by a specialized agent (code review, testing, security checks, UI work, full-stack features, audits, etc.).

Only skip delegation when the task is clearly outside all agents' scope (e.g. a simple factual question, a one-line edit you can do directly, or an explicit user instruction to act yourself).

## Custom Agents

Fourteen custom agents are defined in `.claude/agents/`:

| Agent | Purpose | When to use |
|-------|---------|-------------|
| **agents-manager** | **Primary task router.** Assigns tasks to the best-fitting agent. Also discovers tech stack and injects project-specific patterns (update mode), or reviews the agent suite (review mode). | **For every non-trivial task** (default). Also on `/init`, after CLAUDE.md changes, or when switching projects. |
| **architecture-guard** | Checks structural compliance, import violations, module boundaries | After adding new classes or refactoring |
| **code-reviewer** | Fast code review of a diff (no builds/tests) | DURING development for quick feedback |
| **dependency-auditor** | Audits dependencies for CVEs, outdated versions, license issues | Periodically or before releases |
| **devcontainer-auditor** | Audits devcontainer setup: Dockerfiles, devcontainer.json, compose, infrastructure | When container setup changes |
| **fullstack-developer** | End-to-end feature development spanning backend and frontend (entities, services, APIs, UI) | When implementing complete features across all layers |
| **housekeeper** | Keeps CLAUDE.md accurate, cleans up temp files and processes | Before committing or after larger changes |
| **migration-auditor** | Audits database migrations for safety | Before committing new migrations |
| **performance-auditor** | Static analysis for N+1 queries, memory leaks, rendering issues | When performance is a concern |
| **qa-tester** | Full QA: code review + build + tests + responsive checks | BEFORE committing (comprehensive) |
| **requirements-reviewer** | Reviews feature requirements and implementation plans | BEFORE implementing |
| **security-reviewer** | Deep security review: auth, access control, injection, secrets, HTTP headers | For security-sensitive changes |
| **ui-designer** | Reviews UI design decisions, visual consistency, accessibility, responsive layouts | After creating or modifying UI components/views |
| **ui-explorer** | Live browser-based visual testing via Playwright | To verify visual changes at both viewports |

**Important agent relationships:**
- `agents-manager` is the **default entry point** for all non-trivial tasks — delegate to it and let it pick the right agent
- `code-reviewer` and `qa-tester` are mutually exclusive — do not run both on the same changes
- `agents-manager` should also be run on first project setup (update mode) to populate project-specific sections in all other agents; supports a "review mode" (when explicitly asked) to propose agent additions/removals

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

