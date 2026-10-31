# Vim package 2.7.2.1 — hotfix maintenance notes

**Release date:** 2026-10-31  
**Package release:** 2.7.2.1 (bugfix branch of 2.7.2, not 2.7.3)  
**Vimrc configuration:** 1.5.2.1  
**Native Linux/macOS LSP manager:** 1.1.0 (unchanged)  
**MobaXterm LSP manager:** 1.1.3 (TLS regression corrected)

## Whitespace and diagnostics

- `FixWhitespace()` and `:FixWhitespace` work on all four OS profiles.
- `StripTrailingWhitespace()` remains an alias.
- Auto-clean on save includes normal YAML and Ansible YAML; Markdown, patches and Makefiles are excluded by default.
- Trailing-space dots were removed from `listchars`, preserving literal periods in text.
- Bottom-only ALE diagnostics and yamllint exclusions remain unchanged.

## MobaXterm TLS regression

- The supplied 2.7.2 and 2.7.3 archives both contained manager 1.1.0, lacking the separately reported 1.1.2 npm CA behavior.
- Manager 1.1.3 adds Windows CA-store trust via `NODE_USE_SYSTEM_CA=1` in Node/npm invocations.
- `--ca-bundle` reaches curl/wget, `NODE_EXTRA_CA_CERTS`, and `npm_config_cafile` (translated to Windows paths).
- npm uses strict SSL by default; after a detected certificate-chain failure, it may retry one command with `npm_config_strict_ssl=false` unless `--strict-tls` is selected.
- The exception is temporary and is **not** written to `.npmrc`; using an authorized CA is strongly preferred.
- The previous `cmd.exe` + `cygpath -w` bridge and SHA-256 checks remain intact.

## Version consistency

- Archive, README, maintenance notes, four Vimrc banners, four local templates and internal SHA manifest use 2.7.2.1 / 1.5.2.1 consistently.
- Installer helper usage text was updated without changing their independent script versions.
- npm package/seed-lock use `2.7.2-patch.1` because npm requires 3-component SemVer and does not permit package version `2.7.2.1`.
- Language-server dependency versions are unchanged from the base package.
- No plugin snapshots, ddc variants, historic version copies, or unrelated plugin upgrades.

## Verification

Run `bash -n` on scripts, Vim headless startup and whitespace tests, and the MobaXterm npm failure/retry simulations. Native MobaXterm verification is still required on Windows.
