param(
    [string]$Tool = "auto",
    [string]$Destination = "",
    [string]$Ref = "main"
)

$ErrorActionPreference = "Stop"

if (-not $PSBoundParameters.ContainsKey("Tool") -and $env:DIALECTICAL_TOOL) {
    $Tool = $env:DIALECTICAL_TOOL
}

if (-not $PSBoundParameters.ContainsKey("Destination") -and $env:DIALECTICAL_DESTINATION) {
    $Destination = $env:DIALECTICAL_DESTINATION
}

$repoOwner = if ($env:REPO_OWNER) { $env:REPO_OWNER } else { "Uoghluvm" }
$repoName = if ($env:REPO_NAME) { $env:REPO_NAME } else { "dialectical-reasoning-skill" }
$skillName = "dialectical-reasoning"
$scriptRoot = Split-Path -Parent $PSCommandPath

function Resolve-Targets {
    param(
        [string]$TargetTool,
        [string]$ExplicitDestination
    )

    if ($ExplicitDestination) {
        return @($ExplicitDestination)
    }

    switch ($TargetTool.ToLowerInvariant()) {
        "codex" { return @("$HOME\.codex\skills") }
        "claude" { return @("$HOME\.claude\skills") }
        "claude-code" { return @("$HOME\.claude\skills") }
        "openclaw" { return @("$HOME\.agents\skills") }
        "qclaw" { return @("$HOME\.agents\skills") }
        "agents" { return @("$HOME\.agents\skills") }
        "all" { return @("$HOME\.codex\skills", "$HOME\.claude\skills", "$HOME\.agents\skills") }
        "auto" {
            $targets = New-Object System.Collections.Generic.List[string]
            if ((Test-Path "$HOME\.codex") -or (Test-Path "$HOME\.codex\skills")) {
                $targets.Add("$HOME\.codex\skills")
            }
            if ((Test-Path "$HOME\.claude") -or (Test-Path "$HOME\.claude\skills")) {
                $targets.Add("$HOME\.claude\skills")
            }
            if ((Test-Path "$HOME\.agents") -or (Test-Path "$HOME\.openclaw") -or (Test-Path "$HOME\.openclaw-autoclaw") -or (Test-Path "$HOME\.qclaw")) {
                $targets.Add("$HOME\.agents\skills")
            }
            if ($targets.Count -eq 0) {
                $targets.Add("$HOME\.codex\skills")
                $targets.Add("$HOME\.claude\skills")
                $targets.Add("$HOME\.agents\skills")
            }
            return $targets | Select-Object -Unique
        }
        default { throw "Unsupported tool: $TargetTool" }
    }
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("dialectical-install-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

try {
    $localSourceDir = Join-Path $scriptRoot "skills\$skillName"
    if (Test-Path $localSourceDir) {
        $sourceDir = Get-Item $localSourceDir
    }
    else {
        $archiveUrl = "https://codeload.github.com/$repoOwner/$repoName/zip/refs/heads/$Ref"
        $archivePath = Join-Path $tempRoot "repo.zip"
        $extractPath = Join-Path $tempRoot "repo"

        Write-Host "Downloading $repoOwner/$repoName@$Ref ..."
        Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath
        Expand-Archive -Path $archivePath -DestinationPath $extractPath -Force

        $sourceDir = Get-ChildItem -Path $extractPath -Recurse -Directory |
            Where-Object { $_.FullName -like "*\skills\$skillName" } |
            Select-Object -First 1

        if (-not $sourceDir) {
            throw "Failed to locate skills\$skillName in downloaded archive."
        }
    }

    foreach ($targetRoot in Resolve-Targets -TargetTool $Tool -ExplicitDestination $Destination) {
        New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
        $targetDir = Join-Path $targetRoot $skillName
        if (Test-Path $targetDir) {
            Remove-Item -LiteralPath $targetDir -Recurse -Force
        }
        Copy-Item -LiteralPath $sourceDir.FullName -Destination $targetDir -Recurse
        Write-Host "Installed to $targetDir"
    }

    Write-Host "Done."
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
