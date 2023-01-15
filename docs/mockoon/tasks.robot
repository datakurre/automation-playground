*** Settings ***

Library  RPA.HTTP
Library  RPA.Robocorp.WorkItems

*** Variables ***

${PARTICIPANTS_API}    %{PARTICIPANTS_API=http://localhost:3000}
${TOTAL}    6


*** Tasks ***
Fetch participants
    ${url}    Set variable    ${PARTICIPANTS_API}/users?total=${TOTAL}
    ${response}=    Http Get    ${url}
    ${users}=    Set Variable    ${response.json()}[users]

    Create Output Work Item
    Set Work Item Variable    participants    ${users}
    Save Work Item