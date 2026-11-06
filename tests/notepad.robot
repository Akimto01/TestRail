*** Settings ***
Documentation     Základní sada automatizovaných testů Poznámkového bloku pomocí FlaUILibrary.
...               Slouží jako cvičný projekt pro integraci výsledků s TestRailem.
...               Názvy testů mají formát jako v bance: NAME (EXTID, ATID), kde EXTID je ID casu v TestRailu.
Resource          ../resources/notepad.resource
Test Setup        Open Notepad
Test Teardown     Close Notepad


*** Test Cases ***
Spuštění Notepadu zobrazí prázdný editor - Pozitivní (C21, NOTEPAD001)
    [Tags]    ALL    NOTEPAD001    smoke
    Element Should Exist    ${EDITOR}
    Editor Text Should Be    ${EMPTY}

Zápis textu do editoru - Pozitivní (C19, NOTEPAD002)
    [Tags]    ALL    NOTEPAD002    smoke
    Type Into Editor    ${TEST_TEXT}
    Editor Text Should Be    ${TEST_TEXT}

Smazání celého textu pomocí Ctrl+A a Delete - Pozitivní (C18, NOTEPAD003)
    [Tags]    ALL    NOTEPAD003    regression
    Type Into Editor    ${TEST_TEXT}
    Press Keys    ${{["s'CTRL+A'", "s'DELETE'"]}}    ${EDITOR}
    Editor Text Should Be    ${EMPTY}

Vložení data a času klávesou F5 - Pozitivní (C17, NOTEPAD004)
    [Tags]    ALL    NOTEPAD004    regression
    Press Key    s'F5'    ${EDITOR}
    ${text}=    Get Text From Textbox    ${EDITOR}
    Should Match Regexp    ${text}    ${TIME_PATTERN}

Zavření s neuloženými změnami nabídne uložení - Pozitivní (C20, NOTEPAD005)
    [Tags]    ALL    NOTEPAD005    regression
    Type Into Editor    ${TEST_TEXT}
    Press Key    s'ALT+F4'    ${MAIN_WINDOW}
    Wait Until Element Exist    ${SAVE_DIALOG}
