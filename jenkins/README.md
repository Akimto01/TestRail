# Jenkins job TestRail-FlaUI-Notepad

Export konfigurace lokálního Jenkins jobu, který spouští FlaUI testy Notepadu a posílá
výsledky do TestRailu přes TRCLI, stejně jako na projektu.

- `TestRail-FlaUI-Notepad.xml` – kompletní konfigurace jobu (Freestyle), dá se naimportovat do Jenkinsu
- `build-step.bat` – čitelná kopie build stepu (Execute Windows batch command)

Soubory neobsahují žádná hesla ani API klíče. Přihlašovací údaje k TestRailu si job bere
z Jenkins credentials s ID `testrail-api` (typ Username with password: e-mail a API klíč)
a předává je do buildu jako proměnné `TESTRAIL_USER` a `TESTRAIL_API_KEY`.

## Co job dělá

1. Stáhne repo `Akimto01/TestRail` (větev `main`).
2. Vytvoří `.venv` a nainstaluje závislosti z `requirements.txt` (Robot Framework, FlaUILibrary, TRCLI).
3. Spustí `robot --outputdir results tests`.
4. Nahraje `results/output.xml` do TestRailu přes `trcli -n ... parse_robot --case-matcher auto`.
5. Publikuje výsledky přes Robot Framework plugin (prahy 100 % úspěch, 80 % unstable).

## Parametry buildu

| Parametr | Výchozí hodnota | Obdoba na projektu |
|---|---|---|
| `TAG` | smoke | `%TAG%` |
| `MILESTONE` | 3 | `%MILESTONE%` |
| `RUN_ID` | 4 | `--run-id` |
| `PROJECT_ID` | 2 | `--project-id` |
| `TESTRAIL_PROJECT` | Notepad – FlaUI | `--project` |
| `TESTRAIL_HOST` | https://vojta1trial.testrail.io | `-h` |

## Požadavky na Jenkins

- Pluginy: Git, Robot Framework, Credentials Binding.
- Credential `testrail-api` (Username with password).
- Jenkins musí běžet pod přihlášeným uživatelem s viditelnou plochou (ne jako Windows služba),
  jinak FlaUI testy nefungují. Na stroji musí být Python 3.12, Git a klasický Notepad.

## Import do jiného Jenkinsu

```
curl -X POST "http://localhost:8080/createItem?name=TestRail-FlaUI-Notepad" ^
  --user "uzivatel:jenkins_api_token" ^
  -H "Content-Type: application/xml" ^
  --data-binary "@jenkins/TestRail-FlaUI-Notepad.xml"
```

Případně ručně: New Item → Freestyle project a nastavení podle XML a `build-step.bat`.
