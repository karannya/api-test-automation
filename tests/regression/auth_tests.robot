*** Settings ***
Library    RequestsLibrary
Resource    ../../resources/keywords/auth_keywords.robot

*** Test Cases ***
Verify Missing Token Scenario
    Verify Missing Token 

Verify Invalid Token Scenario
    Verify Invalid Token 
