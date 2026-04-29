*** Settings ***
Library    RequestsLibrary
Resource    ../../resources/keywords/user_flow_keywords.robot
Resource    ../../resources/keywords/common_keywords.robot
Resource    ../../resources/keywords/user_validation_keywords.robot
Resource     ../../resources/keywords/ai_keywords.robot
*** Test Cases ***
Duplicate Email Validation
    Validate Duplicate Email
Invalid Email Validation
    Validate Invalid Email
Validate Response Headers   
    ${response}=    Get All Users Data
    Validate Standard Response    ${response}    200
Validate Pagination Navigation
    Validate Pagination Navigation        
   
