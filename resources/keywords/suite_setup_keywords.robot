*** Settings ***
Library    RequestsLibrary
Resource    user_service_keywords.robot
*** Keywords ***
# Suite setup
Create User For Suite
    ${response}    ${user}=    Create User With Dynamic Data

    Should Be Equal As Integers    ${response.status_code}    201
     ${response_json}=    Set Variable    ${response.json()} 

    Set Suite Variable    ${USER_ID}    ${response_json["id"]}
    Set Suite Variable    ${REQUEST_PAYLOAD}   ${user}
# Suite teardown 
#Clean environment
Delete User For Suite 
    Run Keyword And Ignore Error    Delete Created User        
    