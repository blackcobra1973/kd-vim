# Vim 2.6.0.0 — yegappan/lsp Migration

Version: 2.6.0.0  
Date: 2026-08-23

## Overview

Vim 2.6.0.0 starts from 2.5.0.4 and replaces the previous layered completion/LSP stack with a single Vim9-native LSP client:

- **Added:** `yegappan/lsp`
- **Removed:** `ddc.vim`, `denops.vim`, all ddc sources/filters/UI plugins
- **Removed:** `prabirshrestha/vim-lsp`
- **Removed:** `mattn/vim-lsp-settings`
- **Removed from the standard completion path:** NeoSnippet dependencies that existed only to feed ddc
- **Deno is no longer required for Vim completion/LSP.**

The rest of the 2.5.0.4 modernization remains in place: ALE, fzf/ripgrep, Fugitive/GV/GitGutter, Terraform, Helm, Ansible support, Copilot ghost text on Linux/macOS, and the Linux-only Codex workflow.

## Why yegappan/lsp

`yegappan/lsp` is implemented in Vim9 script and supports Vim 9.0 or newer. It provides code completion, diagnostics, navigation, hover, signature help, rename, code actions, formatting, inlay hints and other LSP features without a Deno or Python runtime in the editor.

The plugin intentionally does **not** install language servers. Vim 2.6 therefore keeps language-server lifecycle management outside Vim with `tools/lsp/lsp-manager.sh`.

## Completion and LSP ownership

The new split is deliberately simple:

| Function | Owner |
|---|---|
| Semantic completion | `yegappan/lsp` |
| Definition/references/hover/rename/code actions | `yegappan/lsp` |
| LSP diagnostics | `yegappan/lsp` |
| External linting/fixing | ALE |
| Copilot ghost text | `github/copilot.vim` on Linux/macOS |
| Explicit AI repository edits | Codex CLI on Linux |
| File/text search | fzf.vim + ripgrep |

ALE remains configured with `g:ale_disable_lsp = 1`; it does not create a second LSP connection.

## Language-server manager

The manager installs servers below:

```text
~/.local/share/vim-lsp/
├── bin/                 stable wrappers used by Vim
├── npm/                 pinned npm language-server installation
├── servers/             native language-server releases
├── runtime/node/        private pinned Node.js runtime
└── cache/                verified downloads
```

The manager's `bin` directory is automatically prepended to Vim's process `PATH` when it exists. This also lets one managed server invoke another managed executable when required.

### Manager commands

```bash
tools/lsp/lsp-manager.sh install --profile standard
tools/lsp/lsp-manager.sh update  --profile standard
tools/lsp/lsp-manager.sh check   --profile standard
tools/lsp/lsp-manager.sh list
tools/lsp/lsp-manager.sh versions
tools/lsp/lsp-manager.sh lock
tools/lsp/lsp-manager.sh clean --yes
```

For MobaXterm:

```bash
tools/lsp/lsp-manager.sh install --profile mobaxterm
```

A minimal npm-only profile is also available:

```bash
tools/lsp/lsp-manager.sh install --profile minimal
```

### TLS behavior

Downloads use normal certificate validation first. Corporate CA bundles can be supplied explicitly:

```bash
tools/lsp/lsp-manager.sh install --profile standard \
    --ca-bundle /path/to/company-ca.pem
```

The manager retains the controlled insecure retry used by the other project installers. To prohibit that fallback:

```bash
tools/lsp/lsp-manager.sh install --profile standard --strict-tls
```

## Managed language servers

| Vim filetype | Language server | Launch command |
|---|---|---|
| `sh` | Bash Language Server | `bash-language-server start` |
| `yaml`, `dockercompose` | YAML Language Server | `yaml-language-server --stdio` |
| `yaml.ansible` | Ansible Language Server | `ansible-language-server --stdio` |
| `python` | Pyright | `pyright-langserver --stdio` |
| JavaScript / TypeScript | TypeScript Language Server | `typescript-language-server --stdio` |
| `json` | VS Code JSON LS | `vscode-json-language-server --stdio` |
| `html` | VS Code HTML LS | `vscode-html-language-server --stdio` |
| CSS / SCSS / LESS | VS Code CSS LS | `vscode-css-language-server --stdio` |
| `vim` | Vim Language Server | `vim-language-server --stdio` |
| `terraform` | Terraform LS | `terraform-ls serve` |
| `helm` | Helm LS | `helm_ls serve` |
| Dockerfile / Compose | Docker Language Server | `docker-language-server start --stdio` |

### Version pins

`tools/lsp/versions.conf` pins native/runtime components:

