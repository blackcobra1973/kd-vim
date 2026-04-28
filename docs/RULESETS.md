# Organization-Wide Defaults with GitHub Rulesets

GitHub **Rulesets** let you enforce consistent rules across repositories (and branches) without
hand-configuring branch protection in every repo.

Use this to enforce GitHub Flow on `main` across an organization.

---

## Where to Configure

### Organization level (recommended)
- Organization **Settings → Repository rules → Rulesets**
- Create a ruleset that targets repositories (all or a selection)

### Repository level
- Repository **Settings → Rules → Rulesets**

---

## Recommended Ruleset for `main`

Target branches:
- `main` (and optionally `release/*` maintenance branches)

Enable these rules (recommended baseline):

### Pull request requirements
- Require a pull request before merging
- Require approvals: **1–2**
- Dismiss stale approvals when new commits are pushed
- Require conversation resolution
- Require review from CODEOWNERS (if using `CODEOWNERS`)

### Status checks (CI)
- Require status checks to pass before merging
- Require branches to be up to date before merging (strict)

Suggested required checks (adjust to your pipeline):
- build
- unit-test
- lint
- security (optional)

### History & safety
- Require linear history (optional but recommended with squash merges)
- Block force pushes
- Block deletions

### Optional (high-traffic repos)
- Require merge queue (reduces “green PR → red main” issues)

---

## Recommended Repo Merge Settings (complements rulesets)

In **Repository Settings → General → Pull Requests**:
- Allow **Squash merging** ✅
- Allow **Rebase merging** (optional) ✅
- Disable merge commits (optional) ❌
- Automatically delete head branches ✅ (see `CLEANUP.md`)

---

## Rollout Tips

- Start with “Require PR + CI checks” first
- Add linear history + merge queue after the team is comfortable
- Document the required checks so teams don’t accidentally break merges

---

## References

- `CONTRIBUTING.md` (workflow expectations)
- `CLEANUP.md` (branch deletion hygiene)
- `MIGRATION_APPENDIX.md` (Git-Flow → GitHub Flow migration)
