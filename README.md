# Quality Code Starter

A lean, **production-grade** starter focused on code **quality**, **consistency**, and **maintainability**.  
Curated like a senior QA/Software Engineer would: opinionated linting, predictable formatting, and CI-ready defaults.

---

## Why this exists

- Catch risky patterns early (type-aware ESLint).
- Eliminate formatting noise with Prettier.
- Make reviews faster and PRs smaller.
- Offer a single command to lint, format, and type-check locally and in CI.

---

## Quick Start

```bash
# Install deps
npm i   # or: pnpm i / yarn

# Check everything
npm verify

# Auto-fix what can be fixed
npm fix
```

> Works with Node 18+ (recommended LTS).

---

## Scripts (DX)

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier . --write",
    "format:check": "prettier . --check",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "verify": "pnpm typecheck && pnpm lint && pnpm format:check",
    "fix": "pnpm lint:fix && pnpm format",
    "prepare": "husky install"
  }
}
```

- **`verify`** is your gatekeeper for CI and pre-push hooks.
- **`fix`** is your daily driver—formats + lint-fixes in one go.

---

## Project Structure (suggested)

```
.
├─ src/
│  ├─ index.ts
│  └─ ...
├─ tests/               # Unit/integration tests
├─ .vscode/             # Editor settings (consistent team DX)
├─ .prettierrc          # Formatting rules
├─ eslint.config.mts    # Flat ESLint config (v9+)
└─ package.json
```

---

## Code Quality Stack

### ESLint (Flat Config, type-aware)

- Uses `typescript-eslint` strict/stylistic presets.
- Rules that matter for correctness and readability:
  - `@typescript-eslint/no-floating-promises`
  - `@typescript-eslint/explicit-function-return-type`
  - `@typescript-eslint/prefer-readonly`
  - Naming conventions and import hygiene
- **Type-aware**: requires a valid `tsconfig.json` (or `tsconfig.eslint.json`).

### Prettier

- Single source of truth via `.prettierrc` file.
- **Do not** duplicate Prettier config in `package.json` _and_ `.prettierrc` (pick one; this template uses `.prettierrc`).

### VS Code Settings

- Enforce Prettier on save (no more “it works on my machine” diffs).
- Organize imports automatically.

---

## Recommended Editor Setup

- VS Code + **Prettier** extension (esbenp.prettier-vscode).
- Enable **Format on Save**.
- Ensure **ESLint** extension is active.

> The repo includes `.vscode/settings.json` to enforce consistent behavior for the team.

---

## Git Hooks (Husky + lint-staged)

We enforce fast local checks and full verification before pushing.

### Install

```bash
npx husky-init && pnpm i -D lint-staged
```

This creates `.husky/` and a default hook.

### lint-staged config (`package.json`)

```json
{
  "lint-staged": {
    "*.{ts,tsx,js,json,md,yml,yaml}": ["prettier --write"],
    "*.{ts,tsx,js}": ["eslint --fix"]
  }
}
```

### Hooks

- **`.husky/pre-commit`**

  ```sh
  #!/bin/sh
  . "$(dirname "$0")/_/husky.sh"
  npx lint-staged
  ```

- **`.husky/pre-push`**
  ```sh
  #!/bin/sh
  . "$(dirname "$0")/_/husky.sh"
  pnpm verify
  ```

### Philosophy

- **Pre-commit** = fast (format + lint only staged files).
- **Pre-push** = full quality gate (`verify`).
- **CI** = runs `verify` again (safety net).

---

## CI Example (GitHub Actions)

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [main]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - run: pnpm i --frozen-lockfile
      - run: pnpm verify
```

---

## Conventions & Best Practices

- **Explicit returns** for exported functions: easier to reason about, safer for public API changes.
- **Avoid implicit any**—favor strong typing, utility types, and `as const` for literals.
- **Small modules**: one concern per file. Keep functions pure where possible.
- **No unused exports**: dead code confuses reviewers and tools.
- **Log with intent**: temporary logs behind debug flags; `console` treated as warnings in lint rules.
- **Fail fast** in CI: keep feedback loops tight.

---

## QA Notes (what we catch early)

- Unhandled promises and async footguns.
- Suspicious `any` usage or unsafe member access.
- Formatting drift that bloats PRs.
- Inconsistent naming and enum usage.
- Import/order chaos and accidental circular deps (lint rules can be extended to enforce it).

---

## Troubleshooting

- **Type-aware linting is slow/misconfigured**:
  - Ensure `tsconfig.json` includes only source files (exclude `dist`, `tests` if needed, or create `tsconfig.eslint.json`).
- **Prettier conflicts with ESLint**:
  - Keep `eslint-config-prettier` last in the config array.
  - Avoid `eslint-plugin-prettier` unless you explicitly want Prettier errors surfaced as ESLint errors.

---

## Author

Created with 💡 by [**Rafał Ciesielski**](https://github.com/rciesielski3)

- [LinkedIn](https://www.linkedin.com/in/rafa%C5%82-ciesielski-820309100/)
- [GitHub](https://github.com/rciesielski3)
- [Portfolio](https://rciesielski3.github.io/portfolio/)

---

## License

MIT License  
Please credit if you reuse it in your own work 🙌

[☕ Buy Me a Coffee](https://buycoffee.to/adateo)
