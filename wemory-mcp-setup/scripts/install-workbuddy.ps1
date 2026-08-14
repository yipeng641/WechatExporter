param(
    [string]$SettingsPath,
    [string]$ConfigPath = (Join-Path $env:USERPROFILE ".workbuddy\mcp.json"),
    [switch]$Apply
)
. (Join-Path $PSScriptRoot "common.ps1")

$connection = Get-WemoryMcpConnection $SettingsPath
if (-not $connection.WemoryRunning) {
    throw "Wemory is not running. Open Wemory and retry."
}

if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
    $raw = [System.IO.File]::ReadAllText($ConfigPath)
    try {
        $root = $raw | ConvertFrom-Json
    } catch {
        throw "WorkBuddy config is not valid JSON: $($_.Exception.Message)"
    }
} else {
    $root = [pscustomobject]@{}
}

$hasMcpServers = @($root.PSObject.Properties | Where-Object { $_.Name -eq "mcpServers" }).Count -gt 0
if (-not $hasMcpServers) {
    $root | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([pscustomobject]@{})
}

$entry = [pscustomobject]@{
    type = "http"
    url = $connection.Endpoint
    headers = [pscustomobject]@{
        Authorization = "Bearer $($connection.Token)"
    }
    description = "Wemory chat context"
}

$hasWemory = @($root.mcpServers.PSObject.Properties | Where-Object { $_.Name -eq "wemory" }).Count -gt 0
if ($hasWemory) {
    $root.mcpServers.wemory = $entry
} else {
    $root.mcpServers | Add-Member -NotePropertyName "wemory" -NotePropertyValue $entry
}
$newContent = ($root | ConvertTo-Json -Depth 20) + [Environment]::NewLine

if (-not $Apply) {
    [pscustomobject]@{
        action = "preview"
        target = $ConfigPath
        endpoint = $connection.Endpoint
        message = "No file was changed. Re-run with -Apply after confirmation."
    } | ConvertTo-Json -Depth 5
    exit 0
}

Ensure-ParentDirectory $ConfigPath
$backup = Backup-File $ConfigPath
Write-Utf8NoBom $ConfigPath $newContent
[pscustomobject]@{
    action = "applied"
    target = $ConfigPath
    backup = $backup
    endpoint = $connection.Endpoint
} | ConvertTo-Json -Depth 5
