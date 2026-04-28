# GitHub Flow — Developer Cheat Sheet

A fast, PR-based Git workflow using a single long-lived branch and short-lived feature branches.

---

## Core Rules (TL;DR)

- `main` is the **only** long-lived branch
- Always branch **from `main`**
- Open a Pull Request for every change
- CI must pass + approvals required
- Merge frequently, deploy often
- Prefer **Squash & Merge**

---

## Branch Naming

```text
feat/<ticket>-short-description
fix/<ticket>-short-description
chore/<ticket>-short-description
docs/<ticket>-short-description
```

---

## Daily Workflow

```bash
git checkout main
git pull --ff-only
git checkout -b feat/ABC-123-my-feature
git add -A
git commit -m "feat: add my feature (ABC-123)"
git push -u origin feat/ABC-123-my-feature
```

---

## Keep Branch Up to Date

```bash
git fetch origin
git rebase origin/main
git push --force-with-lease
```

---

## Releases

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

---

## Mental Model

> If it’s not ready to ship, hide it — don’t branch it forever.
