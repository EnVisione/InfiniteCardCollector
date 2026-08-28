param(
    [Parameter(Mandatory = $true)]
    [string]$Payload
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function ConvertTo-TaskArgument {
    param([string]$Value)

    if ($Value.Length -eq 0) {
        return '""'
    }
    if ($Value -notmatch '[\s"]') {
        return $Value
    }

    $TaskEscaped = [Regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $TaskEscaped = [Regex]::Replace($TaskEscaped, '(\\+)$', '$1$1')
    return '"' + $TaskEscaped + '"'
}

$TaskConfig = $Payload | ConvertFrom-Json
if ($TaskConfig.timeout_seconds -lt 1 -or $TaskConfig.timeout_seconds -gt 600) {
    throw "bounded process error, invalid timeout"
}

$TaskStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
$TaskStartInfo.FileName = [string]$TaskConfig.program
$TaskStartInfo.Arguments = (($TaskConfig.arguments | ForEach-Object { ConvertTo-TaskArgument ([string]$_) }) -join " ")
$TaskStartInfo.CreateNoWindow = $true
$TaskStartInfo.RedirectStandardError = $true
$TaskStartInfo.RedirectStandardOutput = $true
$TaskStartInfo.UseShellExecute = $false

$TaskProcess = [System.Diagnostics.Process]::new()
$TaskProcess.StartInfo = $TaskStartInfo
if (-not $TaskProcess.Start()) {
    throw "bounded process error, process did not start"
}

$TaskStandardOutput = $TaskProcess.StandardOutput.ReadToEndAsync()
$TaskStandardError = $TaskProcess.StandardError.ReadToEndAsync()
$TaskCompleted = $TaskProcess.WaitForExit([int]$TaskConfig.timeout_seconds * 1000)
if (-not $TaskCompleted) {
    try {
        $TaskProcess.Kill($true)
    }
    catch {
        $TaskProcess.Kill()
    }
    $TaskProcess.WaitForExit()
}

[Console]::Out.Write($TaskStandardOutput.GetAwaiter().GetResult())
[Console]::Error.Write($TaskStandardError.GetAwaiter().GetResult())

if (-not $TaskCompleted) {
    exit 124
}
exit $TaskProcess.ExitCode
