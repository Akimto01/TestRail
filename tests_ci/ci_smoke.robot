*** Settings ***
Documentation     Rychlé testy bez uživatelského rozhraní pro ověření CI pipeline
...               (GitHub Actions + TRCLI). Běží na Linuxu, nepotřebují FlaUI ani Notepad.
...               Názvy jsou ve formátu jako v bance: NAME (ATID).
Library           Collections
Library           String


*** Test Cases ***
Součet dvou čísel - Pozitivní (CISMOKE001)
    [Tags]    ALL    CISMOKE001    smoke
    ${vysledek}=    Evaluate    2 + 3
    Should Be Equal As Integers    ${vysledek}    5

Převod textu na velká písmena - Pozitivní (CISMOKE002)
    [Tags]    ALL    CISMOKE002    smoke
    ${text}=    Convert To Upper Case    testrail
    Should Be Equal    ${text}    TESTRAIL

Náhodné číslo leží v povoleném rozsahu - Pozitivní (CISMOKE003)
    [Tags]    ALL    CISMOKE003    smoke
    ${cislo}=    Evaluate    random.randint(1, 100)    modules=random
    Should Be True    1 <= ${cislo} <= 100

Seznam obchodů obsahuje Bill - Pozitivní (CISMOKE004)
    [Tags]    ALL    CISMOKE004    smoke
    ${obchody}=    Create List    Bond    Bill    Transfer
    List Should Contain Value    ${obchody}    Bill
