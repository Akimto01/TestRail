# TestRail – cvičná integrace Robot Framework + FlaUI

Základní sada desktopových testů Poznámkového bloku (Windows) postavená na
[FlaUILibrary](https://github.com/GDATASoftwareAG/robotframework-flaui).
Cílem je vyzkoušet si zápis výsledků automatizovaných testů do TestRailu.

## Požadavky

- Windows 10 (lokátory jsou určené pro klasický Notepad, ve Windows 11 je potřeba je upravit)
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

## Další kroky (integrace s TestRailem)

1. V TestRailu založit test casy odpovídající testům v `tests/notepad.robot`.
2. Doplnit k testům tagy s ID casů z TestRailu.
3. Posílat výsledky do test runu (listener knihovny robotframework-testrail, nebo TRCLI z `output.xml`).
