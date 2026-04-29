*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    ../utils/data_generator.py
Library    ../utils/csv_reader.py
Resource    suite_setup_keywords.robot
Resource    ../variables/config.robot
Resource    common_keywords.robot


*** Keywords ***
# Build authorization headers using token from config
Get Auth Headers
    ${headers}=    Create Headers    Bearer ${TOKEN}
    RETURN    ${headers}  

# Fetch all users from API        
Get All Users Data
     ${headers}=    Get Auth Headers
     ${response}=    GET    ${BASE_URL}/users    
     ...    headers=${headers}
     RETURN     ${response}  

# Create a new user with randomly generated data
Create User With Dynamic Data 
    ${user}=    Generate Random User
    ${headers}=    Get Auth Headers
    ${response}=    POST    ${BASE_URL}/users    
    ...    json=${user}    
    ...    headers=${headers}
    RETURN     ${response}    ${user}

# Retrieve user details using USER_ID (set in suite setup)
Retrieve Created User Data
     ${headers}=    Get Auth Headers     
     ${response}=    GET    ${BASE_URL}/users/${USER_ID}     
     ...    headers=${headers}
     RETURN     ${response} 


# Delete user using USER_ID     
Delete Created User  
     ${headers}=    Get Auth Headers     
     ${response}=    DELETE    ${BASE_URL}/users/${USER_ID}     
     ...    headers=${headers}
     RETURN     ${response}  

# Verify user is deleted
Get Deleted User Response
    ${headers}=    Get Auth Headers    
    ${response}=    GET    ${BASE_URL}/users/${USER_ID}     
    ...    headers=${headers}    
    ...    expected_status=any   #expected_status=any allows 404 safely
    RETURN     ${response}      