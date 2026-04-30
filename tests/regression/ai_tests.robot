*** Settings ***
Resource    ../../resources/keywords/ai_keywords.robot
Resource    ../../resources/keywords/user_flow_keywords.robot

*** Test Cases ***

Generate Test Dataset File With ML Insights
    ${file}=    Generate Test Data File With ML Insights
    Set Suite Variable    ${AI_FILE}    ${file}

Run AI ML User API Tests
    ${data}=    Read AI ML Dataset    ${AI_FILE}
    Run User API Tests With ML Data    ${data}