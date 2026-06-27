# Django Bootstrap Toolkit

Safe, repeatable database setup for an **existing Django project**.

This toolkit does one job: it runs Django migrations and optionally starts a local PostgreSQL container. It does not delete migration files, accept credentials on the command line, create raw seed data, or start a development server.

## Features

- SQLite or local PostgreSQL setup.
- Explicit database reset protection with `--yes-reset`.
- PostgreSQL isolated in a dedicated Docker Compose volume.
- Optional interactive `createsuperuser` command.
- Dry-run mode for reviewing commands before execution.
- Shell syntax and CLI safety tests in GitHub Actions.

## Requirements

- Bash 4+
- Python available as `python` or through `PYTHON_BIN`
- An existing Django project with `manage.py`
- Docker Compose only when using PostgreSQL

## Quick start

Clone this repository, then run the bootstrap script from any directory.

```bash
./scripts/django-bootstrap.sh   --project-root /path/to/your-django-project   --database sqlite
```

The script runs:

```text
python manage.py migrate
```

## Local PostgreSQL

Create a local environment file first:

```bash
cp .env.example .env
```

Edit `.env` and replace the example password. Then start the isolated local PostgreSQL service and migrate your Django project:

```bash
./scripts/django-bootstrap.sh   --project-root /path/to/your-django-project   --database postgres   --start-postgres
```

The service is bound to `127.0.0.1` and uses a dedicated named volume.

## Resetting a database

Database reset is intentionally opt-in.

SQLite reset removes only the selected local SQLite file:

```bash
./scripts/django-bootstrap.sh   --project-root /path/to/your-django-project   --database sqlite   --reset-db   --yes-reset
```

PostgreSQL reset removes only this toolkit's Compose volume:

```bash
./scripts/django-bootstrap.sh   --project-root /path/to/your-django-project   --database postgres   --reset-db   --yes-reset
```

Existing Django migration files are never removed.

## Optional superuser creation

Use Django's interactive command, not command-line credentials:

```bash
./scripts/django-bootstrap.sh   --project-root /path/to/your-django-project   --create-superuser
```

## Dry run

Review generated commands without executing them:

```bash
./scripts/django-bootstrap.sh   --project-root /path/to/your-django-project   --database sqlite   --dry-run
```

## Testing

```bash
bash -n scripts/django-bootstrap.sh tests/test-cli.sh
bash tests/test-cli.sh
```

## Security

- Never commit `.env`.
- Replace all example values before using PostgreSQL outside local development.
- Do not pass passwords through command-line arguments.
- Report vulnerabilities privately; see [SECURITY.md](SECURITY.md).

## License

Licensed under the MIT License. See [LICENSE](LICENSE).
