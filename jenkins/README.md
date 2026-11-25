# Jenkins job TestRail-FlaUI-Notepad

Export konfigurace lokálního Jenkins jobu, který podle obsahu test runu v TestRailu vybere testy,
spustí je, pošle výsledky do TestRailu přes TRCLI a vygeneruje souhrnný report.

- `TestRail-FlaUI-Notepad.xml` – kompletní konfigurace jobu (Freestyle), dá se naimportovat do Jenkinsu
- `build-step.bat` – čitelná kopie build stepu (Execute Windows batch command)

Soubory neobsahují žádná hesla ani API klíče. Přihlašovací údaje k TestRailu si job bere
z Jenkins credentials s ID `testrail-api` (typ Username with password: e-mail a API klíč)
a předává je do buildu jako proměnné `TESTRAIL_USER` a `TESTRAIL_API_KEY`.

## Co job dělá

1. Stáhne repo `Akimto01/TestRail` (větev `main`) a připraví `.venv` se závislostmi z `requirements.txt`.
2. `tools/select-tests.py` přečte přes API testy v runu `RUN_ID` a podle jejich `automation_id`
   připraví filtr `results/selected-tests.args`.
3. Spustí jen vybrané testy: `robot --argumentfile results\selected-tests.args --outputdir results tests`.
4. Nahraje `results/output.xml` do stejného runu přes `trcli -n ... parse_robot --run-id %RUN_ID%`
   (bez `--title`, run si ponechá svůj název; do popisu runu zapíše odkaz na build).
5. `tools/publish-report.ps1` zavolá `run_report` pro API šablonu `REPORT_TEMPLATE_ID`
   a odkaz na vygenerovaný report připíše do popisu runu. Do konzole vypíše řádek `REPORT_URL=...`.
6. Post-build akce Description Setter z řádku `REPORT_URL=...` nastaví popis buildu
   („TestRail report: <odkaz>“).
7. Publikuje výsledky přes Robot Framework plugin (prahy 100 % úspěch, 80 % unstable).

## Parametry buildu

| Parametr | Výchozí hodnota | Význam |
|---|---|---|
| `RUN_ID` | 4 | Run, ze kterého se vyberou testy a kam se zapíší výsledky |
| `MILESTONE` | 3 | Milestone, ke kterému se run přiřadí (`--milestone-id`) |
| `TAG` | smoke | Informativní značka běhu |
| `PROJECT_ID` | 2 | `--project-id` |
| `TESTRAIL_PROJECT` | Notepad – FlaUI | `--project` |
| `TESTRAIL_HOST` | https://vojta1trial.testrail.io | `-h` |
| `APP_VERSION` | 1.0.0 | Verze aplikace, TRCLI ji zapíše do pole Version u výsledků (`--result-fields`) |
| `REPORT_TEMPLATE_ID` | 1 | ID API šablony reportu; prázdné = report se negeneruje |

## Požadavky na Jenkins

- Pluginy: Git, Robot Framework, Credentials Binding, Description Setter.
- Credential `testrail-api` (Username with password).
- V TestRailu report s volbou **On demand via the API** (Reports → API Templates), jeho ID do `REPORT_TEMPLATE_ID`.
- Jenkins musí běžet pod přihlášeným uživatelem s viditelnou plochou (ne jako Windows služba),
  jinak FlaUI testy nefungují. Na stroji musí být Python 3.12, Git, PowerShell a klasický Notepad.

## Import do jiného Jenkinsu

```
curl -X POST "http://localhost:8080/createItem?name=TestRail-FlaUI-Notepad" ^
  --user "uzivatel:jenkins_api_token" ^
  -H "Content-Type: application/xml" ^
  --data-binary "@jenkins/TestRail-FlaUI-Notepad.xml"
```

Případně ručně: New Item → Freestyle project a nastavení podle XML a `build-step.bat`.
