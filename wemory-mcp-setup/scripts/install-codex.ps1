param(
    [string]$SettingsPath,
    [string]$ConfigPath = (Join-Path $env:USERPROFILE ".codex\config.toml"),
    [switch]$Apply
)
. (Join-Path $PSScriptRoot "common.ps1")

$connection = Get-WemoryMcpConnection $SettingsPath
if (-not $connection.WemoryRunning) {
    throw "Wemory is not running. Open Wemory and retry."
}

$url = Escape-TomlBasicString $connection.Endpoint
$token = Escape-TomlBasicString $connection.Token
$block = @"
[mcp_servers.wemory]
url = "$url"
http_headers = { Authorization = "Bearer $token" }
enabled = true
"@.Trim() + [Environment]::NewLine

$existing = if (Test-Path -LiteralPath $ConfigPath -PathType Leaf) {
    [System.IO.File]::ReadAllText($ConfigPath)
} else {
    ""
}

try {
    $withoutWemory = [regex]::Replace(
        $existing,
        '(?ms)^\[mcp_servers\.wemory\]\s*.*?(?=^\[|\z)',
        ""
    ).Trim()
} catch {
    throw "Codex config could not be parsed safely: $($_.Exception.Message)"
}
$newContent = if ([string]::IsNullOrWhiteSpace($withoutWemory)) {
    $block
} else {
    $withoutWemory.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $block
}

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
