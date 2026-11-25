@echo off
rem === Priprava prostredi ===
python -m venv .venv
call .venv\Scripts\activate.bat
python -m pip install -q -r requirements.txt trcli

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%i
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format HH:mm"') do set NOW=%%i

rem === 1) Vyber testu podle obsahu runu v TestRailu (automation_id) ===
python tools\select-tests.py --run-id %RUN_ID%
if errorlevel 1 exit /b 1

rem === 2) Spusteni jen vybranych testu ===
robot --argumentfile results\selected-tests.args --outputdir results tests

rem === 3) Odeslani vysledku do TestRailu (stejne jako na projektu) ===
trcli ^
    -n ^
    -h %TESTRAIL_HOST% ^
    --project-id %PROJECT_ID% ^
    --project "%TESTRAIL_PROJECT%" ^
    --insecure ^
    --username "%TESTRAIL_USER%" ^
    --password "%TESTRAIL_API_KEY%" ^
    parse_robot ^
    --run-id %RUN_ID% ^
    --case-matcher auto ^
    --case-fields template_id:2 ^
    --milestone-id %MILESTONE% ^
    --run-description "%BUILD_URL%" ^
    -f "results/output.xml"
if errorlevel 1 (
    echo TRCLI nenahralo vysledky do TestRailu.
    exit /b 1
)

rem === 4) Report v TestRailu pres API a odkaz do popisu runu ===
if not "%REPORT_TEMPLATE_ID%"=="" powershell -NoProfile -ExecutionPolicy Bypass -File tools\publish-report.ps1 -RunId %RUN_ID% -TemplateId %REPORT_TEMPLATE_ID%
exit /b 0
