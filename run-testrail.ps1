# Spusti FlaUI testy a posle vysledky do TestRailu pres TRCLI
# (stejny postup jako Jenkins job a jako na projektu: nejdriv robot, pak trcli).
#
# Prihlasovaci udaje se ctou z promennych prostredi TESTRAIL_USER a TESTRAIL_API_KEY,
# nikdy je nedavej primo do tohoto souboru (repozitar je verejny).
#
# Pouziti:
#   .\run-testrail.ps1                     # vychozi hodnoty (run 4, milestone 3, -n)
#   .\run-testrail.ps1 -Include smoke      # jen testy s tagem smoke
#   .\run-testrail.ps1 -AutoCreate         # povoli zalozit chybejici casy (-y)
#   .\run-testrail.ps1 -FromRun            # spusti jen testy vybrane v runu RunId v TestRailu
#   .\run-testrail.ps1 -ExtraRobotArgs "--variable","TIME_PATTERN:NEEXISTUJE"
#                                          # dalsi argumenty pro robot (napr. umyslne shozeny test)

param(
    [int]$RunId = 4,
    [int]$MilestoneId = 3,
    [int]$ProjectId = 2,
    [string]$Project = ("Notepad " + [char]0x2013 + " FlaUI"),
    [string]$TestRailHost = "https://vojta1trial.testrail.io",
    [string]$Tag = "smoke",
    [string]$Include = "",
    [switch]$AutoCreate,
    [switch]$FromRun,
    [string[]]$ExtraRobotArgs = @()
)

if (-not $env:TESTRAIL_USER -or -not $env:TESTRAIL_API_KEY) {
    Write-Error "Chybi promenne prostredi TESTRAIL_USER nebo TESTRAIL_API_KEY."
    exit 1
}

# 1) Spusteni testu
$robotArgs = @("--outputdir", "results")
if ($FromRun) {
    # Vyber testu podle obsahu runu v TestRailu (podle automation_id jeho casu)
    $env:TESTRAIL_HOST = $TestRailHost
    python tools\select-tests.py --run-id $RunId
    if ($LASTEXITCODE -ne 0) { exit 1 }
    $robotArgs += @("--argumentfile", "results\selected-tests.args")
}
if ($Include) { $robotArgs += @("--include", $Include) }
$robotArgs += $ExtraRobotArgs
robot @robotArgs tests
$robotRc = $LASTEXITCODE

# 2) Odeslani vysledku do TestRailu
$now = Get-Date -Format "yyyy-MM-dd HH:mm"
$confirm = if ($AutoCreate) { "-y" } else { "-n" }

trcli $confirm `
    -h $TestRailHost `
    --project-id $ProjectId `
    --project $Project `
    --insecure `
    --username $env:TESTRAIL_USER `
    --password $env:TESTRAIL_API_KEY `
    parse_robot `
    --run-id $RunId `
    --case-matcher auto `
    --case-fields "template_id:2" `
    --title "Notepad FlaUI lokalni-beh - $now - tag:$Tag" `
    --milestone-id $MilestoneId `
    --run-description "Lokalni beh z pocitace $env:COMPUTERNAME" `
    -f "results/output.xml"

if ($LASTEXITCODE -ne 0) {
    Write-Error "TRCLI nenahralo vysledky do TestRailu (napr. nenalezene casy podle automation_id)."
    exit 1
}

exit $robotRc
