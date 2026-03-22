# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

one-click-claw is a Windows one-click installer for [OpenClaw](https://www.npmjs.com/package/openclaw), an AI assistant platform. It sets up a complete OpenClaw environment inside WSL2 so non-technical users can double-click a `.bat` file and get a working AI assistant with Telegram and web UI access. The README and all user-facing text are in Traditional Chinese.

## Architecture

The installer is a three-stage pipeline:

1. **`windows/START-HERE.bat`** - Entry point. Requests admin elevation, unblocks downloaded files, launches the PowerShell installer.

2. **`windows/install-openclaw.ps1`** - Windows-side orchestrator (PowerShell, requires admin). Runs 5 sequential steps:
   - Installs/verifies WSL2
   - Creates an `openclaw` WSL distro from Ubuntu 24.04 with a default user (`openclaw`/`openclaw`)
   - Writes `.wslconfig` (memory limits, systemd)
   - Registers a Windows Scheduled Task (`OpenClaw-WSL-Gateway`) for auto-start on login
   - Copies and executes the bash setup script inside WSL

3. **`windows/setup-openclaw.sh`** - Linux-side setup (runs inside the WSL distro). Interactively collects Gemini API Key and Telegram Bot Token, then:
   - Installs Node.js 22 via NodeSource
   - Installs `openclaw` npm package globally (to `~/.npm-global`)
   - Writes config to `~/.openclaw/openclaw.json`
   - Sets up a cron-based keepalive (`keepalive.sh` every 5 min)
   - Starts the gateway and prints onboarding instructions

## Development Notes

- There is no build step, test suite, or linter. The project is pure shell scripts (bat/ps1/sh).
- To test changes, run the installer on a Windows machine with WSL2 support. The distro name is `openclaw`.
- The PowerShell script checks for the distro via the Windows registry at `HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss`.
- OpenClaw runs on `http://localhost:18789` (web UI) with `localhostForwarding=true` in `.wslconfig`.
