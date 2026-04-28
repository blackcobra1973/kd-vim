# Local Git Hooks (Optional) — pre-push / pre-merge reminders

Git hooks run locally on a developer machine and can prevent common mistakes.
They are **not enforced by GitHub** (use Rulesets for that), but they’re great guardrails.

This repo recommends storing hooks in `.githooks/` and enabling them via `core.hooksPath`.

---

## Quick Setup

From the repo root:

```bash
git config core.hooksPath .githooks
```

Verify:

```bash
git config --get core.hooksPath
```

---

## Included Sample Hooks

### 1) `.githooks/pre-push`
Blocks accidental pushes directly to `main` (and other protected branches if you add them).

### 2) `.githooks/pre-merge-commit`
Displays a reminder when you create a local merge commit (useful if you prefer linear history).

> Note: This hook only runs when Git creates a merge commit locally (e.g., `git merge`).
> It does not run for PR merges on GitHub.

---

## Making Hooks Executable

On macOS/Linux:

```bash
chmod +x .githooks/pre-push .githooks/pre-merge-commit
```

On Windows (Git Bash), `chmod` usually works the same. If not, ensure the files have LF endings and are executable in your environment.

---

## Customizing

Edit the scripts in `.githooks/` to match your branch naming conventions, protected branches,
or to check for required files (e.g., changelog updates).
