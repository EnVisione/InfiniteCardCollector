$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$TaskScriptDirectory = Split-Path -Parent $PSCommandPath
$TaskRepositoryRoot = Split-Path -Parent $TaskScriptDirectory
$TaskRegistryPath = Join-Path $TaskRepositoryRoot "config/tool-artifacts.json"

function Stop-TaskBootstrap {
    param([string]$Message)
    throw "bootstrap error, $Message"
}

if (-not [Environment]::Is64BitOperatingSystem -or $env:PROCESSOR_ARCHITECTURE -notin @("AMD64", "x86_64")) {
    Stop-TaskBootstrap "supported target is windows x86_64"
}

$TaskRegistry = Get-Content -LiteralPath $TaskRegistryPath -Raw | ConvertFrom-Json
$TaskToolIds = @($TaskRegistry.tools | ForEach-Object { $_.id } | Sort-Object)
if ($TaskRegistry.schema_version -ne 1 -or ($TaskToolIds -join ",") -ne "lune,rojo,rokit,selene,stylua") {
    Stop-TaskBootstrap "artifact registry contract is invalid"
}

$TaskBootstrapDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("infinite-card-collector-bootstrap." + [Guid]::NewGuid().ToString("N"))
[System.IO.Directory]::CreateDirectory($TaskBootstrapDirectory) | Out-Null

