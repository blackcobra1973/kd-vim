# Vim 2.6.0.7 Maintenance Notes

**Date:** 2026-08-23

## Changes

- Updated `tools/lsp/lsp-manager.sh` from 1.0.3 to 1.0.4.
- Fixed Docker Language Server release asset construction for v0.20.1.
- Docker assets now include the upstream version suffix, for example
  `docker-language-server-linux-amd64-v0.20.1`.
- Retained mandatory GitHub SHA-256 asset-digest verification.
- Reworked `README.md` into a complete installation, operation, update,
  troubleshooting, mapping, security, and LSP-manager manual.
- Enforced the package cleanup policy: only current files, no ddc variants,
  no historical diffs, and no `tools/lsp/history/` payload.
- Updated package metadata to 2.6.0.7.

## Validation targets

```bash
bash -n tools/lsp/lsp-manager.sh
bash -n scripts/install-vim-ai-linux-1.0.2.sh
bash -n scripts/install-vim-copilot-macos-1.0.1.sh
tools/lsp/lsp-manager.sh --help
tools/lsp/lsp-manager.sh versions
```

Expected manager version:

```text
lsp-manager.sh 1.0.4
```
