## API Automation Framework 

This project is a keyword-driven API test automation framework built with Robot Framework, featuring end-to-end CRUD validation, request chaining, and data-driven testing.

It also includes an ML-based test data enrichment pipeline, where an unsupervised machine learning model (Isolation Forest) is used to analyze and classify test payloads as normal or anomalous after they are generated using Faker and rule-based logic.

## Overview

This project was built against the [GoRest public REST API](https://gorest.co.in/public/v2) and covers the full quality-assurance lifecycle: 

manual exploratory testing → documented test cases → automated regression suites → ML-assisted test data classification for enhanced edge-case visibility.

## Tech Stack

| Layer | Tool / Library |
|---|---|
| Test framework | Robot Framework |
| HTTP client | RequestsLibrary |
| Data generation | Faker, Python |
| ML / anomaly detection | scikit-learn (Isolation Forest) |
| Data-driven testing | CSV (static) + ML-generated CSV |
| Language | Python 3 |
---
## Test Coverage

### Smoke Tests 
Quick confidence check covering the essential user lifecycle: create → retrieve → delete → verify deletion.

### Regression Tests
| Suite | Scenarios Covered |
|---|---|
| `user_tests` | Dynamic PATCH with random field mutation |
| `auth_tests` | Missing token, invalid token |
| `validation_tests` | Duplicate email, invalid email formats, response headers, pagination |
| `chaining_tests` | User → Post → Comment end-to-end flow |
| `ai_tests` | Executes API tests using ML-enriched dataset (Faker + rule-based + Isolation Forest anomaly scoring) across 30 payloads |

### Full Test Case Summary

30 documented test cases across 10 test scenarios, including:
- CRUD operations 
- Field validation: mandatory fields, email format/uniqueness, gender enum 
- Authentication: missing/invalid token 
- Negative testing: non-existent IDs, extra fields, empty body 
- Response validation: headers, status codes, schema 
- Request chaining: User→Post and User→Post→Comment 
- Error handling: invalid JSON, inconsistent error codes 
- Headers/content-type validation 
- Pagination: navigation, page size, edge cases 
- Rate limiting 

## AI / ML Integration

This project integrates a lightweight machine learning pipeline to enhance test data analysis and classification.

**1. Feature Engineering**
Each API payload is converted into numerical features such as:

Length of name and email
Presence of special characters (e.g., "@")
Validation checks for email format, gender, and status

**2. Model Training**
An unsupervised Isolation Forest model is trained using 200 synthetically generated valid user records.
The model learns the statistical pattern of “normal” API payloads without requiring labeled data.

**3. Dataset Generation**
Test data is generated in three categories:

Positive: Valid API payloads
Negative: Missing fields, invalid formats, incorrect enum values
Edge: Boundary cases such as very short names, malformed emails, and empty values

**4. Anomaly Scoring**
Each generated payload is scored by the ML model:

ml_label: normal / anomaly
anomaly_score: deviation score from learned normal behavior

These results are stored in a CSV file alongside the test dataset.

**5. Robot Framework Integration**
The generated dataset is consumed by Robot Framework tests, where each payload is sent to the API and validated against expected HTTP responses.

## Key Findings

| Status | Area | Observation |
|---|---|---|
| ✅ Pass | CRUD, Authentication, Validation | Core API operations behave as expected with correct status codes and responses |
| ⚠️ Observation | Authentication Handling | Unauthorized write operations return `404` instead of expected `401/403` |
| ⚠️ Observation | PATCH Operations | Empty PATCH requests return `200 OK` with no validation error (`400/422` expected) |
| ⚠️ Observation | Request Validation | Unknown fields in payload are silently ignored by the API |
| ⚠️ Observation | Pagination Edge Case | Negative page values (e.g., `page=-1`) return data instead of validation error (`400`) |
| ❌ Issue | Comment API (Invalid JSON) | Returns `401` instead of expected `400/422` for malformed payload |
| ❌ Issue | PATCH Error Handling | Invalid PATCH payload results in `502 Bad Gateway` |
| ❌ Issue | Rate Limiting | API rate limit counters do not decrement consistently under repeated requests |

## Setup

### Prerequisites
- Python 3.9+
- pip

### Install dependencies

```bash
pip install robotframework
pip install robotframework-requests
pip install faker
pip install scikit-learn numpy
```

## Running Tests

```bash
# Run all tests
robot tests/

# Run smoke tests only
robot tests/smoke/

# Run regression tests
robot tests/regression/

# Run a specific suite
robot tests/regression/chaining_tests.robot

# Run with a custom output directory
robot --outputdir results/ tests/
```

## Project Structure

```
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
```