# Security Policy

## Supported versions

Only the latest 2.x release on `main` receives security fixes.

## Reporting a vulnerability

Do not open a public issue. Report privately through GitHub private vulnerability reporting:

https://github.com/rciesielski3/quality-code-starter/security/advisories/new

This is a repository setting that the owner must enable. If the link is unavailable, open a public issue asking for a private contact channel, without including vulnerability details.

Please include affected files or versions, reproduction steps, and the expected impact.

## Response expectations

Best effort, no SLA. Target: acknowledge reports within 7 days.

## Scope

In scope: the template's tooling and configuration (scripts, lint/format/test config, CI workflows, dependency setup).

No secrets are stored in this repository. Issues in third-party dependencies should be reported upstream.

## Safeguards in this repository

- gitleaks runs as a pre-commit hook and over the full history in CI.
- `pnpm audit --prod` runs in CI.
- Dependabot keeps dependencies and actions up to date.
- GitHub Actions are pinned to commit SHAs.
- Workflows default to read-only permissions; only the release-please job has write access, scoped to that job.
