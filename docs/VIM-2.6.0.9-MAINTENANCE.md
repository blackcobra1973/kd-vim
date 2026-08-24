# Vim 2.6.0.9 Maintenance Notes

**Date:** 2026-08-24

## Changes

- Split the former combined `lsp-manager.sh` into two platform-specific tools:
  - `tools/lsp/lsp-manager-linux-macos.sh` 1.1.0
  - `tools/lsp/lsp-manager-mobaxterm.sh` 1.1.0
- Removed the old combined `tools/lsp/lsp-manager.sh` from the package.
- Fixed the MobaXterm private Node/npm bootstrap failure where Windows
  `node.exe` interpreted `/home/mobaxterm/.../npm-cli.js` as
  `C:\home\mobaxterm\...\npm-cli.js`.
- The MobaXterm manager now executes the official Node distribution's
  `npm.cmd` through `cmd.exe` and converts native paths with `cygpath -w`.
- MobaXterm download handling now prefers verified `wget`, then verified
  `curl`, before using the configured insecure fallback. Failed verified
  attempts no longer dump repeated curl certificate errors to the terminal.
- The insecure fallback warning is emitted once per manager run.
- Added package-pinned SHA-256 hashes for the official Node 24.19.0 Windows
  x64 and ARM64 ZIP archives.
- Retained the versioned Docker Language Server asset-name fix and GitHub
  SHA-256 digest verification.
- Updated Vim health messages and documentation for the two manager names.
- Updated `vimrc.before.local` to 1.4.1 for the platform-specific manager
  documentation.
- Rewrote `README.md` as a detailed installation, operation and troubleshooting
  manual.
- Preserved the YAML/ALE diagnostic policy from 2.6.0.8: no line-length,
  comments-indentation or truthy yamllint noise, and no inline virtual
  diagnostic text.
- Preserved package cleanup policy: latest files only, no ddc content, no
  historical diffs, scripts only in `scripts/`, tooling only in `tools/`.

## MobaXterm root cause

Do not execute native Windows Node this way:

```text
node.exe /home/mobaxterm/.../npm-cli.js
```

The Windows process does not understand MobaXterm's POSIX virtual path as the
MobaXterm shell does.

The dedicated manager instead uses:

```text
cygpath -w <path-to-npm.cmd>
cmd.exe /c <translated-npm.cmd> ...
```

The native `npm.cmd` file resolves its accompanying `node.exe` and
`node_modules/npm/bin/npm-cli.js` from native Windows paths.

## Node 24.19.0 Windows pins

```text
win-x64:
57f71ab3652e797d84acddc79c81cc9ff1c6ddb2a1974cdb83f00fee9bff4c73

win-arm64:
8502f4a50b458d4cc38ed8f2001556c2cd239d464920f74017926ccb1e1c157f
```

## Validation

```bash
bash -n tools/lsp/lsp-manager-linux-macos.sh
bash -n tools/lsp/lsp-manager-mobaxterm.sh
bash -n scripts/install-vim-ai-linux-1.0.2.sh
bash -n scripts/install-vim-copilot-macos-1.0.1.sh

tools/lsp/lsp-manager-linux-macos.sh --help
tools/lsp/lsp-manager-mobaxterm.sh --help
```

Archive checks must also confirm:

- no `ddc` files;
- no `.diff` files;
- no old `lsp-manager.sh`;
- no older versioned Vimrc snapshots;
- no scripts in the package root;
- no tool payload in the package root.
