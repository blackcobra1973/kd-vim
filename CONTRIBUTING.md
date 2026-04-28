# Contributing Guide

This repository follows **GitHub Flow** with a single long-lived branch named `main`.

> ⚠️ Note for existing contributors: this repository previously used `master` as the default branch.
> The default branch has been renamed to **`main`**. Please update your local clones accordingly
> (see instructions below).

---

## Branching Model

- `main` is the only long-lived branch
- `main` is always releasable
- All work branches from `main`
- All changes go through Pull Requests

### Branch Naming Convention

```text
feat/<ticket>-short-description
fix/<ticket>-short-description
chore/<ticket>-short-description
docs/<ticket>-short-description
```

---

## Updating Existing Local Clones (`master` → `main`)

If you cloned this repository before the rename, run the following once:

```bash
git fetch origin
git branch -m master main
git branch -u origin/main main
git remote set-head origin -a
```

If your local clone did not have `master` checked out, you may need:

```bash
git checkout -b main origin/main
```

---

## Development Process

1. Pull latest `main`
   ```bash
   git checkout main
   git pull --ff-only
   ```

2. Create a branch from `main`
   ```bash
   git checkout -b feat/ABC-123-my-feature
   ```

3. Commit changes using clear, imperative messages
   ```text
   feat: add invoice export endpoint (ABC-123)
   fix: prevent null pointer in payment flow (ABC-999)
   ```

4. Push branch and open a Pull Request targeting `main`

---

## Pull Request Requirements

All Pull Requests must:

- Target `main`
- Pass all CI checks
- Receive required approvals
- Be small and focused
- Include tests or justification if tests are omitted

Draft PRs are encouraged for early feedback.

---

## Merge Strategy

Allowed:
- **Squash & Merge** (preferred)
- **Rebase & Merge**

Avoid:
- Merge commits (unless explicitly required)

---

## Releases

We support one of the following strategies:

### Continuous Deployment
- Every merge to `main` is deployable

### Tagged Releases
- Releases are created by tagging commits on `main`
- Example:
  ```bash
  git tag -a v1.12.0 -m "Release v1.12.0"
  git push origin v1.12.0
  ```

---

## Hotfixes

- Branch from `main`
- Open a PR back to `main`
- Merge and deploy immediately
- Cherry-pick into maintenance branches if required

---

## Branch Cleanup

Short-lived branches should be deleted **right after the PR is merged**.

See **`CLEANUP.md`** for the complete cleanup procedure (auto-delete in GitHub, local cleanup, pruning stale refs).

---

## Optional: Local Hook Reminders (pre-push / pre-merge)

Hooks are optional but helpful to prevent mistakes (like pushing to `main`).

- See **`HOOKS.md`** for setup instructions and sample hooks
- Recommended approach: store hooks in **`.githooks/`** and enable them via `core.hooksPath`

---

## Organization-Wide Defaults (GitHub Rulesets)

For consistent enforcement across repositories (especially in an organization),
use GitHub **Rulesets** to apply the same protections to `main` everywhere.

- See **`RULESETS.md`** for the recommended org-wide ruleset configuration.

---

## Maintenance Branches (If Applicable)

Maintenance branches are used **only** to support released versions.

```text
release/<major.minor>
```

Example:
```bash
git checkout -b release/1.12 v1.12.0
```

---

## Branch Protection Rules (Repo-Level Summary)

The `main` branch is protected:

- No direct pushes
- Pull Requests required
- CI checks required
- Linear history enforced (optional)

---

## Best Practices

- Keep PRs under ~300 lines when possible
- One logical change per PR
- Merge frequently
- Use feature flags for incomplete functionality
- Prefer boring releases over risky ones

---

## Migration Reference

For full details on migrating from Git-Flow and renaming `master` to `main`, see:

- `MIGRATION_APPENDIX.md`

---

## Philosophy

> **Continuous integration beats delayed perfection.**  
Small changes, fast feedback, and frequent merges keep the system healthy.
