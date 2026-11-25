# Po behu testu vygeneruje report v TestRailu pres API (run_report) a odkaz na nej
# pripise do popisu test runu. Odkaz zaroven vypise do konzole (radek REPORT_URL=...),
# odkud si ho Jenkins muze vzit do popisu buildu.
#
# Report musi mit v TestRailu zaskrtnute "On demand via the API" (sekce Reports > API Templates).
# Prihlaseni: promenne prostredi TESTRAIL_USER a TESTRAIL_API_KEY (stejne jako pro TRCLI).
#
# Pouziti:
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\publish-report.ps1 -RunId 4 -TemplateId 1
#
# Kdyz se report nepodari vytvorit, skript jen vypise varovani a skonci s kodem 0,
# aby kvuli reportu neselhal cely build.

param(
    [Parameter(Mandatory = $true)][int]$RunId,
    [int]$TemplateId = 1,
    [string]$TestRailHost = $env:TESTRAIL_HOST
)

if (-not $TestRailHost) { $TestRailHost = "https://vojta1trial.testrail.io" }

try {
    $pair = "$($env:TESTRAIL_USER):$($env:TESTRAIL_API_KEY)"
    $headers = @{ Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pair)) }
    $api = "$($TestRailHost.TrimEnd('/'))/index.php?/api/v2"

    # 1) Spusteni reportu
    $report = Invoke-RestMethod -Uri "$api/run_report/$TemplateId" -Headers $headers -ErrorAction Stop
    $url = $report.report_url
    Write-Output "REPORT_URL=$url"

    # 2) Pripsani odkazu do popisu runu (TRCLI tam pred tim zapsal odkaz na build)
    $run = Invoke-RestMethod -Uri "$api/get_run/$RunId" -Headers $headers -ErrorAction Stop
    $description = [string]$run.description
    $line = "TestRail report: $url"
    if ($description) { $newDescription = "$description`n$line" } else { $newDescription = $line }

    # Run uvnitr test planu se upravuje jinym endpointem nez samostatny run
    if ($run.plan_id) { $endpoint = "update_run_in_plan_entry/$RunId" } else { $endpoint = "update_run/$RunId" }

    $body = @{ description = $newDescription } | ConvertTo-Json
    Invoke-RestMethod -Uri "$api/$endpoint" -Method Post -Headers $headers `
        -ContentType "application/json; charset=utf-8" `
        -Body ([Text.Encoding]::UTF8.GetBytes($body)) -ErrorAction Stop | Out-Null
    Write-Output "Odkaz na report pridan do popisu runu R$RunId."
}
catch {
    Write-Warning "Report se nepodarilo vytvorit nebo zapsat do runu: $($_.Exception.Message)"
}

exit 0
