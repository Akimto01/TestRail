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

Testy jsou namapované na test casy v TestRailu tagem `testrailid=<ID casu>` (C12 až C16 v projektu
„Notepad – FlaUI“). Výsledky se zapisují do test runu listenerem `TestRailListener` z balíčku
`u-robotframework-testrail` (fork knihovny robotframework-testrail, který funguje i s TestRail Cloud).

Přihlašovací údaje se čtou z proměnných prostředí, do repozitáře je nikdy neukládej:

```
setx TESTRAIL_USER "tvuj@email.cz"
setx TESTRAIL_API_KEY "api_klic_z_testrailu"
```

Spuštění s odesláním výsledků do runu R3:

```
.\run-testrail.ps1 -RunId 3
```
