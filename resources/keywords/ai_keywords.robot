*** Settings ***
Library    ../utils/ai_utils.py
Library    Collections
Library    RequestsLibrary
Resource   user_flow_keywords.robot
Resource   common_keywords.robot


*** Keywords ***
# Generate dataset using ML insights (saved as CSV file)
Generate Test Data File With ML Insights
    ${file}=    Generate Test Data With Ml Insights
    Log To Console    Generated File: ${file}
    RETURN    ${file}

# Read generated ML dataset into dictionary format
Read AI ML Dataset
    [Arguments]    ${file}
    ${data}=    Read Csv As Dict    ${file}
    RETURN    ${data}

# Execute API tests 
Run User API Tests With ML Data
    [Arguments]    ${data}

    ${headers}=    Get Auth Headers

    FOR    ${row}    IN    @{data}

        ${payload}=    Create Dictionary
        ...    name=${row["name"]}
        ...    email=${row["email"]}
        ...    gender=${row["gender"]}
        ...    status=${row["status"]}

        ${response}=    POST    ${BASE_URL}/users
        ...    json=${payload}
        ...    headers=${headers}
        ...    expected_status=any

       # Log ML classification and anomaly score (for debugging/analysis)
        Log To Console    ML: ${row["ml_label"]} | Score: ${row["anomaly_score"]}

        Validate API Response    ${response}

    END
    
# Validate API response is within acceptable status range
Validate API Response
    [Arguments]    ${response}

    Should Be True    ${response.status_code} in [200, 201, 400, 401, 422]