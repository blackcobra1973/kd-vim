# Vim 2.6.0.10 Maintenance Notes

**Date:** 2026-08-24

## Changes

- Updated `tools/lsp/lsp-manager-mobaxterm.sh` from 1.1.0 to 1.1.1.
- Fixed the MobaXterm `check` false failure where a working `node.exe` was shown
  with an empty version and a working `npm.cmd` was shown as `(FAILED)`.
- Node and npm checks now execute the same commands that work interactively in
  MobaXterm:
  - `.../runtime/node/node.exe --version`
  - `.../runtime/node/npm.cmd --version`
- Normal MobaXterm npm execution now invokes `npm.cmd` directly instead of
  adding a `cmd.exe /c` wrapper.
- npm language-server wrappers now execute their `.cmd` shims directly through
  MobaXterm's Windows-command bridge.
- The manager continues to avoid `node.exe /home/.../npm-cli.js`, which caused
  Windows Node to resolve the path incorrectly as `C:\home\...`.
- `check` now validates all components required by the selected profile and
  returns exit status 1 when any required component is unavailable.
- A successful check now ends with `status: OK`; an incomplete check ends with
  a `status: FAILED (...)` summary.
- Retained pinned Node Windows SHA-256 verification and the existing MobaXterm
  TLS fallback policy.
- Preserved the Docker Language Server versioned asset-name/digest fix.
- Preserved the YAML/ALE diagnostic policy: no `line-length`,
  `comments-indentation` or `truthy` yamllint noise and no inline virtual
  diagnostic comments.
- Preserved package cleanup rules: current files only, no ddc files, no
  historical diffs, scripts only under `scripts/`, tooling only under `tools/`.

## Expected MobaXterm check output

With Node/npm installed but language servers still absent, the runtime portion
should look like:

```text
node:        /home/mobaxterm/.local/share/vim-lsp/runtime/node/node.exe (v24.19.0)
npm bridge:  /home/mobaxterm/.local/share/vim-lsp/runtime/node/npm.cmd (11.17.0)
```

The command must return status 1 until all servers required by the selected
profile are installed.

After a complete `mobaxterm` profile install it should end with:

```text
status:      OK
```

and return status 0.

## Validation

```bash
bash -n tools/lsp/lsp-manager-linux-macos.sh
bash -n tools/lsp/lsp-manager-mobaxterm.sh
bash -n scripts/install-vim-ai-linux-1.0.2.sh
bash -n scripts/install-vim-copilot-macos-1.0.1.sh

tools/lsp/lsp-manager-linux-macos.sh --help
tools/lsp/lsp-manager-mobaxterm.sh --help
```

The MobaXterm manager was additionally tested with a simulated MobaXterm
command bridge for both incomplete and complete `check --profile mobaxterm`
states. The incomplete state returned 1 while preserving the real Node/npm
versions; the complete state returned 0 and reported `status: OK`.
