$version = $args[0]
if ($null -eq $version) {
	Write-Host "No version specified, script will not be compiled."
	return
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$buildTime = (Get-Date -Date (Get-Date).ToUniversalTime() -UFormat "%d.%m.%Y %H%MZ")
$header = "env.info(`"--- SKYNET VERSION: $version | BUILD TIME (UTC): $buildTime ---`")`r`n"

$sourceFiles = @(
	"../skynet-iads-source/skynet-iads-supported-types.lua",
	"../skynet-iads-source/highdigitsams/skynet-iads-high-digit-sams-suported-types.lua",
	"../skynet-iads-source/skynet-iads-logger.lua",
	"../skynet-iads-source/skynet-iads.lua",
	"../skynet-iads-source/skynet-mooose-a2a-dispatcher-connector.lua",
	"../skynet-iads-source/skynet-iads-table-delegator.lua",
	"../skynet-iads-source/skynet-iads-abstract-dcs-object-wrapper.lua",
	"../skynet-iads-source/skynet-iads-abstract-element.lua",
	"../skynet-iads-source/skynet-iads-abstract-radar-element.lua",
	"../skynet-iads-source/skynet-iads-awacs-radar.lua",
	"../skynet-iads-source/skynet-iads-command-center.lua",
	"../skynet-iads-source/skynet-iads-contact.lua",
	"../skynet-iads-source/skynet-iads-early-warning-radar.lua",
	"../skynet-iads-source/skynet-iads-jammer.lua",
	"../skynet-iads-source/skynet-iads-sam-search-radar.lua",
	"../skynet-iads-source/skynet-iads-sam-site.lua",
	"../skynet-iads-source/skynet-iads-sam-tracking-radar.lua",
	"../skynet-iads-source/syknet-iads-sam-launcher.lua",
	"../skynet-iads-source/skynet-iads-harm-detection.lua"
)

$sb = New-Object System.Text.StringBuilder

foreach ($relPath in $sourceFiles) {
	$fullPath = Resolve-Path (Join-Path $PSScriptRoot $relPath)
	$text = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
	if ($text.Length -gt 0 -and [int][char]$text[0] -eq 0xFEFF) {
		$text = $text.Substring(1)
	}
	[void]$sb.Append($text)
	if (-not $text.EndsWith("`n")) {
		[void]$sb.Append("`r`n")
	}
}

[void]$sb.Append("`r`n" + $header)

$outPath = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "../demo-missions")) "skynet-iads-compiled.lua"
[System.IO.File]::WriteAllText($outPath, $sb.ToString(), $utf8NoBom)
Write-Host "Compiled UTF-8 (no BOM): $outPath"

if (Test-Path (Join-Path $PSScriptRoot "bin/gh-md-toc.exe")) {
	Push-Location -LiteralPath $PSScriptRoot
	$toc = ./bin/gh-md-toc.exe --hide-footer ../skynet-iads-source/README_source.md
	$toc = $toc -replace "=================", "=================
"
	$toc = $toc -replace "Table of Contents", "Table of Contents
"
	$toc = $toc -replace "\)", "`)
"
	$readme = Get-Content ../skynet-iads-source/README_source.md -Encoding UTF8
	$readmeWithTOC = $readme -replace "{TOC_PLACEHOLDER}", $toc
	[System.IO.File]::WriteAllLines((Join-Path (Resolve-Path "..") "README.md"), $readmeWithTOC, $utf8NoBom)
	Pop-Location
}