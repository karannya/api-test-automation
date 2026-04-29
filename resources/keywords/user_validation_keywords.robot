*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource    user_service_keywords.robot
Resource    user_flow_keywords.robot

*** Keywords ***
# Validate API returns all users successfully
Validate Get All Users
    ${response}=    Get All Users Data
    Validate Standard Response    ${response}    200 

# Validate retrieved user matches created user data    
Validate Retrieve Created User
    ${response}=    Retrieve Created User Data

    Validate Standard Response    ${response}    200

    ${json}=    Set Variable    ${response.json()}

    Dictionary Should Contain Key    ${json}    id

    Should Be Equal    ${json["name"]}    ${REQUEST_PAYLOAD["name"]}
    Should Be Equal    ${json["email"]}   ${REQUEST_PAYLOAD["email"]}
    Should Be Equal    ${json["gender"]}  ${REQUEST_PAYLOAD["gender"]}
    Should Be Equal    ${json["status"]}  ${REQUEST_PAYLOAD["status"]}

# Validate user update API modifies only intended fields
Validate Update User With Dynamic Data
    ${response}    ${updated_user}=    Update User With Random Field  

    Should Be Equal As Integers    ${response.status_code}    200

    ${response_json}=    Set Variable    ${response.json()}

    # Validate ONLY updated fields
    FOR    ${key}    ${value}    IN    &{updated_user}
        Should Be Equal    ${response_json["${key}"]}    ${value}
    END

# Validate user deletion returns correct status
Validate Delete User
    ${response}=    Delete Created User
    Should Be Equal As Integers    ${response.status_code}    204   

# Validate deleted user is no longer accessible (404)
Validate User Deletion
    ${response}=    Get Deleted User Response
    Should Be Equal As Integers    ${response.status_code}    404

# Validate duplicate email is rejected by API
Validate Duplicate Email
    ${response}=     Verify Existing Email  
    Should Be Equal As Integers    ${response.status_code}    422 

    ${response_json}=    Set Variable    ${response.json()}
    ${message}=    Set Variable    ${response_json[0]["message"]}

    Should Be Equal    ${message}    has already been taken

# Validate invalid email formats are rejected
 Validate Invalid Email 
    ${response}=    Verify Invalid Emailid  
    Should Be Equal As Integers    ${response.status_code}    422

    ${response_json}=    Set Variable    ${response.json()}
    ${message}=    Set Variable    ${response_json[0]["message"]}

    Should Be Equal    ${message}    is invalid       
