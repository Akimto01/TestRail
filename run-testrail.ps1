# Spusti testy a zapise vysledky do TestRailu pres TestRailListener.
# Prihlasovaci udaje se ctou z promennych prostredi TESTRAIL_USER a TESTRAIL_API_KEY,
# nikdy je nedavej primo do tohoto souboru (repozitar je verejny).
#
# Pouziti:  .\run-testrail.ps1 -RunId 3
#           .\run-testrail.ps1 -RunId 3 -Include smoke

param(
    [Parameter(Mandatory = $true)][int]$RunId,
    [string]$Server = "vojta1trial.testrail.io",
    [string]$Include = ""
)

if (-not $env:TESTRAIL_USER -or -not $env:TESTRAIL_API_KEY) {
    Write-Error "Chybi promenne prostredi TESTRAIL_USER nebo TESTRAIL_API_KEY."
    exit 1
}

$listener = "TestRailListener:${Server}:$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY):${RunId}:https"
$robotArgs = @("--outputdir", "results", "--listener", $listener)
if ($Include) { $robotArgs += @("--include", $Include) }

robot @robotArgs tests
