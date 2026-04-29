import csv

def get_invalid_emails(path):
    emails=[]
    with open(path, newline='')as f:
        reader= csv.DictReader(f)
        for row in reader:
            emails.append(row['email'])
    return emails   

def read_csv_as_dict(path):
    data = []

    with open(path, newline='') as f:
        reader = csv.DictReader(f)

        for row in reader:
            data.append(dict(row))

    return data     