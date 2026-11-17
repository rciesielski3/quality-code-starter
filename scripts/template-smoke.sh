#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
README="${README_FILE:-$ROOT/README.md}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
PROJECT="$TMP/project"
failures=0
SECONDS=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; failures=$((failures + 1)); }
die() { echo "FAIL: $1" >&2; exit 1; }

expect_fail() {
  local name="$1" pattern="$2"
  shift 2
  local out
  if out=$("$@" 2>&1); then
    fail "$name: command succeeded, expected failure"
  elif grep -Eiq "$pattern" <<<"$out"; then
    pass "$name"
  else
    fail "$name: failed for the wrong reason (expected /$pattern/)"
    sed 's/^/    | /' <<<"$out"
  fi
}

# Identity via env only; never touches git config.
export GIT_AUTHOR_NAME="Template Smoke" GIT_AUTHOR_EMAIL="smoke@example.invalid"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

echo "== copy tree"
mkdir -p "$PROJECT"
(
  cd "$ROOT"
  git ls-files -z -co --exclude-standard | while IFS= read -r -d '' f; do
    if [ -e "$f" ] || [ -L "$f" ]; then printf '%s\0' "$f"; fi
  done >"$TMP/files.list"
  tar -cf - --null -T "$TMP/files.list" | tar -xf - -C "$PROJECT"
)
cd "$PROJECT"

echo "== bootstrap"
git init -q -b main
pnpm install --frozen-lockfile
git add -A
HUSKY=0 git commit -q -m "chore: baseline"
if pnpm verify; then pass "pnpm verify"; else die "pnpm verify"; fi

echo "== commit-msg: commitlint"
expect_fail "commitlint rejects bad message" "(subject|type) may not be empty" \
  git commit --allow-empty -m "bad message"

echo "== pre-commit: gitleaks"
# Built at runtime so no secret-shaped literal lives in the repo.
suffix=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 36 || true)
[ "${#suffix}" -eq 36 ] || die "could not generate fake token"
token="ghp_$suffix"
printf 'token=%s\n' "$token" >leaked.txt
git add leaked.txt
expect_fail "gitleaks blocks staged secret" "leaks found" \
  git commit -m "feat: add file"
git reset -q leaked.txt
rm -f leaked.txt

echo "== commit-msg: no-ai-trailers"
expect_fail "repo hook rejects Claude co-author trailer" "no-ai-trailers: rejected" \
  git commit --allow-empty -m "feat: add thing" -m "Co-Authored-By: Claude <noreply@anthropic.com>"

echo "== agent setup install"
[ -f "$README" ] || die "README not found: $README"
marker=$(grep -n -F -x '<!-- agent-setup-install -->' "$README" | head -n1 | cut -d: -f1 || true)
[ -n "$marker" ] || die "marker '<!-- agent-setup-install -->' missing in $README"
tail -n +"$((marker + 1))" "$README" | awk '
  !started { if ($0 ~ /^```sh[[:space:]]*$/) { started = 1; found = 1; next } else { exit } }
  /^```[[:space:]]*$/ { exit }
  { print }
  END { if (!found) exit 3 }
' >"$TMP/install.sh" || die "no \`\`\`sh block directly after the agent-setup-install marker"
[ -s "$TMP/install.sh" ] || die "agent setup install block is empty"
TARGET="$TMP/target"
mkdir -p "$TARGET/.husky"
printf '#!/bin/sh\n' >"$TARGET/.husky/commit-msg"
export KIT="$PROJECT"
cd "$TARGET"
if bash -euo pipefail "$TMP/install.sh"; then pass "agent setup install commands"; else die "agent setup install commands"; fi
for f in .claude/settings.json CLAUDE.md AGENTS.md; do
  if [ -f "$TARGET/$f" ]; then pass "target has $f"; else fail "target has $f"; fi
done
printf 'feat: add thing\n\nCo-Authored-By: Claude <noreply@anthropic.com>\n' >"$TMP/bad-msg"
printf 'feat: add thing\n' >"$TMP/good-msg"
expect_fail "installed hook rejects Claude co-author trailer" "no-ai-trailers: rejected" \
  sh .husky/commit-msg "$TMP/bad-msg"
if sh .husky/commit-msg "$TMP/good-msg"; then pass "installed hook accepts clean message"; else fail "installed hook accepts clean message"; fi
cd "$PROJECT"

echo "== valid commit"
if out=$(git commit --allow-empty -m "feat: add thing" 2>&1); then
  pass "valid conventional commit succeeds"
else
  fail "valid conventional commit succeeds"
  sed 's/^/    | /' <<<"$out"
fi

echo "== done in ${SECONDS}s"
if [ "$failures" -gt 0 ]; then
  echo "FAIL: $failures check(s) failed"
  exit 1
fi
echo "PASS: all checks"
