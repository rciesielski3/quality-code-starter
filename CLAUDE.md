@AGENTS.md

# Working rules

## Orchestration

The main session is the orchestrator and delegates by agent role.

1. Break the task into small, independently verifiable steps.
2. Delegate implementation to `implementer`, tests and gate runs to `qa-engineer`, review to `reviewer`.
3. Loop implement, `pnpm verify`, review until every acceptance criterion is met and the gate is green.
4. Stop and ask only when a human check is required, an AC is ambiguous, docs are unreachable, or a decision is irreversible.

## Workflow

- Never commit to `main`. Work on a branch and open a PR.
- A separate reviewer agent reviews the PR before merge.
- Never push or merge without asking.
- Update the README with every behaviour change.

## Repo policy

- Implementation only. Do not commit personal overrides (`CLAUDE.local.md`, `.claude/settings.local.json`), plans or notes.
- No narrative comments. Comment only a non-obvious "why".
- DRY, KISS, YAGNI. Smallest change that meets the AC.
- Justify every new dependency in the commit body.
- Never invent APIs or payloads. Verify against official docs; if unreachable, ask.
- Never read `.env`. Never log or print secrets.

## Commits

- Conventional Commits per `commitlint.config.mts`: `type(scope): subject`.
- No AI attribution, `Co-Authored-By`, session links, or "Generated with" footers.
- Use the local git identity. Never change git config.

## Quality gate

`pnpm verify` must pass before every commit.
