*** Settings ***
Documentation     Základní sada automatizovaných testů Poznámkového bloku pomocí FlaUILibrary.
...               Slouží jako cvičný projekt pro integraci výsledků s TestRailem.
Resource          ../resources/notepad.resource
Test Setup        Open Notepad
Test Teardown     Close Notepad


*** Test Cases ***
Spuštění Notepadu zobrazí prázdný editor
    [Tags]    smoke
    Element Should Exist    ${EDITOR}
    Editor Text Should Be    ${EMPTY}

Zápis textu do editoru
    [Tags]    smoke
    Type Into Editor    ${TEST_TEXT}
    Editor Text Should Be    ${TEST_TEXT}

Smazání celého textu pomocí Ctrl+A a Delete
    [Tags]    regression
    Type Into Editor    ${TEST_TEXT}
    Press Keys    ${{["s'CTRL+A'", "s'DELETE'"]}}    ${EDITOR}
    Editor Text Should Be    ${EMPTY}

Vložení data a času klávesou F5
    [Tags]    regression
    Press Key    s'F5'    ${EDITOR}
    ${text}=    Get Text From Textbox    ${EDITOR}
    Should Match Regexp    ${text}    \\d{1,2}:\\d{2}

Zavření s neuloženými změnami nabídne uložení
    [Tags]    regression
    Type Into Editor    ${TEST_TEXT}
    Press Key    s'ALT+F4'    ${MAIN_WINDOW}
    Wait Until Element Exist    ${SAVE_DIALOG}