try {
    if ([string]::IsNullOrWhiteSpace($env:ROKIT_ROOT)) {
        $env:ROKIT_ROOT = Join-Path ([Environment]::GetFolderPath("UserProfile")) ".rokit"
    }

    $TaskRokitBin = Join-Path $env:ROKIT_ROOT "bin"
    $TaskToolStorage = Join-Path $env:ROKIT_ROOT "tool-storage"
    [System.IO.Directory]::CreateDirectory($TaskRokitBin) | Out-Null
    [System.IO.Directory]::CreateDirectory($TaskToolStorage) | Out-Null

    $TaskTrustedIds = [System.Collections.Generic.List[string]]::new()
    $TaskInstalledSpecs = [System.Collections.Generic.List[string]]::new()

    foreach ($TaskTool in $TaskRegistry.tools) {
        $TaskArtifact = @($TaskTool.artifacts | Where-Object { $_.platform -eq "windows-x86_64" })
        if ($TaskArtifact.Count -ne 1) {
            Stop-TaskBootstrap "$($TaskTool.id) has no unique windows artifact"
        }
        $TaskArtifact = $TaskArtifact[0]

        if ([System.IO.Path]::GetFileName($TaskArtifact.filename) -ne $TaskArtifact.filename -or [System.IO.Path]::GetFileName($TaskArtifact.executable) -ne $TaskArtifact.executable) {
            Stop-TaskBootstrap "artifact names must be basenames"
        }
        if (-not $TaskArtifact.url.StartsWith("https://github.com/", [StringComparison]::Ordinal)) {
            Stop-TaskBootstrap "artifact source must be github over https"
        }

        $TaskArchive = Join-Path $TaskBootstrapDirectory $TaskArtifact.filename
        $TaskExtracted = Join-Path $TaskBootstrapDirectory $TaskTool.id
        Invoke-WebRequest -Uri $TaskArtifact.url -OutFile $TaskArchive -MaximumRedirection 5

        if ((Get-Item -LiteralPath $TaskArchive).Length -ne [long]$TaskArtifact.size) {
            Stop-TaskBootstrap "$($TaskArtifact.filename) size mismatch"
        }
        if ((Get-FileHash -LiteralPath $TaskArchive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $TaskArtifact.sha256) {
            Stop-TaskBootstrap "$($TaskArtifact.filename) sha256 mismatch"
        }
        if ((Get-FileHash -LiteralPath $TaskArchive -Algorithm SHA512).Hash.ToLowerInvariant() -ne $TaskArtifact.sha512) {
            Stop-TaskBootstrap "$($TaskArtifact.filename) sha512 mismatch"
        }

        $TaskZip = [System.IO.Compression.ZipFile]::OpenRead($TaskArchive)
        try {
            if ($TaskZip.Entries.Count -ne 1 -or $TaskZip.Entries[0].FullName -ne $TaskArtifact.executable) {
                Stop-TaskBootstrap "$($TaskArtifact.filename) archive layout mismatch"
            }
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($TaskZip.Entries[0], $TaskExtracted, $true)
        }
        finally {
            $TaskZip.Dispose()
        }

        if ((Get-Item -LiteralPath $TaskExtracted).Length -ne [long]$TaskArtifact.executable_size) {
            Stop-TaskBootstrap "$($TaskArtifact.executable) size mismatch"
        }
        if ((Get-FileHash -LiteralPath $TaskExtracted -Algorithm SHA256).Hash.ToLowerInvariant() -ne $TaskArtifact.executable_sha256) {
            Stop-TaskBootstrap "$($TaskArtifact.executable) sha256 mismatch"
        }
        if ((Get-FileHash -LiteralPath $TaskExtracted -Algorithm SHA512).Hash.ToLowerInvariant() -ne $TaskArtifact.executable_sha512) {
            Stop-TaskBootstrap "$($TaskArtifact.executable) sha512 mismatch"
        }

        if ($TaskTool.id -eq "rokit") {
            $TaskTarget = Join-Path $TaskRokitBin "rokit.exe"
        }
        else {
            if ($TaskTool.rokit_spec -notmatch '^([^/]+)/([^@]+)@(.+)$') {
                Stop-TaskBootstrap "$($TaskTool.id) rokit specification is invalid"
            }
            $TaskAuthor = $Matches[1].ToLowerInvariant()
            $TaskName = $Matches[2].ToLowerInvariant()
            $TaskVersion = $Matches[3]
            $TaskTarget = Join-Path $TaskToolStorage "$TaskAuthor/$TaskName/$TaskVersion/$TaskName.exe"
            $TaskTrustedIds.Add("$($Matches[1])/$($Matches[2])")
            $TaskInstalledSpecs.Add($TaskTool.rokit_spec)
        }

        [System.IO.Directory]::CreateDirectory((Split-Path -Parent $TaskTarget)) | Out-Null
        if (Test-Path -LiteralPath $TaskTarget) {
            if ((Get-FileHash -LiteralPath $TaskTarget -Algorithm SHA256).Hash.ToLowerInvariant() -ne $TaskArtifact.executable_sha256) {
                Stop-TaskBootstrap "existing $TaskTarget is not the pinned executable"
            }
        }
        else {
            Copy-Item -LiteralPath $TaskExtracted -Destination $TaskTarget
        }
    }

    $TaskCachePath = Join-Path $TaskToolStorage "cache.json"
    if (Test-Path -LiteralPath $TaskCachePath) {
        $TaskCache = Get-Content -LiteralPath $TaskCachePath -Raw | ConvertFrom-Json
    }
    else {
        $TaskCache = [pscustomobject]@{ trusted = @(); installed = @() }
    }
    if ($null -eq $TaskCache.trusted -or $null -eq $TaskCache.installed) {
        Stop-TaskBootstrap "rokit cache is invalid"
    }
    $TaskCacheNext = [ordered]@{
        trusted = @($TaskCache.trusted + $TaskTrustedIds | Sort-Object -Unique)
        installed = @($TaskCache.installed + $TaskInstalledSpecs | Sort-Object -Unique)
    }
    $TaskCacheNext | ConvertTo-Json -Depth 4 -Compress | Set-Content -LiteralPath $TaskCachePath -Encoding utf8NoBOM

    $env:PATH = "$TaskRokitBin$([System.IO.Path]::PathSeparator)$env:PATH"
    $TaskRokitCommand = Get-Command rokit -CommandType Application | Select-Object -First 1
    if ($TaskRokitCommand.Source -ne (Join-Path $TaskRokitBin "rokit.exe")) {
        Stop-TaskBootstrap "rokit is shadowed on path"
    }
    if ((rokit --version) -ne "rokit 1.2.0") {
        Stop-TaskBootstrap "rokit version mismatch"
    }

    Push-Location $TaskRepositoryRoot
    try {
        rokit install
        if ($LASTEXITCODE -ne 0) {
            Stop-TaskBootstrap "rokit install failed"
        }
    }
    finally {
        Pop-Location
    }

    Write-Output "bootstrap complete, rokit root $env:ROKIT_ROOT"
}
finally {
    if ($TaskBootstrapDirectory.StartsWith([System.IO.Path]::GetTempPath(), [StringComparison]::OrdinalIgnoreCase)) {
        [System.IO.Directory]::Delete($TaskBootstrapDirectory, $true)
    }
}
