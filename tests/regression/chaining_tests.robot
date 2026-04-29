*** Settings ***
Library    RequestsLibrary
Resource    ../../resources/keywords/chaining_keywords.robot

*** Test Cases ***
User → Post → Comment Flow
    Execute User Post Comment Flow