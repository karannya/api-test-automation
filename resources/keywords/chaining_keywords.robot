*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource    common_keywords.robot
Resource    user_service_keywords.robot
Resource    ../variables/config.robot
*** Keywords ***
# Create a post for a given user_id
Create Post For User
    [Arguments]    ${user_id}

    ${headers}=    Get Auth Headers

    ${post}=    Create Dictionary
    ...    user_id=${user_id}
    ...    title=Test Post ${user_id}
    ...    body=This is a test post
    
    ${response}=    POST    ${BASE_URL}/posts
    ...    json=${post}
    ...    headers=${headers}
    
    Should Be Equal As Integers    ${response.status_code}    201

    ${json}=    Set Variable    ${response.json()}
    ${post_id}=    Set Variable      ${json["id"]}

    RETURN    ${post_id}    ${post}

## Create a comment for a given post using user details
Create Comment For Post 
    [Arguments]    ${post_id}    ${user}

    ${headers}=    Get Auth Headers 
    ${name}=     Get From Dictionary    ${user}    name
    ${email}=    Get From Dictionary    ${user}    email
    ${comment}=    Create Dictionary
    ...    post_id=${post_id}
    ...    name=${name} 
    ...    email=${email}
    ...    body=This is a test comment
    
    ${response}=    POST    ${BASE_URL}/comments
    ...    json=${comment}
    ...    headers=${headers}
    
    Should Be Equal As Integers    ${response.status_code}    201

     ${json}=    Set Variable    ${response.json()}
    ${comment_id}=    Set Variable      ${json["id"]} 
    RETURN    ${comment_id}    ${comment}

# Fetch comment details by comment_id
Get Comment By ID 
    [Arguments]    ${comment_id} 
    ${headers}=    Get Auth Headers

    ${response}=    GET    ${BASE_URL}/comments/${comment_id}
    ...    headers=${headers}

    Should Be Equal As Integers    ${response.status_code}    200     
    RETURN    ${response}

# End-to-end flow: create user → post → comment → validate response
Execute User Post Comment Flow
# Step 1: Create User
    ${response}    ${user}=    Create User With Dynamic Data 
    Should Be Equal As Integers    ${response.status_code}    201

    ${user_json}=    Set Variable    ${response.json()}
    ${user_id}=    Set Variable    ${user_json["id"]}

# Step 2: Create Post
    ${post_id}    ${post}=    Create Post For User    ${user_id}
    ${post_json}=    Set Variable    ${response.json()}

# Step 3: Create Comment
    ${comment_id}    ${comment}=    Create Comment For Post    ${post_id}    ${user}

# Step 4: Retrieve Comment 
    ${response}=    Get Comment By ID    ${comment_id}
    ${comment_json}=    Set Variable    ${response.json()} 

# Step 5: Validations
    Should Be Equal    ${comment_json["post_id"]}    ${post_id}
    Should Be Equal    ${comment_json["name"]}     ${user["name"]}
    Should Be Equal    ${comment_json["email"]}    ${user["email"]}    
              