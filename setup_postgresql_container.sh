#! /usr/bin/env bash

# Remove any existing PostgreSQL container named dbpostgres forcefully.
docker rm -f dbpostgres

# Example: configure PostgreSQL container
# Run a new PostgreSQL container with the specified environment variables and settings.
docker run --name dbpostgres -e POSTGRES_PASSWORD=1234 -d --rm -p "5432:5432" -e PGDATA=/var/lib/postgresql/data/pgdata -v /docker/db:/var/lib/postgresql/data postgres:alpine

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to start..."
RETRIES=10
until docker exec -i dbpostgres pg_isready -U postgres || [ $RETRIES -eq 0 ]; do
  echo "Waiting for PostgreSQL server, $((RETRIES--)) remaining attempts..."
  sleep 2
done

# Exit if PostgreSQL did not start in time.
if [ $RETRIES -eq 0 ]; then
  echo "PostgreSQL did not start in time."
  exit 1
fi

echo "Setup complete: Delete migrations."
# Example: Drop existing tables to ensure a clean setup.
docker exec -i dbpostgres psql -U postgres -d dbpostgres -c "
DROP TABLE IF EXISTS django_session CASCADE;
"
echo "Setup complete: Dropped tables."
sleep 2

# Create new migrations for Django apps.
python manage.py makemigrations
echo "Setup complete: Created migrations."
sleep 2

# Apply the migrations to the database.
python manage.py migrate
echo "Setup complete: Applied migrations."
sleep 2

# Example: Insert initial data for the account_user table.
docker exec -i dbpostgres psql -U postgres -d dbpostgres -c "
INSERT INTO account_user (
    username, email, password, phone_number, last_login, create_time, update_time, is_deleted, is_active, is_admin, is_staff, is_superuser
) VALUES
    ('user1', 'user1@gmail.com', 'password@1', '09128355701', NULL, NOW(), NOW(), FALSE, TRUE, FALSE, FALSE, FALSE),
    ('user2', 'user2@gmail.com', 'password@2', '09128355702', NULL, NOW(), NOW(), FALSE, TRUE, FALSE, FALSE, FALSE),
    ('user3', 'user3@gmail.com', 'password@3', '09128355703', NULL, NOW(), NOW(), FALSE, TRUE, FALSE, FALSE, FALSE),
    ('user4', 'user4@gmail.com', 'password@4', '09128355704', NULL, NOW(), NOW(), FALSE, TRUE, FALSE, FALSE, FALSE),
    ('user5', 'user5@gmail.com', 'password@5', '09128355705', NULL, NOW(), NOW(), FALSE, TRUE, FALSE, FALSE, FALSE);
"

# Example: Create the books table and add initial data.
docker exec -i dbpostgres psql -U postgres -d dbpostgres -c "
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(200) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    UNIQUE (title, author, genre)
);
"
echo "Database setup complete."

# Example: Create a Django superuser with the specified credentials.
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
