# WorkBuddy target

The installer updates the user-level WorkBuddy MCP file:

```text
%USERPROFILE%\.workbuddy\mcp.json
```

The generated entry is:

```json
{
  "mcpServers": {
    "wemory": {
      "type": "http",
      "url": "http://127.0.0.1:38471/mcp",
      "headers": {
        "Authorization": "Bearer <WEMORY_TOKEN>"
      },
      "description": "Wemory 微信聊天上下文"
    }
  }
}
```

Use `scripts/install-workbuddy.ps1` without `-Apply` to preview the target. Ask the user to confirm, then run it with `-Apply`. The script preserves other MCP servers and creates a timestamped backup before writing.

If WorkBuddy is using a project-level MCP file instead, pass its path with `-ConfigPath`. Restart or reload WorkBuddy after the file is changed, then use `scripts/verify-mcp.ps1` to check the endpoint.
