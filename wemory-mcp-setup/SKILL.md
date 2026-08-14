---
name: wemory-mcp-setup
description: Configure the local Wemory HTTP MCP service for Codex or WorkBuddy on Windows. Use when a user asks to install, connect, verify, repair, or update Wemory MCP, or wants an AI client to access Wemory chat context, contacts, media, or moments through MCP.
---

# Wemory MCP Setup

Configure client-side MCP settings for the Wemory desktop application. Wemory is the MCP server; this skill only discovers its local connection, writes client configuration after confirmation, and verifies the connection.

## Safety rules

- Do not start Wemory, elevate privileges, change firewall rules, expose `0.0.0.0`, or create a public tunnel.
- Do not print, commit, or log the Wemory MCP token.
- Never overwrite an existing Codex or WorkBuddy configuration without creating a timestamped backup.
- Show the planned target path and ask for confirmation before using `-Apply`.
- Preserve every existing MCP server and unrelated configuration entry.
- Stop with a clear error if Wemory is not running, MCP is disabled, the host is not loopback, or the configured port is `0`.

## Workflow

1. Run `scripts/detect-wemory.ps1` from this skill directory.
2. Confirm that `ready` is `true`. If not, ask the user to open Wemory, enable Settings → AI tools → MCP service, and choose a fixed port such as `38471`.
3. Read the relevant reference:
   - Codex: `references/codex.md`
   - WorkBuddy: `references/workbuddy.md`
4. For a preview only, run the target installer without `-Apply`.
5. After the user confirms the target file and changes, run the target installer with `-Apply`.
6. Run `scripts/verify-mcp.ps1` and report only the endpoint, server name, tool count, and resource count. Redact the token.

## Commands

All scripts accept `-SettingsPath` when Wemory uses a non-default local data directory.

```powershell
.\scripts\detect-wemory.ps1
.\scripts\install-codex.ps1
.\scripts\install-codex.ps1 -Apply
.\scripts\install-workbuddy.ps1
.\scripts\install-workbuddy.ps1 -Apply
.\scripts\verify-mcp.ps1
```

The preview commands never write files. The apply commands create a backup beside the target file before merging the `wemory` entry.

## Failure handling

- If the endpoint cannot be reached, ask the user to keep Wemory open and retry; do not guess a port.
- If authentication fails, ask the user to regenerate or copy the MCP token in Wemory, then retry.
- If a target config is invalid, leave it untouched and report the backup/parse error.
- If a target client is not installed, still generate the configuration and show its path; do not install unrelated software.
