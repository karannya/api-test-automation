*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource    ../variables/config.robot
Resource    user_service_keywords.robot
*** Keywords ***
# Build standard request headers with authorization token
Create Headers
    [Arguments]    ${token}
    ${headers}=    Create Dictionary
    ...    Authorization=${token}
    ...    Content-Type=application/json
    RETURN     ${headers}

# Validate response status code and content type
Validate Standard Response
    [Arguments]    ${response}    ${expected_status}
    
    Should Be Equal As Integers    ${response.status_code}    ${expected_status}

    ${content_type}=    Get From Dictionary    ${response.headers}    Content-Type
    Should Contain    ${content_type}    application/json

#Page 1 → collect users
#Page 2 → collect users 
#Compare:
# no duplicate IDs
#data exists
#API works

# Fetch users for a specific page using query parameter
Get Users By Page
    [Arguments]    ${page}

    ${headers}=    Get Auth Headers
    ${params}=    Create Dictionary    page=${page}
    ${response}=    GET    ${BASE_URL}/users
    ...    params=${params}
    ...    headers=${headers}

    RETURN     ${response}
    
# Validate pagination across pages    
Validate Pagination Navigation 
    ${all_ids}=    Create List  
    FOR    ${page}    IN RANGE    1    3
        ${response}=    Get Users By Page    ${page}
        Should Be Equal As Integers    ${response.status_code}    200

        ${json}=    Set Variable    ${response.json()}

        ${page_ids}=    Create List
        FOR    ${item}    IN    @{json}
            Append To List    ${page_ids}    ${item["id"]}
        END
       
         # Check duplicates across pages
        FOR    ${id}    IN    @{page_ids}
            List Should Not Contain Value    ${all_ids}    ${id}
        END

        # Add current page IDs to master list
        FOR    ${id}    IN    @{page_ids}
            Append To List    ${all_ids}    ${id}
        END
       
    END  
    Should Not Be Empty    ${all_ids}
    