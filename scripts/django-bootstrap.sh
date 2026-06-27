#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$PWD"
DATABASE="sqlite"
RESET_DB=false
CONFIRM_RESET=false
START_POSTGRES=false
CREATE_SUPERUSER=false
DRY_RUN=false
PYTHON_BIN="${PYTHON_BIN:-python}"
SQLITE_DB_PATH="${SQLITE_DB_PATH:-db.sqlite3}"
COMPOSE_FILE="$SCRIPT_DIR/compose.postgres.yaml"
ENV_FILE="$SCRIPT_DIR/.env"

usage() {
  cat <<'USAGE'
Usage:
  django-bootstrap.sh [options]

Run safe, repeatable Django database setup from a Django project directory.

Options:
  --project-root PATH      Django project directory containing manage.py.
  --database NAME          sqlite or postgres. Default: sqlite.
  --start-postgres         Start the bundled local PostgreSQL Compose service.
  --reset-db               Reset only the selected local database.
  --yes-reset              Required with --reset-db.
  --create-superuser       Run Django's interactive createsuperuser command.
  --dry-run                Print commands without executing them.
  -h, --help               Show this help message.

Safety:
  - Existing migration files are never deleted.
  - Superuser credentials are never accepted as command-line arguments.
  - --reset-db requires --yes-reset.
  - PostgreSQL resets affect only this toolkit's Compose volume.
USAGE
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  printf '+ '
  printf '%q ' "$@"
  printf '\n'

  if [[ "$DRY_RUN" == false ]]; then
    "$@"
  fi
}

require_manage_py() {
  [[ -f "$PROJECT_ROOT/manage.py" ]] || die "manage.py was not found in: $PROJECT_ROOT"
}

validate_sqlite_path() {
  [[ "$SQLITE_DB_PATH" != /* ]] || die "SQLITE_DB_PATH must be relative to the project root."
  [[ "$SQLITE_DB_PATH" != *".."* ]] || die "SQLITE_DB_PATH must not contain '..'."
}

compose() {
  [[ -f "$ENV_FILE" ]] || die "Create $ENV_FILE from .env.example before using PostgreSQL."
  run docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" "$@"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root)
      [[ $# -ge 2 ]] || die "--project-root requires a path."
      PROJECT_ROOT="$2"
      shift 2
      ;;
    --database)
      [[ $# -ge 2 ]] || die "--database requires sqlite or postgres."
      DATABASE="$2"
      shift 2
      ;;
    --start-postgres)
      START_POSTGRES=true
      shift
      ;;
    --reset-db)
      RESET_DB=true
      shift
      ;;
    --yes-reset)
      CONFIRM_RESET=true
      shift
      ;;
    --create-superuser)
      CREATE_SUPERUSER=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
done

case "$DATABASE" in
  sqlite|postgres) ;;
  *) die "--database must be sqlite or postgres." ;;
esac

PROJECT_ROOT="$(cd -- "$PROJECT_ROOT" && pwd)"
require_manage_py

if [[ "$RESET_DB" == true && "$CONFIRM_RESET" != true ]]; then
  die "--reset-db requires --yes-reset."
fi

cd -- "$PROJECT_ROOT"

if [[ "$DATABASE" == "sqlite" ]]; then
  validate_sqlite_path

  if [[ "$RESET_DB" == true ]]; then
    run rm -f -- "$PROJECT_ROOT/$SQLITE_DB_PATH"
  fi
else
  if [[ "$RESET_DB" == true ]]; then
    compose down -v --remove-orphans
    START_POSTGRES=true
  fi

  if [[ "$START_POSTGRES" == true ]]; then
    compose up -d --wait
  fi
fi

run "$PYTHON_BIN" manage.py migrate

if [[ "$CREATE_SUPERUSER" == true ]]; then
  run "$PYTHON_BIN" manage.py createsuperuser
fi

printf 'Bootstrap completed for %s using %s.\n' "$PROJECT_ROOT" "$DATABASE"
