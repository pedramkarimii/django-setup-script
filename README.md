# Django Setup Scripts

This project contains scripts and configurations to set up a Django application with either SQLite or PostgreSQL as the database and commands to set up a reate a superuser with specified credentials. .
## Contents

- `setup_cleaner_sqlite.sh`: Script to clean up and set up a fresh SQLite database.
- `setup_postgresql_container.sh`: Script to set up a PostgreSQL container and initialize the database.
- `creat_a_super_user.py`: Custom Django management command to create a superuser.

## Prerequisites

- Docker and Docker Compose (for PostgreSQL setup)
- Python
- Django


## Scripts

### `setup_cleaner_sqlite.sh`

This script is used to set up a Django application using an SQLite database. It performs the following tasks:

1. Removes the existing SQLite database file to ensure a clean start.
2. Deletes all migration files except for `__init__.py` in the migrations directories of Django apps.
3. Creates new migrations for Django apps.
4. Applies the migrations to the database.
5. Creates a Django superuser with the specified credentials.
6. Starts the Django development server.

### Usage

```bash
./setup_cleaner_sqlite.sh
```


## Scripts

### `setup_postgresql_container.sh`

This script is used to set up a Django application using a PostgreSQL container. It performs the following tasks:

1. Removes any existing PostgreSQL container named `dbpostgres` forcefully.
2. Runs a new PostgreSQL container with the specified environment variables and settings.
3. Waits for PostgreSQL to be ready.
4. Drops existing tables to ensure a clean setup.
5. Creates new migrations for Django apps.
6. Applies the migrations to the database.
7. Inserts initial data into the `account_user` table.
8. Creates the `books` table and adds initial data.
9. Creates a Django superuser with the specified credentials.
10. Starts the Django development server.

### Usage

```bash
./setup_postgresql_container.sh
```


## Custom Management Command

### `creat_a_super_user.py`

The `creat_a_super_user.py` script is a Django management command that allows you to create a superuser with specified credentials if one does not already exist.

### Command Usage

To use this command, run the following from your Django project directory:

```bash
python manage.py creat_a_super_user --username <username> --email <email> --password <password> --phone_number <phone_number>
```


### Fork and Contribute

To contribute to the project, you can fork it and submit a pull request. Here’s how:

1. **Fork the repository from GitHub**: [Fork Repository](https://github.com/pedramkarimii/django-setup-script)

2. **Clone your forked repository**:

   ```bash
   git clone https://github.com/pedramkarimii/django-setup-script
   ```
3. **Navigate to the Project Directory**:

   ```bash
   cd django-setup-script
   ```
4. **Create a new branch for your changes**:

   ```bash
   git checkout -b my-feature-branch
   ```
5. **Make your changes and commit them**:

   ```bash
   git add .
   git commit -m "Description of your changes"
   ```
6. **Push your changes to your fork**:

   ```bash
   git push origin master
   ```

#### 7. Create a pull request on GitHub:

Go to your forked repository on GitHub and click the "New pull request" button. Follow the prompts to create a pull
request from your fork and branch to the original repository.

### Author

#### This project is developed and maintained by Pedram Karimi.