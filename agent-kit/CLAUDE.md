@AGENTS.md

# Agent operating rules

## Orchestration

The main session is the orchestrator. For each task:

1. Break it into small, independently verifiable steps.
2. Delegate implementation to `implementer`.
3. Delegate test design and gate execution to `qa-engineer`.
4. Delegate review to `reviewer` before every commit.
5. Loop implement, `pnpm verify`, review until every acceptance criterion is met and the gate is green.
6. Stop and ask only when a human check is required, an AC is ambiguous, docs are unreachable, or a decision is irreversible.

## Repo policy

- Implementation only. Do not commit local agent config, plans or notes.
- No narrative comments. Comment only a non-obvious "why".
- DRY, KISS, YAGNI. Smallest change that meets the AC.
- Justify every new dependency in the commit body.
- Never invent APIs or payloads. Verify against official docs; if unreachable, ask.
- Never read `.env`. Never log or print secrets.

## Workflow

- Never commit to `main`. Work on a branch and open a PR.
- A separate reviewer agent reviews the PR before merge.
- Never push without asking.

## Commits

- Conventional Commits (`@commitlint/config-conventional`): `type(scope): subject`.
- Imperative, lowercase subject, 72 characters or fewer.
- No AI attribution, `Co-Authored-By`, session links, or "Generated with" footers.
- Use the local git identity. Never change git config.

## Quality gate

`pnpm verify` must pass before every commit.
