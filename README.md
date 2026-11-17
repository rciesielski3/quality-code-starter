# Quality Code Starter

[![CI](https://github.com/rciesielski3/quality-code-starter/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/rciesielski3/quality-code-starter/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Strict TypeScript starter with one local and CI quality gate: format, type-aware lint, typecheck, tests with coverage, commit and secret checks.

## Quick Start

Prerequisites:

- Node 22 (`.nvmrc`).
- pnpm 9 (see `packageManager` in `package.json`); `corepack enable` provides it.
- [gitleaks](https://github.com/gitleaks/gitleaks#installing). The pre-commit hook fails closed without it.

```sh
pnpm install   # also installs the husky hooks
pnpm verify    # format:check, lint, typecheck, test:coverage, check:agents
pnpm fix       # eslint --fix, then prettier --write
```

## What's enforced

| Check                  | Tool                                                           | Runs                                                      |
| ---------------------- | -------------------------------------------------------------- | --------------------------------------------------------- |
| Format                 | Prettier                                                       | pre-commit (staged files, writes), pre-push, CI `verify`  |
| Lint                   | typescript-eslint `strictTypeChecked` + `stylisticTypeChecked` | pre-commit (staged files, `--fix`), pre-push, CI `verify` |
| Typecheck              | `tsc --noEmit`                                                 | pre-push, CI `verify`                                     |
| Unit tests, coverage   | Vitest, v8; 90% lines/functions/branches/statements            | pre-push, CI `verify`                                     |
| Commit message         | commitlint (`config-conventional`)                             | commit-msg                                                |
| No AI trailers         | `.claude/hooks/no-ai-trailers.sh`                              | commit-msg                                                |
| Secrets                | gitleaks                                                       | pre-commit (staged); CI `gitleaks` (full history)         |
| PR title               | commitlint                                                     | CI `pr-title`                                             |
| Dependency audit       | `pnpm audit --prod --audit-level high`                         | CI `audit`                                                |
| Agent setup validation | `scripts/check-agents.mjs`                                     | pre-push, CI `verify`                                     |
| Template self-test     | `pnpm test:template`                                           | CI `template-smoke`                                       |
| Dependency updates     | Dependabot (npm minor/patch, github-actions)                   | scheduled                                                 |
| Releases               | release-please                                                 | on push to `main`                                         |

Pre-push runs `pnpm verify`, so it covers every `verify` step.

## Scripts

| Script               | Command                                                               |
| -------------------- | --------------------------------------------------------------------- |
| `pnpm verify`        | format:check, lint, typecheck, test:coverage, check:agents            |
| `pnpm fix`           | lint:fix, format                                                      |
| `pnpm lint`          | `eslint .`                                                            |
| `pnpm lint:fix`      | `eslint . --fix`                                                      |
| `pnpm format`        | `prettier . --write`                                                  |
| `pnpm format:check`  | `prettier . --check`                                                  |
| `pnpm typecheck`     | `tsc -p tsconfig.json --noEmit`                                       |
| `pnpm test`          | `vitest run`                                                          |
| `pnpm test:coverage` | `vitest run --coverage`                                               |
| `pnpm check:agents`  | validate `.claude` agents, `settings.json` and the `AGENTS.md` roster |
| `pnpm test:template` | smoke test of the template itself (CI `template-smoke`)               |

## Agent setup

The Claude Code setup lives at the repo root and is meant to be reused in other projects:

- `CLAUDE.md`: how to work (orchestration loop, workflow, repo policy, commits, gate).
- `AGENTS.md`: the agent roster (`implementer`, `qa-engineer`, `reviewer`, `security-auditor`) and project facts.
- `.claude/`: `settings.json` (permissions and empty commit/PR attribution), `agents/`, and `hooks/no-ai-trailers.sh` (commit-msg hook rejecting Claude co-author, session and "Generated with" trailers).

It maps onto the gate: the orchestrator delegates to `implementer`, `qa-engineer` runs `pnpm verify`, `reviewer` reviews before each commit and the PR, and the loop repeats until the gate is green. The husky hooks enforce the same rules without the agent, and `pnpm check:agents` keeps agent files, `settings.json` and the `AGENTS.md` roster in sync.

`.claude/settings.local.json` and `CLAUDE.local.md` are gitignored personal overrides.

To install into another project, use a clean checkout (or `git archive` output) of this repo as `KIT`, so no local files are copied:

```sh
export KIT=/path/to/checkout
```

Then run from the target project root:

<!-- prettier-ignore-start -->
<!-- agent-setup-install -->
```sh
mkdir -p .claude && cp -R "$KIT/.claude/." .claude/
cp -n "$KIT/CLAUDE.md" "$KIT/AGENTS.md" .
grep -qF no-ai-trailers.sh .husky/commit-msg || printf 'sh .claude/hooks/no-ai-trailers.sh "$1"\n' >> .husky/commit-msg
```
<!-- prettier-ignore-end -->

- The copy overwrites existing `.claude` settings and agents; back them up first. `CLAUDE.md` and `AGENTS.md` are not overwritten (`cp -n`).
- Requires a husky v8 `.husky/commit-msg` hook with the commitlint line first; the trailer check is appended after it.
- Edit `AGENTS.md` for the target project and review the permissions in `.claude/settings.json` before use.

## Using as a template

1. Click "Use this template" on GitHub.
2. Change the package name in `package.json`, the holder in `LICENSE`, and the `SECURITY.md` contact. Enable private vulnerability reporting in the repository settings.
3. Reset `.release-please-manifest.json` and `package.json` to your starting version, and delete `release-as` from `release-please-config.json` after your first release.
4. Branch protection on `main`: require a PR and the checks `verify`, `pr-title`, `audit`, `gitleaks`, `template-smoke`; squash merge only; linear history.

## Workflow

Changes land through a PR. The squash-merge title is a Conventional Commit (checked by `pr-title`) and becomes the changelog entry via release-please.

## Limits

- Type-aware lint only covers files in `tsconfig.eslint.json` (`src`, root `*.mts`/`*.cts`). Add new paths there, or lint fails with a parsing error.
- `.mjs` files are linted without type information.
- Commits are blocked until gitleaks is on `PATH`.

## Author

[Rafał Ciesielski](https://github.com/rciesielski3): [LinkedIn](https://www.linkedin.com/in/rafa%C5%82-ciesielski-820309100/), [GitHub](https://github.com/rciesielski3), [Portfolio](https://rciesielski3.github.io/portfolio/)

## License

[MIT](LICENSE)
