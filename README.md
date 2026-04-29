API Automation Framework 
📖 Overview

This project is an end-to-end API test automation framework built using Robot Framework to validate the functionality, reliability, and behavior of the  public API.

It covers:

CRUD operations
Authentication & authorization
Negative testing
Request chaining
Nested resource validation
Pagination & headers
ML-based anomaly detection
🚀 Tech Stack
Robot Framework
RequestsLibrary
Python (Custom Utilities)
CSV-based data handling
🌐 API Under Test


Resources Covered
Users
Posts
Comments
Todos (partially explored)
🔐 Authentication
Bearer Token based authentication
Used for:
POST
PUT / PATCH
DELETE
🧪 Test Coverage
✅ 1. CRUD Operations
Create User
Retrieve User
Update User (PUT & PATCH)
Delete User
Verify deletion (404)
🔄 2. End-to-End Request Chaining

Validated full workflow:

Create User → Get User → Update User → Delete User → Verify Deletion

Also implemented:

User → Post → Comment flow

Includes:

Dynamic ID extraction
Data passing across requests
Cross-resource validation
🔗 3. Nested Resource Testing
User → Posts
Post → Comments

Validations include:

Correct relationship mapping
Data consistency across entities
❌ 4. Negative Testing
Missing fields
Invalid email formats
Duplicate email validation
Invalid payload scenarios
Unsupported field handling
🔐 5. Authentication Testing
Valid token
Missing token
Invalid token

Validated:

Status codes
Error messages
📊 6. Response Validation
Status code validation
JSON schema validation
Data type validation
Field presence validation
Value constraints (gender, status)
📄 7. Header & Content Validation
Content-Type validation (application/json)
Header consistency checks
Accept header behavior
📚 8. Pagination Testing
Page navigation
Data uniqueness across pages
Page size validation
Edge cases:
Large page number
Negative page number
⚡ 9. Rate Limiting Observation
Headers validated:
x-ratelimit-limit
x-ratelimit-remaining
x-ratelimit-reset
Observed:
No strict enforcement
🤖 10. ML-based anomaly detection
ML analyzes and classifies test data anomalies
CSV-driven test execution
anomaly_score
ml_label
🏗️ Framework Design

The framework is modular and organized using Robot Framework resource files:

🔹 Service Keywords
Direct API calls only
No assertions
Example:
Create user
Get users
Delete user
🔹 Flow Keywords
Business logic & chaining
Multi-step workflows
Example:
User → Post → Comment flow
Update user with mutation
🔹 Validation Keywords
Assertions & verifications
Response validation logic
Schema & data checks
🔹 Utility Layer
Data generation
CSV reading
AI/ML dataset generation

Project structure
api-test-automation/
│
├── tests/
│   ├── smoke/
│   │   └── user_smoke_tests.robot
│   │
│   ├── regression/
│   │   ├── user_tests.robot
│   │   ├── auth_tests.robot
│   │   ├── validation_tests.robot
│   │   ├── chaining_tests.robot
│   │   └── ai_tests.robot
│
├── resources/
│   │
│   ├── keywords/
│   │   ├── suite_setup_keywords.robot
│   │   ├── user_flow_keywords.robot
│   │   ├── user_service_keywords.robot
│   │   ├── auth_keywords.robot
│   │   ├── common_keywords.robot
│   │   ├── user_validation_keywords.robot
│   │   ├── chaining_keywords.robot
│   │   └── ai_keywords.robot
│   │
│   ├── variables/
│   │   └── config.robot
│   │
│   ├── utils/
│   │   ├── data_generator.py
│   │   ├── csv_reader.py
│   │   └── ai_utils.py
│
├── data/
│   ├── invalid_emails.csv
│   └── ai_ml_test_data.csv
│
├── results/
│
└── README.md
