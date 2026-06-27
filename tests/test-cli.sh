#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/django-bootstrap.sh"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf -- "$TMP_DIR"
}
trap cleanup EXIT

fail() {
  printf 'test failure: %s\n' "$*" >&2
  exit 1
}

"$SCRIPT" --help >/dev/null

PROJECT_DIR="$TMP_DIR/project"
mkdir -p "$PROJECT_DIR"
touch "$PROJECT_DIR/manage.py" "$PROJECT_DIR/db.sqlite3"

env PYTHON_BIN=echo "$SCRIPT" \
  --project-root "$PROJECT_DIR" \
  --database sqlite \
  --reset-db \
  --yes-reset >"$TMP_DIR/output"

[[ ! -e "$PROJECT_DIR/db.sqlite3" ]] || fail "SQLite reset did not remove db.sqlite3."
grep -Fq "manage.py migrate" "$TMP_DIR/output" || fail "Migrate command was not issued."

if "$SCRIPT" --project-root "$PROJECT_DIR" --database mysql >/dev/null 2>&1; then
  fail "Unsupported database was accepted."
fi

touch "$PROJECT_DIR/db.sqlite3"
if "$SCRIPT" --project-root "$PROJECT_DIR" --database sqlite --deset-db >/dev/null 2>&1; then
  fail "Reset without confirmation was accepted."
fi

printf 'CLI tests passed.\n'
