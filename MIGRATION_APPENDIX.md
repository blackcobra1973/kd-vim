# Git-Flow → GitHub Flow Migration Appendix

This appendix explains the conceptual and practical differences between Git-Flow and GitHub Flow
and provides a checklist-style migration plan, including renaming the default branch from
`master` to `main` in GitHub.

---

## Conceptual Shift

| Git-Flow | GitHub Flow |
|--------|-------------|
| Long-lived `develop` branch | Single integration branch |
| Release preparation branches | Always releasable `main` |
| Late integration | Continuous integration |
| Merge-heavy | Rebase + squash |

---

## Branch Mapping

| Git-Flow Branch | GitHub Flow Equivalent |
|-----------------|-----------------------|
| master          | main                  |
| develop         | ❌ removed             |
| feature/*       | short-lived branches  |
| release/*       | tags or maintenance branches |
| hotfix/*        | fix/* from `main`     |

---

## Migration Checklist

- [ ] Align `develop` and `master`
- [ ] Rename `master` → `main`
- [ ] Protect `main`
- [ ] Require PRs + CI
- [ ] Stop branching from `develop`
- [ ] Replace release branches with tags
- [ ] Train team on rebase + squash
- [ ] Use feature flags

---

## Renaming `master` to `main` (GitHub)

This should be done **once**, ideally before removing `develop`.

### Step 1: Rename the branch locally
```bash
git checkout master
git branch -m master main
```

### Step 2: Push `main` and set upstream
```bash
git push -u origin main
```

### Step 3: Update default branch in GitHub
- Go to **Settings → Branches**
- Change default branch from `master` to `main`

### Step 4: Update remote references
```bash
git push origin --delete master
git fetch --prune
```

> ⚠️ Only delete `master` after all active PRs and CI pipelines are updated.

### Step 5: Update CI/CD and tooling
- Update CI configs referencing `master`
- Update branch protections
- Update documentation and scripts

---

## Aligning `develop` and `main` (Final Sync)

If `develop` exists, merge it **once** into `main`:

```bash
git checkout main
git merge develop
```

Resolve conflicts carefully. This is the **last time** `develop` is merged.

After this:
- Freeze `develop`
- Make it read-only or delete it later

---

## New Hotfix Process

```bash
git checkout main
git checkout -b fix/ABC-999-critical
git commit -m "fix: critical production bug"
git push -u origin fix/ABC-999-critical
```

Open PR → merge → deploy.

---

## Common Pitfalls

- Long-running feature branches
- Skipping CI for “small” changes
- Treating `main` as unstable
- Forgetting to update CI after renaming `master`

---

## Success Criteria

- PRs merged daily
- `main` always deployable
- Releases become boring
