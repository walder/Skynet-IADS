param(
    [string]$InstallMode = "AUTONOMOUS"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Continue'

$rootDir   = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { (Get-Location).Path }
$cardSrc   = Join-Path $rootDir "SkynetDataCard"
$isCommanderMode = ($InstallMode -eq "COMMANDER")

Write-Host ""
Write-Host "  ============================================================================" -ForegroundColor DarkCyan
Write-Host "      ____  _  ____   ___   _ _____ _____      ___    _    ____  ____  " -ForegroundColor Cyan
Write-Host "     / ___|| |/ /\ \ / / \ | | ____|_   _|    |_ _|  / \  |  _ \/ ___| " -ForegroundColor Cyan
Write-Host "     \___ \| ' /  \ V /|  \| |  _|   | | _____ | |  / _ \ | | | \___ \ " -ForegroundColor White
Write-Host "      ___) | . \   | | | |\  | |___  | ||_____|| | / ___ \| |_| |___) |" -ForegroundColor White
Write-Host "     |____/|_|\_\  |_| |_| \_|_____| |_|      |___/_/   \_\____/|____/ " -ForegroundColor Cyan
Write-Host ""
Write-Host "         S K Y N E T   I N T E G R A T E D   A I R   D E F E N S E" -ForegroundColor Yellow
Write-Host "          DCS 2.9+ EDITION WITH DEDICATED DEBUG & EVENT FILE LOGGER" -ForegroundColor Cyan
Write-Host "  ============================================================================" -ForegroundColor DarkCyan
Write-Host ""

if ($isCommanderMode) {
    Write-Host "   SELECTED MODE : [1] MISSION COMMANDER F10 MENU + HOOK DATA CARD + DEBUG LOG" -ForegroundColor Magenta
    Write-Host "   INCLUDES      : Hook (Skynet DataCard + SKYNET_IADS_DEBUG.log) + Single-File Scripts (1 & 2)" -ForegroundColor Gray
} else {
    Write-Host "   SELECTED MODE : [2] 100% AUTONOMOUS STEALTH MODE (NO F10 MENU + DEBUG LOG ACTIVE)" -ForegroundColor Yellow
    Write-Host "   INCLUDES      : Stealth Single-File Script (2) + Background SKYNET_IADS_DEBUG.log Hook" -ForegroundColor Gray
}
Write-Host "  ----------------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  >>> PRESS ANY KEY TO START INSTALLATION..." -ForegroundColor Green
cmd.exe /c "pause >nul"
Write-Host ""

# 1) Locate Windows Saved Games folder via Registry
$savedGames = $null
try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
    $val = (Get-ItemProperty -Path $regPath -Name "{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}" -ErrorAction SilentlyContinue)."{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}"
    if ($val -and (Test-Path $val)) {
        $savedGames = $val
    }
} catch {}

if (-not $savedGames) {
    $fallback = Join-Path $env:USERPROFILE "Saved Games"
    if (-not (Test-Path $fallback)) {
        New-Item -ItemType Directory -Path $fallback -Force | Out-Null
    }
    $savedGames = $fallback
}

Write-Host ("[FOUND] Windows Saved Games Directory: " + $savedGames) -ForegroundColor Green

# 2) Detect all DCS profiles inside Saved Games
$dcsDirs = @()
Get-ChildItem -Path $savedGames -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^DCS(\.|_|$)' } | ForEach-Object {
    $p = $_.FullName
    if ((Test-Path (Join-Path $p "Config")) -or (Test-Path (Join-Path $p "Scripts")) -or (Test-Path (Join-Path $p "Missions")) -or (Test-Path (Join-Path $p "Logs")) -or ($_.Name -in @("DCS", "DCS.openbeta"))) {
        $dcsDirs += $p
    }
}

if ($dcsDirs.Count -eq 0) {
    $defDcs = Join-Path $savedGames "DCS"
    New-Item -ItemType Directory -Path $defDcs -Force | Out-Null
    $dcsDirs += $defDcs
}

Write-Host ("[DETECTED] Found " + $dcsDirs.Count + " DCS Saved Games profile(s).") -ForegroundColor Cyan
Write-Host ""

