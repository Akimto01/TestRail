*** Settings ***
Documentation     Sdílené keywordy a lokátory pro testy Poznámkového bloku (Notepad).
...               Lokátory jsou určené pro klasický Notepad ve Windows 10.
...               Ve Windows 11 má nový Notepad jinou strukturu, lokátory ověř ve FlaUInspectu.
Library           FlaUILibrary    uia=UIA3    screenshot_on_failure=True    screenshot_dir=results/screenshots


*** Variables ***
${NOTEPAD_EXE}        notepad.exe
${MAIN_WINDOW}        //Window[@ClassName='Notepad']
${EDITOR}             ${MAIN_WINDOW}//*[@ClassName='Edit']
${SAVE_DIALOG}        ${MAIN_WINDOW}/Window[@ClassName='#32770']
${TEST_TEXT}          Ahoj z Robot Frameworku a FlaUI
${NOTEPAD_PID}        ${EMPTY}


*** Keywords ***
Open Notepad
    [Documentation]    Spustí Notepad, počká na hlavní okno a uloží PID pro teardown.
    ${pid}=    Launch Application    ${NOTEPAD_EXE}
    Set Test Variable    ${NOTEPAD_PID}    ${pid}
    Wait Until Element Exist    ${MAIN_WINDOW}

Close Notepad
    [Documentation]    Ukončí Notepad bez uložení (používá se v Test Teardown).
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
