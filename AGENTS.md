# Agents and project facts

Imported by `CLAUDE.md`. Agent definitions live in `.claude/agents/`.

## Agents

| Agent              | Role                                          | Tools                                           | Use when                                        | Returns                                                               |
| ------------------ | --------------------------------------------- | ----------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------- |
| `implementer`      | Implements one scoped task against its AC     | read, write, edit, bash                         | writing or changing production code             | files changed, AC mapping, gate result, open questions                |
| `qa-engineer`      | Designs tests for the AC and runs the gate    | read, write, edit, bash                         | after implementation, before review             | AC-to-test mapping, files changed, gate summary, defects              |
| `reviewer`         | Read-only code and security review            | read-only, bash (git, `pnpm verify`)            | before every commit and before merging a PR     | findings ranked blocker/major/minor, then APPROVE or CHANGES REQUIRED |
| `security-auditor` | Read-only audit of secrets, deps, input, logs | read-only, bash (`gitleaks`, `pnpm audit`, git) | before release or on security-sensitive changes | findings by priority with file:line, impact and fix                   |

## Commands

- `pnpm verify`: format check, lint, typecheck, tests with coverage, agent validation.
- `pnpm fix`: auto-fix lint and formatting.
- `pnpm test:template`: smoke test of the template itself.

## Stack

- TypeScript (strict), Node 22, pnpm, Vitest, ESLint, Prettier, husky, commitlint, gitleaks.

## Layout

- `src/`: code and co-located `*.test.ts`.
- `scripts/`: repo tooling (`check-agents.mjs`, `template-smoke.sh`).
- `.claude/`: agents, `settings.json`, hooks.

## Conventions

- Type-aware ESLint (`strictTypeChecked`); only files in `tsconfig.eslint.json` are type-linted.
- Tests are named by behaviour; no snapshot tests.
