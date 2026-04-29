*** Settings ***
Library    RequestsLibrary
Resource    ../../resources/keywords/user_flow_keywords.robot

Suite Setup        Create User For Suite
Suite Teardown     Delete User For Suite

*** Test Cases ***
Validate Updated User With Random Data
     Update User With Random Field
