# Codex target

The installer updates the user-level Codex TOML file:

```text
%USERPROFILE%\.codex\config.toml
```

The generated entry is:

```toml
[mcp_servers.wemory]
url = "http://127.0.0.1:38471/mcp"
http_headers = { Authorization = "Bearer <WEMORY_TOKEN>" }
enabled = true
```

Use `scripts/install-codex.ps1` without `-Apply` to preview the target. Ask the user to confirm, then run it with `-Apply`. The script preserves other TOML sections and creates a timestamped backup before writing.

After installation, restart Codex if it was already running and verify that the Wemory server appears in the MCP server list. Never place the real token in source control or in a shared project configuration.
