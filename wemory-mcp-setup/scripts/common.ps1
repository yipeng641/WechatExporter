Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-OptionalProperty {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) {
        return $null
    }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }
    return $property.Value
}

function Get-WemoryToken {
    param([object]$Settings)

    # Support both the original snake_case key and Wemory's camelCase JSON key.
    $token = Get-OptionalProperty $Settings "mcp_token"
    if ($null -eq $token) {
        $token = Get-OptionalProperty $Settings "mcpToken"
    }
    return [string]$token
}

function Resolve-WemorySettingsPath {
    param([string]$SettingsPath)

    if ($SettingsPath) {
        return [System.IO.Path]::GetFullPath($SettingsPath)
    }

    $appData = [Environment]::GetFolderPath("ApplicationData")
    $candidates = @(
        (Join-Path $appData "com.wemory.desktop\settings.json"),
        (Join-Path $appData "com.wemory.desktop\settings\settings.json")
    )
    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }
    return $candidates[0]
}

function Read-WemorySettings {
    param([string]$SettingsPath)

    $path = Resolve-WemorySettingsPath $SettingsPath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Wemory settings file was not found: $path"
    }
    $raw = [System.IO.File]::ReadAllText($path)
    if ([string]::IsNullOrWhiteSpace($raw)) {
        throw "Wemory settings file is empty: $path"
    }
    return [pscustomobject]@{
        Path = $path
        Data = ($raw | ConvertFrom-Json)
    }
}

function Get-WemoryMcpConnection {
    param([string]$SettingsPath)

    $loaded = Read-WemorySettings $SettingsPath
    $settings = $loaded.Data
    $mcp = Get-OptionalProperty $settings "mcp"
    if ($null -eq $mcp) {
        throw "Wemory MCP configuration is missing. Enable MCP in Wemory first."
    }
    if (-not [bool](Get-OptionalProperty $mcp "enabled")) {
        throw "Wemory MCP service is disabled. Enable it in Wemory first."
    }

    $configuredHost = Get-OptionalProperty $mcp "host"
    $hostName = if ($configuredHost) { [string]$configuredHost } else { "127.0.0.1" }
    if ($hostName -notin @("127.0.0.1", "localhost")) {
        throw "Wemory MCP must use the loopback host, not $hostName"
    }

    $configuredPort = Get-OptionalProperty $mcp "port"
    $port = if ($null -eq $configuredPort) { 0 } else { [int]$configuredPort }
    if ($port -lt 1 -or $port -gt 65535) {
        throw "Wemory MCP must use a fixed port from 1 to 65535; port 0 is not supported by this installer"
    }

    $token = Get-WemoryToken $settings
    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "Wemory MCP token is not configured"
    }

    $running = @(Get-Process -Name "wemory" -ErrorAction SilentlyContinue).Count -gt 0
    [pscustomobject]@{
        SettingsPath = $loaded.Path
        Host = $hostName
        Port = $port
        Endpoint = "http://$hostName`:$port/mcp"
        Token = $token
        WemoryRunning = $running
    }
}

function Ensure-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Backup-File {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }
    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $backup = "$Path.bak.$stamp"
    Copy-Item -LiteralPath $Path -Destination $backup -Force
    return $backup
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Escape-TomlBasicString {
    param([string]$Value)
    return $Value.Replace("\", "\\").Replace('"', '\"')
}
