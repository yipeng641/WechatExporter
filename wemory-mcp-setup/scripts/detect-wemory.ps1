param([string]$SettingsPath)
. (Join-Path $PSScriptRoot "common.ps1")

$resolved = Resolve-WemorySettingsPath $SettingsPath
$result = [ordered]@{
    settingsPath = $resolved
    wemoryRunning = (@(Get-Process -Name "wemory" -ErrorAction SilentlyContinue).Count -gt 0)
    mcpEnabled = $false
    host = $null
    port = $null
    endpoint = $null
    tokenConfigured = $false
    ready = $false
    message = $null
}

try {
    $loaded = Read-WemorySettings $SettingsPath
    $mcp = Get-OptionalProperty $loaded.Data "mcp"
    if ($null -eq $mcp) {
        throw "Wemory MCP configuration is missing. Enable MCP in Wemory first."
    }
    $result.mcpEnabled = [bool](Get-OptionalProperty $mcp "enabled")
    $configuredHost = Get-OptionalProperty $mcp "host"
    $result.host = if ($configuredHost) { [string]$configuredHost } else { "127.0.0.1" }
    $configuredPort = Get-OptionalProperty $mcp "port"
    $result.port = if ($null -eq $configuredPort) { 0 } else { [int]$configuredPort }
    $token = Get-WemoryToken $loaded.Data
    $result.tokenConfigured = -not [string]::IsNullOrWhiteSpace($token)
    if (-not $result.mcpEnabled) {
        $result.message = "Wemory MCP service is disabled. Enable it in Wemory first."
    } elseif ($result.port -lt 1 -or $result.port -gt 65535) {
        $result.message = "Choose a fixed Wemory MCP port from 1 to 65535; port 0 is not supported by this installer."
    } elseif (-not $result.tokenConfigured) {
        $result.message = "Wemory MCP token is not configured. Start the service once in Wemory."
    } else {
        $connection = Get-WemoryMcpConnection $SettingsPath
        $result.endpoint = $connection.Endpoint
        $result.wemoryRunning = $connection.WemoryRunning
        $result.ready = $connection.WemoryRunning
        if (-not $result.ready) {
            $result.message = "Wemory is not running. Open Wemory before installing the client configuration."
        }
    }
} catch {
    $result.message = $_.Exception.Message
}

[pscustomobject]$result | ConvertTo-Json -Depth 5
