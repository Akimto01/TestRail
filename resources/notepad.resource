*** Settings ***
Documentation     Sdílené keywordy a lokátory pro testy Poznámkového bloku (Notepad).
...               Lokátory jsou určené pro klasický Notepad (Windows 10, ve Windows 11 s vypnutým aliasem).
...               Editor je přímý potomek okna: ControlType Document, AutomationId 15 (ověřeno ve FlaUInspectu).
Library           FlaUILibrary    uia=UIA3    screenshot_on_failure=True    screenshot_dir=results/screenshots


*** Variables ***
${NOTEPAD_EXE}        notepad.exe
${MAIN_WINDOW}        //Window[@ClassName='Notepad']
${EDITOR}             ${MAIN_WINDOW}/Document[@AutomationId='15']
${SAVE_DIALOG}        ${MAIN_WINDOW}/Window[@ClassName='#32770']
${TEST_TEXT}          Ahoj z Robot Frameworku a FlaUI
${TIME_PATTERN}       \\d{1,2}:\\d{2}
${NOTEPAD_PID}        ${EMPTY}


*** Keywords ***
Open Notepad
    [Documentation]    Spustí Notepad, počká na hlavní okno a uloží PID pro teardown.
    ${pid}=    Launch Application    ${NOTEPAD_EXE}
    Set Test Variable    ${NOTEPAD_PID}    ${pid}
    Wait Until Element Exist    ${MAIN_WINDOW}

Close Notepad
    [Documentation]    Ukončí Notepad bez uložení (používá se v Test Teardown).
    ...                Pokud test selhal, nejdřív pořídí screenshot a připraví ho jako přílohu pro TestRail.
    Run Keyword If Test Failed    Attach Screenshot For TestRail
    IF    '${NOTEPAD_PID}' != '${EMPTY}'
        Close Application    ${NOTEPAD_PID}
    END

Type Into Editor
    [Arguments]    ${text}
    Set Text To Textbox    ${EDITOR}    ${text}

Editor Text Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Text From Textbox    ${EDITOR}
    Should Be Equal    ${actual}    ${expected}

Attach Screenshot For TestRail
    [Documentation]    Pořídí screenshot obrazovky a zapíše jeho cestu do dokumentace testu
    ...                ve tvaru, který TRCLI pozná a přiloží soubor k výsledku v TestRailu.
    ...                FlaUILibrary dělá screenshot sama jen při pádu vlastního keywordu,
    ...                proto ho tady pořizujeme vždy, když test selže.
    ${path}=    Take Screenshot
    ${abs_path}=    Evaluate    os.path.abspath(r"""${path}""")    modules=os
    Set Test Documentation    ${TEST DOCUMENTATION}\n- testrail_attachment: ${abs_path}
