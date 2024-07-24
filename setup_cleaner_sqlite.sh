#! /usr/bin/env bash

# Remove the existing SQLite database file to ensure a clean start.
rm -rf db.sqlite3

# Find and delete all migration files except for __init__.py in the migrations directories of Django apps.
find . -path "*/migrations/*.py" -not -name "__init__.py" -delete

# Create new migrations for Django apps.
python manage.py makemigrations
echo "Setup complete: Created migrations."
sleep 2

# Apply the migrations to the database.
python manage.py migrate
echo "Setup complete: Applied migrations."
sleep 2

# Create a Django superuser with the specified credentials.
echo "Creating superuser..."
python manage.py creat_a_super_user --username PedraKmarimi --email pedram.9060@gmail.com --password qwertyQ@1 --phone_number 09128355747
if [ $? -ne 0 ]; then
  echo "Failed to create superuser."
  exit 1
fi
echo "Setup complete: Created a superuser."
sleep 2

# Start the Django development server.
echo "Starting Django development server..."
python manage.py runserver