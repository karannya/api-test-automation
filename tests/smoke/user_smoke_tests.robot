*** Settings ***
Library    RequestsLibrary
Resource    ../../resources/keywords/user_validation_keywords.robot
Resource    ../../resources/keywords/suite_setup_keywords.robot
Suite Setup        Create User For Suite
Suite Teardown     Delete User For Suite

*** Test Cases ***

Get All Users
    Validate Get All Users

Retrieve Created User
    Validate Retrieve Created User

Delete Created User
    Validate Delete User

Verify User Deletion
    Validate User Deletion
 