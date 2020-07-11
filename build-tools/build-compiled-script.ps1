$version=$args[0]
if ($version -eq $null){
	echo "No Version supplied, not bulding script"
	return
}
if (Test-Path ./tmp/){
	Remove-Item ./tmp/
}
New-Item ./tmp/ -ItemType Directory
if (Test-Path ./tmp/skynet-iads-compiled.lua) {
	Remove-Item ./tmp/skynet-iads-compiled.lua
}
Add-Content ./tmp/tmp-time.lua ("env.info(`"--- SKYNET VERSION: "+$version+" | BUILD TIME: "+(Get-Date -date (Get-Date).ToUniversalTime()-uformat "%d.%m.%Y %H%MZ")+" ---`")")  
cat ../skynet-iads-source/skynet-iads-supported-types.lua, ../skynet-iads-source/skynet-iads.lua, ../skynet-iads-source/skynet-mooose-a2a-dispatcher-connector.lua, ../skynet-iads-source/skynet-iads-table-delegator.lua, ../skynet-iads-source/skynet-iads-abstract-dcs-object-wrapper.lua, ../skynet-iads-source/skynet-iads-abstract-element.lua, ../skynet-iads-source/skynet-iads-abstract-radar-element.lua, ../skynet-iads-source/skynet-iads-awacs-radar.lua, ../skynet-iads-source/skynet-iads-command-center.lua, ../skynet-iads-source/skynet-iads-contact.lua, ../skynet-iads-source/skynet-iads-early-warning-radar.lua, ../skynet-iads-source/skynet-iads-jammer.lua, ../skynet-iads-source/skynet-iads-sam-search-radar.lua, ../skynet-iads-source/skynet-iads-sam-site.lua, ../skynet-iads-source/skynet-iads-sam-tracking-radar.lua, ../skynet-iads-source/syknet-iads-sam-launcher.lua | sc ./tmp/tmp-code.lua 
$code = Get-Content ./tmp/tmp-code.lua
Add-Content ./tmp/tmp-time.lua $code
Rename-Item -Path ./tmp/tmp-time.lua -NewName skynet-iads-compiled.lua
Remove-Item ./tmp/tmp-code.lua

if (Test-Path ../demo-missions/skynet-iads-compiled.lua) {
	Remove-Item ../demo-missions/skynet-iads-compiled.lua
}

Move-Item -Path ./tmp/skynet-iads-compiled.lua ../demo-missions/skynet-iads-compiled.lua

$toc = ./bin/gh-md-toc.exe --hide-footer ../skynet-iads-source/README_source.md
$toc = $toc -replace "=================", "=================`n"
$toc = $toc -replace "Table of Contents", "Table of Contents`n"
$toc = $toc -replace "\)", "`)`n"
$readme = Get-Content ../skynet-iads-source/README_source.md
$readmeWithTOC = $readme -replace "{TOC_PLACEHOLDER}", $toc

if (Test-Path ../README.md) {
	Remove-Item ../README.md
}

Add-Content ../README.md $readmeWithTOC
Remove-Item ./tmp/