"""Trusted-host owner enrollment/recovery. No passwords in command arguments."""
import argparse
import getpass
import os
from pymongo import MongoClient
from main import passwords, prepare

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['create', 'reset-password', 'disable'])
    parser.add_argument('email')
    args = parser.parse_args()
    email = args.email.strip().casefold()
    if '@' not in email or len(email) > 254:
        parser.error('Supply a valid owner email')
    with MongoClient(os.environ['MONGODB_URI'], serverSelectionTimeoutMS=5000) as client:
        db = client[os.getenv('MONGODB_DATABASE', 'splash')]
        prepare(db)
        account = db.owners.find_one({'email': email})
        if args.action == 'create' and account:
            parser.error('Owner already exists; use reset-password')
        if args.action != 'create' and not account:
            parser.error('Owner not found')
        if args.action == 'disable':
            db.owners.update_one({'_id': account['_id']}, {'$set': {'active': False}})
        else:
            password = getpass.getpass('New password (at least 12 characters): ')
            if len(password) < 12 or len(password) > 1024 or password != getpass.getpass('Confirm password: '):
                parser.error('Passwords must match and contain 12–1024 characters')
            values = {'email': email, 'password_hash': passwords.hash(password), 'active': True}
            if args.action == 'create':
                db.owners.insert_one(values)
            else:
                db.owners.update_one({'_id': account['_id']}, {'$set': values})
        if account:
            db.sessions.delete_many({'owner_id': account['_id']})
        print('Owner account updated.')

if __name__ == '__main__':
    main()
