[CmdletBinding()]
param(
    [ValidatePattern('^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$')]
    [string] $AppVersion = '0.1.0',
    [string] $HeadsetControlDirectory,
    [string] $InnoCompiler
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($HeadsetControlDirectory)) {
    $HeadsetControlDirectory = Join-Path $repositoryRoot 'packaging\headsetcontrol'
}

$requiredBackendFiles = @(
    'headsetcontrol.exe',
    'HeadsetControl-GPL-3.0.txt',
    'HeadsetControl-SOURCE.txt'
)
foreach ($fileName in $requiredBackendFiles) {
    $path = Join-Path $HeadsetControlDirectory $fileName
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required packaging input is missing: $path"
    }
}

$publishDirectory = Join-Path $repositoryRoot 'artifacts\publish\win-x64'
$installerOutput = Join-Path $repositoryRoot 'artifacts\installer'
$project = Join-Path $repositoryRoot 'src\HeadsetBatteryMonitor\HeadsetBatteryMonitor.csproj'

dotnet publish $project `
    --configuration Release `
    --runtime win-x64 `
    --self-contained true `
    --output $publishDirectory `
    -p:PublishProfile=win-x64 `
    -p:Version=$AppVersion `
    -m:1
if ($LASTEXITCODE -ne 0) {
    throw "dotnet publish failed with exit code $LASTEXITCODE."
}

$publishedExe = Join-Path $publishDirectory 'HeadsetBatteryMonitor.exe'
if (-not (Test-Path -LiteralPath $publishedExe -PathType Leaf)) {
    throw "The expected published executable was not produced: $publishedExe"
}

if ([string]::IsNullOrWhiteSpace($InnoCompiler)) {
    $command = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        $InnoCompiler = $command.Source
    }
    else {
        $defaultCompiler = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'
        if (Test-Path -LiteralPath $defaultCompiler -PathType Leaf) {
            $InnoCompiler = $defaultCompiler
        }
    }
}
if ([string]::IsNullOrWhiteSpace($InnoCompiler) -or -not (Test-Path -LiteralPath $InnoCompiler -PathType Leaf)) {
    throw 'Inno Setup 6 compiler (ISCC.exe) was not found. Install it or pass -InnoCompiler.'
}

New-Item -ItemType Directory -Force -Path $installerOutput | Out-Null
$script = Join-Path $PSScriptRoot 'HeadsetBatteryMonitor.iss'
& $InnoCompiler `
    "/DSourceDir=$publishDirectory" `
    "/DHeadsetControlDir=$HeadsetControlDirectory" `
    "/DAppVersion=$AppVersion" `
    "/DOutputDir=$installerOutput" `
    $script
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup compilation failed with exit code $LASTEXITCODE."
}

Write-Host "Installer created in $installerOutput"
