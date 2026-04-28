# Branch Cleanup Guide (GitHub Flow)

This document explains **when and how to delete short-lived branches** when working with
a PR-based GitHub Flow.

---

## When to Delete a Short-Lived Branch

✅ **Delete the branch immediately after the Pull Request is merged.**

The PR merge is the source of truth that the work is integrated into `main`.

Do **not** delete the branch before the PR is merged.

---

## Recommended: Automatic Deletion (GitHub)

Enable automatic cleanup in GitHub:

1. Go to **Repository Settings → General**
2. Scroll to **Pull Requests**
3. Enable **“Automatically delete head branches”**

With this enabled:
- The remote branch is deleted automatically after merge
- No manual action is required

---

## Manual Remote Cleanup (If Needed)

If the branch was not deleted automatically:

```bash
# Delete remote branch
git push origin --delete feat/ABC-123-invoice-export
```

---

## Local Branch Cleanup

After the PR is merged:

```bash
git checkout main
git pull --ff-only
```

### Safe delete (preferred)
```bash
git branch -d feat/ABC-123-invoice-export
```
- Fails if Git believes the branch is not merged locally
- Safe default

### Force delete (after squash merge)
```bash
git branch -D feat/ABC-123-invoice-export
```
- Use only if you are sure the PR was merged
- Common with squash merges

---

## Clean Up Stale Remote-Tracking Branches

Remove references to deleted remote branches:

```bash
git fetch --prune
```

(Optional)
```bash
git remote prune origin
```

---

## When NOT to Delete Immediately

Do not delete the branch yet if:

- You plan to open a follow-up PR from the same branch
- You are actively debugging a production issue from that branch
- The branch is part of a coordinated release happening the same day

⚠️ These are exceptions — short-lived branches should not live for weeks.

---

## Best Practices Summary

- ✅ Delete short-lived branches **right after PR merge**
- ✅ Enable automatic deletion in GitHub
- ✅ Clean up local branches regularly
- ✅ Prune stale remote branches
- ❌ Do not keep feature branches long-term

---

## Mental Model

> **A merged PR means the branch’s job is done.**
> Delete it and move on.
