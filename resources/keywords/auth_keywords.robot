*** Settings ***
Library    RequestsLibrary
Library    ../utils/data_generator.py
Resource    ../variables/config.robot
Resource    common_keywords.robot

*** Keywords ***
# Create user request without Authorization header (negative scenario)
Create User Without Token
    ${headers}=    Create Headers    ${EMPTY}
    ${user}=    Generate Random User

    ${response}=    POST    ${BASE_URL}/users
    ...    json=${user}
    ...    headers=${headers}
    ...    expected_status=any

    RETURN     ${response} 

# Create user request with invalid token (negative scenario)
Create User With Invalid Token
    ${headers}=    Create Headers    ${INVALID_TOKEN}
    ${user}=    Generate Random User

    ${response}=    POST    ${BASE_URL}/users
    ...    json=${user}
    ...    headers=${headers}
    ...    expected_status=any

    RETURN     ${response}

Validate Auth Failure
    [Arguments]    ${response}    ${expected_message}

    Should Be Equal As Integers    ${response.status_code}    401

    ${json}=    Set Variable    ${response.json()}
    Should Contain    ${json["message"]}    ${expected_message}

#Missing token should fail authentication    
Verify Missing Token 
    ${response}=    Create User Without Token
    Validate Auth Failure    ${response}    Authentication failed
    
#Invalid token should fail authentication
Verify Invalid Token
    ${response}=    Create User With Invalid Token
    Validate Auth Failure    ${response}    Invalid token  