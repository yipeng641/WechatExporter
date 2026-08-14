param([string]$SettingsPath)
. (Join-Path $PSScriptRoot "common.ps1")

$connection = Get-WemoryMcpConnection $SettingsPath
if (-not $connection.WemoryRunning) {
    throw "Wemory is not running. Open Wemory and retry."
}

$headers = @{
    Authorization = "Bearer $($connection.Token)"
    Accept = "application/json, text/event-stream"
}

function Invoke-Mcp {
    param([string]$Method, [int]$Id)
    $body = @{
        jsonrpc = "2.0"
        id = $Id
        method = $Method
        params = @{}
    } | ConvertTo-Json -Depth 10 -Compress
    $response = Invoke-RestMethod -Uri $connection.Endpoint -Method Post -Headers $headers -ContentType "application/json" -Body $body
    $error = Get-OptionalProperty $response "error"
    if ($null -ne $error) {
        throw "$Method failed: $($error.message)"
    }
    return $response.result
}

$initialize = Invoke-Mcp "initialize" 1
$tools = Invoke-Mcp "tools/list" 2
$resources = Invoke-Mcp "resources/list" 3

[pscustomobject]@{
    verified = $true
    endpoint = $connection.Endpoint
    server = $initialize.serverInfo.name
    serverVersion = $initialize.serverInfo.version
    toolCount = @($tools.tools).Count
    resourceCount = @($resources.resources).Count
    resourceTemplateCount = @($resources.resourceTemplates).Count
} | ConvertTo-Json -Depth 5
