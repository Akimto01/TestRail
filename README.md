# TestRail – cvičná integrace Robot Framework + FlaUI

Základní sada desktopových testů Poznámkového bloku (Windows) postavená na
[FlaUILibrary](https://github.com/GDATASoftwareAG/robotframework-flaui).
Cílem je vyzkoušet si zápis výsledků automatizovaných testů do TestRailu.

## Požadavky

- Windows 10 nebo 11 s klasickým Notepadem. Ve Windows 11 vypni alias nového Notepadu:
  Nastavení → Aplikace → Rozšířené nastavení aplikací → Aliasy pro spouštění aplikací → Poznámkový blok (notepad.exe)
- Python 3.10 až 3.12 (kvůli pythonnet, na kterém FlaUILibrary stojí)
- .NET Framework 4.8 (ve Windows 10 bývá nainstalovaný)

## Instalace

```
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

## Spuštění

```
robot --outputdir results tests
```

Jen smoke testy:

```
robot --outputdir results --include smoke tests
```

## Struktura

- `tests/notepad.robot` – test casy
- `resources/notepad.resource` – lokátory a sdílené keywordy
- `results/` – výstupy běhu (log, report, output.xml, screenshoty), neverzuje se

## Hledání lokátorů

Strom prvků a jejich vlastnosti (ClassName, AutomationId, Name) zjistíš nástrojem
[FlaUInspect](https://github.com/FlaUI/FlaUInspect). Lokátory jsou XPath nad stromem
Microsoft UI Automation.

## Integrace s TestRailem

Výsledky se do TestRailu posílají nástrojem **TRCLI** (`trcli parse_robot`) až po doběhnutí testů,
stejně jako na projektu. Párování testů s casy probíhá přes pole **automation_id** v TestRailu
(`--case-matcher auto`), které se skládá z cesty k suite a názvu testu, např.
`Tests.Notepad.Zápis textu do editoru - Pozitivní (C19, NOTEPAD002)`.

Pozor: když se změní název testu nebo struktura složek, změní se i `automation_id`. S přepínačem
`-n` pak TRCLI case nenajde a výsledky nenahraje. Řešení je upravit `automation_id` u casu v TestRailu.

Přihlašovací údaje se čtou z proměnných prostředí, do repozitáře je nikdy neukládej:

```
setx TESTRAIL_USER "tvuj@email.cz"
setx TESTRAIL_API_KEY "api_klic_z_testrailu"
```

### Lokálně

```
.\run-testrail.ps1                  # spustí testy a nahraje výsledky do runu 4
.\run-testrail.ps1 -Include smoke   # jen smoke testy
.\run-testrail.ps1 -AutoCreate      # povolí TRCLI založit chybějící casy (-y)
```

### Jenkins

Job `TestRail-FlaUI-Notepad` dělá totéž: stáhne repo, spustí `robot` a pak `trcli` s parametry
buildu (`TAG`, `MILESTONE`, `RUN_ID`, …). Přihlašovací údaje bere z Jenkins credentials `testrail-api`.
Jenkins musí běžet pod přihlášeným uživatelem (ne jako služba), jinak FlaUI testy nefungují.

### GitHub Actions

Workflow `.github/workflows/ci-testrail.yml` spouští rychlé testy bez UI ze složky `tests_ci/`
na Linuxu a výsledky posílá přes TRCLI do nového runu. Přihlašovací údaje jsou v repository
secrets `TESTRAIL_USER` a `TESTRAIL_API_KEY`.
