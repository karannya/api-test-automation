from faker import Faker
import random
import numpy as np
import csv
import os
import re
from sklearn.ensemble import IsolationForest

fake = Faker()
fake.seed_instance(42)

# CONFIG
VALID_GENDERS = ["male", "female"]
VALID_STATUS = ["active", "inactive"]

EMAIL_REGEX = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

# VALIDATORS 
def is_valid_email(email):
    return isinstance(email, str) and re.match(EMAIL_REGEX, email) is not None


def is_valid_gender(gender):
    return gender in VALID_GENDERS


def is_valid_status(status):
    return status in VALID_STATUS


def is_valid_name(name):
    return (
        isinstance(name, str)
        and len(name.strip()) > 1
        and re.match(r"^[A-Za-z ]+$", name) is not None
    )


# FEATURE ENGINEERING (ML INPUT)

def extract_features(user):
    return [
        len(user.get("name", "")),
        len(user.get("email", "")),
        user.get("email", "").count("@"),
        1 if is_valid_email(user.get("email", "")) else 0,
        1 if is_valid_gender(user.get("gender")) else 0,
        1 if is_valid_status(user.get("status")) else 0
    ]

# TRAIN ML MODEL (NORMAL ONLY)
def generate_normal_dataset(n=200):
    data = []

    for _ in range(n):
        user = {
            "name": fake.name(),
            "email": fake.unique.email(),
            "gender": random.choice(VALID_GENDERS),
            "status": random.choice(VALID_STATUS)
        }
        data.append(extract_features(user))

    return np.array(data)


model = IsolationForest(contamination=0.1, random_state=42)
model.fit(generate_normal_dataset())

# POSITIVE GENERATION
def generate_positive_user():
    return {
        "name": fake.name(),
        "email": fake.unique.email(),
        "gender": random.choice(VALID_GENDERS),
        "status": random.choice(VALID_STATUS),
        "expected_type": "positive"
    }

# EMAIL INVALID GENERATOR
def generate_invalid_email():
    patterns = [
        "invalid-email",
        "plainaddress",
        "@nouser.com",
        "user@.com",
        "user@@domain.com",
        "user@com",
        "user domain.com",
        "missingatsign.com"
    ]
    return random.choice(patterns)

# NEGATIVE GENERATION (STRUCTURED + ML FILTER)
def generate_negative_user():

    base = {
        "name": fake.name(),
        "email": fake.email(),
        "gender": random.choice(VALID_GENDERS),
        "status": random.choice(VALID_STATUS)
    }

    patterns = [
        # missing single fields
        lambda: {k: v for k, v in base.items() if k != "name"},
        lambda: {k: v for k, v in base.items() if k != "email"},
        lambda: {k: v for k, v in base.items() if k != "gender"},
        lambda: {k: v for k, v in base.items() if k != "status"},

        # invalid email regression set
        lambda: {**base, "email": generate_invalid_email()},

        # invalid enums
        lambda: {**base, "gender": "unknown"},
        lambda: {**base, "status": "invalid"},

        # empty values
        lambda: {"name": "", "email": "", "gender": "", "status": ""}
    ]

    candidate = random.choice(patterns)()
    candidate["expected_type"] = "negative"
    # ML filter (ensure anomaly)
    features = extract_features(candidate)
    if model.predict([features])[0] == -1:
        return candidate

    return candidate

# EDGE CASE GENERATION
def generate_edge_user():

    base = generate_positive_user()

    patterns = [
        lambda: {**base, "name": "A"},
        lambda: {**base, "name": "AB"},
        lambda: {**base, "name": "John"*50},
        lambda: {**base, "name": "John@Smith"},
        lambda: {**base, "email": fake.unique.email()},
        lambda: {**base, "email": "test+tag@gmail.com"},
        lambda: {**base, "email": "test.email@sub.domain.com"},
        lambda: {**base, "email": "a@b"},
        lambda: {**base, "name": " "},
        lambda: {**base, "email": ""},
    ]
    user = random.choice(patterns)()
    user["expected_type"] = "edge"
    return user

# DATASET GENERATION
def generate_dataset():
    dataset = []

    for _ in range(10):
        user = generate_positive_user()
        user.update(get_anomaly_insight(user))
        dataset.append(user)

    for _ in range(10):
        user = generate_negative_user()
        user.update(get_anomaly_insight(user))
        dataset.append(user)


    for _ in range(10):
         user = generate_edge_user()
         user.update(get_anomaly_insight(user))
         dataset.append(user)

    return dataset

# SAVE CSV
def save_to_csv(data, filename="ai_ml_test_data.csv"):

    import os

    # go to project root (api-test-automation)
    base_dir = os.path.abspath(
        os.path.join(os.path.dirname(__file__), "../../")
    )

    data_dir = os.path.join(base_dir, "data")

    file_path = os.path.join(data_dir, filename)

    with open(file_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["name", "email", "gender", "status", "expected_type", "ml_label", "anomaly_score"])
        writer.writeheader()
        writer.writerows(data)

    return file_path

# ENTRY POINT
def generate_test_data_with_ml_insights():
    data = generate_dataset()
    return save_to_csv(data)

def get_anomaly_insight(user):
    features = extract_features(user)
    prediction = model.predict([features])[0]
    score = model.decision_function([features])[0]

    return {
        "ml_label": "anomaly" if prediction == -1 else "normal",
        "anomaly_score": round(score, 3)
    }