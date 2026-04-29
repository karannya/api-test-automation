from faker import Faker
import random
fake=Faker()    #Create a Faker object

def generate_random_user():
    return {
        "name": fake.name(),
        "email":fake.unique.email(),
        "gender":random.choice(['male','female']),
        "status":random.choice(['active','inactive']),
    }
     
