*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    ../utils/data_generator.py
Library    ../utils/csv_reader.py
Resource    suite_setup_keywords.robot
Resource    ../variables/config.robot
Resource    common_keywords.robot
Resource    user_service_keywords.robot

*** Keywords *** 
# Mutate one random field in user payload (used for update testing)
Mutate User Payload
    [Arguments]    ${user}
    ${updated}=    Copy Dictionary    ${user}
    # generate random value properly
    ${rand}=    Evaluate    random.randint(1000,9999)    modules=random
    # choose random field
    ${field}=    Evaluate    random.choice(["name","email","gender","status"])    modules=random

    IF     '${field}' == 'name'
        ${name}=       Get From Dictionary      ${updated}      name
        Set To Dictionary    ${updated}    name=${name}_U_${rand}
        
    ELSE IF    '${field}' == 'email'
        ${email}=      Get From Dictionary      ${updated}      email
        Set To Dictionary    ${updated}    email=${name}_U_${rand}@test.com
    
     ELSE IF    '${field}' == 'gender'
        ${gender}=     Get From Dictionary      ${updated}      gender
        ${new_gender}=    Set Variable If    '${gender}'=='male'    female    male
        Set To Dictionary    ${updated}    gender=${new_gender} 

     ELSE IF     '${field}' == 'status'  
    ${status}=     Get From Dictionary      ${updated}      status
    ${new_status}=    Set Variable If    '${status}'=='active'    inactive    active
    Set To Dictionary    ${updated}    status=${new_status} 
    
    END
    Log To Console    Updated field: ${field}
    RETURN     ${updated}

# Update user with mutated payload and return response + updated data
Update User With Random Field
     ${updated_user}=    Mutate User Payload    ${REQUEST_PAYLOAD} 
    
     ${headers}=    Get Auth Headers     
     ${response}=    PATCH    ${BASE_URL}/users/${USER_ID}    
     ...    json=${updated_user}     
     ...    headers=${headers}
     RETURN     ${response}    ${updated_user}

# Validate duplicate email scenario by reusing an existing email         
Verify Existing Email 
     ${headers}=    Get Auth Headers 
    # create base user inside keyword
    ${base_user}=    Generate Random User
     ${response1}=    POST    ${BASE_URL}/users
    ...    json=${base_user}
    ...    headers=${headers}
    ...    expected_status=any
    
    ${response_json}=    Set Variable    ${response1.json()}
    ${existing_email}=      Set Variable    ${response_json["email"]}

    # reuse email
    ${new_user}=    Generate Random User 
    # Override email with existing one
    Set To Dictionary    ${new_user}    email=${existing_email}

    ${response2}=    POST    ${BASE_URL}/users    
     ...    headers=${headers}
     ...    json=${new_user}
    ...    expected_status=any
    
    RETURN     ${response2} 

# Fetch invalid emails from CSV file      
Fetch Invalid Emails
    ${emails}=    Get Invalid Emails    ${INVALID_EMAIL_CSV_PATH}
    RETURN     ${emails}

 # Validate invalid email scenarios using dataset     
Verify Invalid Emailid  
    ${emails}=    Fetch Invalid Emails
    Log    ${emails}

    ${headers}=    Get Auth Headers
      
    FOR    ${email}    IN    @{emails}
        ${user}=    Generate Random User
        Set To Dictionary    ${user}    email=${email}

        ${response}=    POST    ${BASE_URL}/users 
        ...    headers=${headers} 
        ...    json=${user}
        ...    expected_status=any
    END 
    RETURN    ${response}

