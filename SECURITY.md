# Security Policy

## Supported version

Only the current `main` branch is supported.

## Reporting a vulnerability

Do not open a public issue for credentials, destructive behavior, or security vulnerabilities.

Contact the repository owner privately with:

- a concise description of the issue;
- reproduction steps;
- affected files or commands;
- potential impact.

Please do not include real credentials, private keys, or production data in reports.

## Secure usage

- Keep `.env` local and untracked.
- Replace all example PostgreSQL credentials.
- Use `--reset-db` only with `--yes-reset`.
- Review `--dry-run` output before running a new workflow against a project.