```text
Node.js                 24.19.0 LTS
terraform-ls             0.39.0
docker-language-server   0.20.1
helm_ls                  master (upstream rolling manual-binary release)
```

Pinned npm packages are in `tools/lsp/npm/package.json`:

```text
@ansible/ansible-language-server   26.6.0
@zed-industries/vscode-langservers-extracted 4.10.8
bash-language-server               5.6.0
pyright                            1.1.413
typescript                         6.0.0
typescript-language-server         6.0.0
vim-language-server                2.3.1
yaml-language-server               1.24.0
```

### npm lockfile note

The shipped `package-lock.json` is intentionally a **seed lock**, marked with `"kdSeedLock": true`. The build environment used to create this release cannot access the npm registry, so fabricating a transitive lock would be incorrect.

On the first networked `install`/`update`, `lsp-manager.sh` uses the pinned private Node/npm runtime to expand that seed into a real runtime lock before running `npm ci`.

For the strongest reproducibility, run this once on a trusted networked host:

```bash
tools/lsp/lsp-manager.sh lock
```

That writes a complete transitive lockfile back to `tools/lsp/npm/package-lock.json`; commit that generated lockfile to the configuration repository.

## Ansible behavior

The 2.5.0.4 Ansible lint policy is retained:

- ALE runs `yamllint` and `ansible-lint` for `yaml.ansible`.
- yamllint's generic 80-column `line-length` rule remains disabled **only for Ansible buffers**.
- Other yamllint rules remain enabled.

To avoid duplicate `ansible-lint` diagnostics, the Ansible Language Server is registered with:

```vim
'workspaceConfig': {
  'ansible': {
    'validation': {
      'enabled': v:true,
      'lint': {'enabled': v:false},
    },
  },
}
```

The language server still provides Ansible validation, completion, navigation and documentation; ALE remains the only lint owner.

## Docker Compose behavior

Compose files are assigned the `dockercompose` filetype while retaining YAML syntax:

```text
docker-compose.yml
docker-compose.yaml
compose.yml
compose.yaml
```

Both YAML LS and Docker LS are registered for this filetype. Docker LS is launched with the upstream `start --stdio` command.

## LSP mappings

When an LSP server attaches to a buffer:

| Mapping | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Show references |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `[g` | Previous diagnostic |
| `]g` | Next diagnostic |
| `<leader>ca` | Code action |
| `<leader>lf` | Format buffer |

Automatic LSP completion is enabled. When the Vim popup menu is visible, `<Tab>`/`<S-Tab>` move through candidates and `<CR>` accepts the selected candidate. Copilot continues to leave `<Tab>` alone and uses its separate ghost-text acceptance mapping.

## Health commands

Use:

```vim
:KDLspHealth
:KDCompletionHealth
:KDModernHealth
:LspShowAllServers
```

`KDCompletionHealth` is retained as an alias so existing muscle memory/scripts do not immediately break.

## Platform behavior

### Linux

- yegappan/lsp enabled on Vim 9.0+
- standard LSP-manager profile
- Copilot ghost text enabled when selected
- Codex CLI integration enabled when selected

### macOS

- yegappan/lsp enabled on Vim 9.0+
- standard LSP-manager profile
- Copilot ghost text enabled when selected
- Codex Vim workflow remains disabled by the existing 2.5 platform policy

### MobaXterm

- yegappan/lsp enabled on Vim 9.0+
- `mobaxterm` LSP-manager profile
- no Copilot
- no Codex
- no Deno/denops requirement for completion

## Upgrade procedure from 2.5.0.4

1. Replace the vimrc and `vimrc.before.local`.
2. Start Vim and remove obsolete plugins:

```vim
:PlugClean
```

The cleanup should include the old ddc/denops and vim-lsp stack.

3. Install/update the remaining plugins:

```vim
:PlugInstall
:PlugUpdate
```

4. Completely restart Vim.
5. Install the language-server profile:

```bash
tools/lsp/lsp-manager.sh install --profile standard
```

Use `--profile mobaxterm` on MobaXterm.

6. Validate:

```bash
tools/lsp/lsp-manager.sh check --profile standard
```

and in Vim:

```vim
:KDLspHealth
:LspShowAllServers
```

## Naming transition

The primary 2.6 filenames now use `-lsp` rather than `-ddc`:

```text
vimrc-linux-lsp-2.6.0.0
vimrc-windows-mobaxterm-lsp-2.6.0.0
```

Byte-identical compatibility aliases using the previous `-ddc` names are also shipped so existing deployment scripts can be migrated separately.