$scriptFiles = @(
    "1_SINGLE_FILE_MIST_INCLUDED_COMMANDER_MENU_SKYNET_IADS.lua",
    "2_SINGLE_FILE_MIST_INCLUDED_SKYNET_IADS.lua"
)

foreach ($dcsPath in $dcsDirs) {
    Write-Host (">>> Installing into: " + $dcsPath) -ForegroundColor Yellow

    $hooksDir       = Join-Path $dcsPath "Scripts\Hooks"
    $cardDir        = Join-Path $hooksDir "SkynetDataCard"
    $dcsScriptsDir  = Join-Path $dcsPath "Scripts\Skynet_IADS"
    $dcsMissionsDir = Join-Path $dcsPath "Missions\Skynet_IADS_Scripts"

    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    New-Item -ItemType Directory -Path $cardDir -Force | Out-Null
    New-Item -ItemType Directory -Path $dcsScriptsDir -Force | Out-Null
    New-Item -ItemType Directory -Path $dcsMissionsDir -Force | Out-Null

    Get-ChildItem -LiteralPath $dcsScriptsDir -File -ErrorAction SilentlyContinue | Remove-Item -Force
    Get-ChildItem -LiteralPath $dcsMissionsDir -File -ErrorAction SilentlyContinue | Remove-Item -Force

    # Install Hook and SkynetDataCard PNG/DLG assets (handles both HUD DataCard and SKYNET_IADS_DEBUG.log writing)
    Copy-Item -Path (Join-Path $cardSrc "Skynet_IADS_DataCard_Hook.lua") -Destination (Join-Path $hooksDir "Skynet_IADS_DataCard_Hook.lua") -Force
    Get-ChildItem -Path $cardSrc -File | Where-Object { $_.Name -ne "Install_Skynet_IADS.ps1" -and $_.Name -ne "Skynet_IADS_DataCard_Hook.lua" } | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $cardDir $_.Name) -Force
    }
    Write-Host ("    [+] Skynet DataCard & Debug Logger Hook INSTALLED -> " + $hooksDir) -ForegroundColor Green

    foreach ($fName in $scriptFiles) {
        $srcFile = Join-Path $rootDir $fName
        if (Test-Path $srcFile) {
            Copy-Item -LiteralPath $srcFile -Destination (Join-Path $dcsScriptsDir $fName) -Force
            Copy-Item -LiteralPath $srcFile -Destination (Join-Path $dcsMissionsDir $fName) -Force
        }
    }
    Write-Host ("    [+] Skynet Single-File & Modular Lua Scripts INSTALLED -> " + $dcsMissionsDir) -ForegroundColor Green
    Write-Host ""
}

Write-Host "  ============================================================================" -ForegroundColor DarkCyan
if ($isCommanderMode) {
    Write-Host "   [SUCCESS] SKYNET-IADS COMMANDER F10 MENU & HOOK DATA CARD INSTALLED!" -ForegroundColor Green
    Write-Host "   * Use in Mission Editor (DO SCRIPT FILE):" -ForegroundColor White
    Write-Host "     1_SINGLE_FILE_MIST_INCLUDED_COMMANDER_MENU_SKYNET_IADS.lua" -ForegroundColor Yellow
} else {
    Write-Host "   [SUCCESS] SKYNET-IADS 100% AUTONOMOUS STEALTH MODE INSTALLED!" -ForegroundColor Green
    Write-Host "   * Use in Mission Editor (DO SCRIPT FILE):" -ForegroundColor White
    Write-Host "     2_SINGLE_FILE_MIST_INCLUDED_SKYNET_IADS.lua" -ForegroundColor Yellow
}
Write-Host "   * Mission Scripts Folder: Saved Games\DCS\Missions\Skynet_IADS_Scripts" -ForegroundColor Cyan
Write-Host "   * Dedicated Debug Log   : Saved Games\DCS\Logs\SKYNET_IADS_DEBUG.log" -ForegroundColor Cyan
Write-Host "                             C:\Users\TurkishCommunity\Desktop\Scriptler\SKYNET_IADS_DEBUG.log" -ForegroundColor Cyan
Write-Host "  ============================================================================" -ForegroundColor DarkCyan
