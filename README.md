# Vim Configuration 2.6.0.2

A modern classic-Vim configuration for Linux, macOS, and MobaXterm, with a single Vim9-native LSP client, externally managed language servers, ALE linting/fixing, Terraform/Helm/Ansible support, and optional AI integration.

**Release:** 2.6.0.2  
**Date:** 2026-08-23  
**Primary LSP client:** `yegappan/lsp`  
**Language-server manager:** `tools/lsp/lsp-manager.sh` 1.0.1

---

## 1. What changed in Vim 2.6

Vim 2.6 replaces the previous layered ddc/denops/vim-lsp stack with one Vim9-native LSP client:

```text
Vim 2.5.x                          Vim 2.6.x
──────────                         ──────────
ddc.vim                            yegappan/lsp
├── denops.vim                     └── external lsp-manager.sh
├── Deno                               ├── private Node runtime
├── ddc sources / filters              ├── pinned npm servers
├── ddc-vim-lsp                       ├── terraform-ls
├── vim-lsp                           ├── helm_ls
└── vim-lsp-settings                  └── docker-language-server
```

The following are no longer required for normal completion/LSP operation:

- `ddc.vim`
- `denops.vim`
- Deno
- `ddc-vim-lsp`
- `vim-lsp`
- `vim-lsp-settings`

`yegappan/lsp` now owns semantic completion, navigation, hover, diagnostics, rename, code actions, formatting, and other LSP functions. ALE remains the dedicated external linter/fixer layer.

---

## 2. Platform matrix

| Feature | Linux | macOS | MobaXterm |
|---|---:|---:|---:|
| Classic Vim | Yes | Yes | Yes |
| Vim requirement for LSP | Vim 9.0+ with `+job` and `+channel` | Same | Same |
| `yegappan/lsp` | Yes | Yes | Yes |
| Managed language servers | `standard` profile | `standard` profile | `mobaxterm` profile |
| ALE | Yes | Yes | Yes |
| Terraform / Helm / Ansible | Yes | Yes | Yes |
| GitHub Copilot ghost text | Optional | Optional | No |
| OpenAI Codex Vim workflow | Optional | No | No |
| Deno required | No | No | No |

Debian 13's stock Vim 9.1.1244 is therefore suitable for the 2.6 LSP stack; the old ddc/denops 9.1.1646 minimum no longer applies.

---

## 3. Release files

### Linux / macOS

Preferred file:

```text
vimrc-linux-lsp-2.6.0.2
```

Canonical copy:

```text
vimrc-linux-lsp
```

The `vimrc-linux-ddc-2.6.0.2` file is a compatibility filename only. New deployments should use the `-lsp` name.

### MobaXterm

Preferred file:

```text
vimrc-windows-mobaxterm-lsp-2.6.0.2
```

Canonical copy:

```text
vimrc-windows-mobaxterm-lsp
```

The `-ddc` filename remains only for compatibility with older deployment scripts.

### Shared defaults

```text
vimrc.before.local-1.4.0
```

The standard bundle profile is:

```vim
let g:kd_bundle_groups = ['general', 'lsp', 'ale', 'programming', 'markdown', 'ruby', 'ansible', 'python', 'docker', 'javascript', 'html', 'terraform', 'helm', 'misc', 'github_copilot', 'codex',]
```

Platform filtering automatically removes unsupported AI groups:

- Linux: keeps `github_copilot` and `codex`.
- macOS: keeps `github_copilot`, removes `codex`.
- MobaXterm: removes both AI groups.

---

## 4. Package verification and extraction

The release archive is:

```text
vim-2.6.0.2.tar.gz
```

Verify the archive SHA-256 using the value supplied with the release:

```bash
sha256sum vim-2.6.0.2.tar.gz
```

On macOS:

```bash
shasum -a 256 vim-2.6.0.2.tar.gz
```

Extract it:

```bash
tar -xzf vim-2.6.0.2.tar.gz
cd vim-2.6.0.2-package
```

Verify the package contents:

```bash
sha256sum -c vim-2.6.0.2-SHA256SUMS.txt
```

On macOS, if GNU `sha256sum` is not installed, use the manifest for manual verification with `shasum -a 256` as needed.

---

## 5. Base prerequisites

The Vim configuration itself expects at least:

```text
Vim 9.0+
Git
curl
```

For the LSP manager, also ensure these common archive/checksum tools are available:

```text
tar
xz / xz-utils
unzip
sha256sum or shasum
```

### RHEL / AlmaLinux

A suitable base is:

```bash
dnf install -y ca-certificates curl git tar xz unzip
```

### Debian

```bash
apt-get update
apt-get install -y ca-certificates curl git tar xz-utils unzip
```

### macOS

The system already provides most required tools. Homebrew can be used for anything missing:

```bash
brew install git xz
```

### MobaXterm

Use a MobaXterm environment that provides at least:

```text
/bin/bash
curl
git
tar
unzip
```

The MobaXterm Vim configuration intentionally targets terminal Vim only; it does not configure gVim or X11.

---

## 6. Recommended external developer tools

These are not all installed by `lsp-manager.sh`, because they are used by ALE, Vim plugins, or command-line workflows rather than by the LSP client itself:

```text
fzf >= 0.54
ripgrep (rg)
Universal Ctags
ansible-lint
yamllint
shellcheck
ruff
hadolint
terraform
tflint
helm
```

Missing tools are reported by:

```vim
:KDModernHealth
```

---

## 7. Back up the existing Vim setup

Before replacing a working configuration, preserve it.

Example:

```bash
stamp="$(date +%Y%m%d-%H%M%S)"

[ -e ~/.vimrc ] && cp -a ~/.vimrc ~/.vimrc."$stamp".bak
[ -e ~/.vimrc.before.local ] && cp -a ~/.vimrc.before.local ~/.vimrc.before.local."$stamp".bak
```

If `~/.vim` itself contains the Git-managed configuration, commit or back it up before replacing files:

```bash
cd ~/.vim
git status
```

To see the vimrc currently used by Vim:

```vim
:echo $MYVIMRC
```

Install the new main vimrc at that same location.

---

## 8. Fresh installation — Linux / macOS

### 8.1 Install the main vimrc

If the existing configuration uses `~/.vim/vimrc`:

```bash
mkdir -p ~/.vim
cp vimrc-linux-lsp-2.6.0.2 ~/.vim/vimrc
```

If the existing configuration uses `~/.vimrc`, copy the same file there instead:

```bash
cp vimrc-linux-lsp-2.6.0.2 ~/.vimrc
```

Do not keep two different active copies. Use the location shown by `:echo $MYVIMRC`.

### 8.2 Install the shared defaults

```bash
cp vimrc.before.local-1.4.0 ~/.vimrc.before.local
```

Edit `~/.vimrc.before.local` if you want to enable/disable bundle groups or override paths/options.

### 8.3 Install the LSP-manager files into the Vim repository

When `~/.vim` is the configuration repository root:

```bash
mkdir -p ~/.vim/tools
rm -rf ~/.vim/tools/lsp
cp -a tools/lsp ~/.vim/tools/
chmod 755 ~/.vim/tools/lsp/lsp-manager.sh
```

You should then have:

```text
~/.vim/tools/lsp/lsp-manager.sh
~/.vim/tools/lsp/versions.conf
~/.vim/tools/lsp/npm/package.json
~/.vim/tools/lsp/npm/package-lock.json
```

### 8.4 Start Vim and install plugins

The vimrc can bootstrap `vim-plug` automatically when `curl` and Git are available.

Then run:

```vim
:PlugInstall
:PlugUpdate
```

Completely exit and restart Vim after the first plugin installation.

### 8.5 Install the language servers

From the Vim repository root:

```bash
cd ~/.vim
tools/lsp/lsp-manager.sh install --profile standard
```

Validate:

```bash
tools/lsp/lsp-manager.sh check --profile standard
tools/lsp/lsp-manager.sh list
tools/lsp/lsp-manager.sh versions
```

Then in Vim:

```vim
:KDLspHealth
:LspShowAllServers
:KDModernHealth
```

---

## 9. Fresh installation — MobaXterm

Install the MobaXterm-specific vimrc at the location used by MobaXterm Vim, for example inside the persistent MobaXterm home:

```bash
cp vimrc-windows-mobaxterm-lsp-2.6.0.2 ~/.vim/vimrc
cp vimrc.before.local-1.4.0 ~/.vimrc.before.local
```

Copy the manager tree:

```bash
mkdir -p ~/.vim/tools
rm -rf ~/.vim/tools/lsp
cp -a tools/lsp ~/.vim/tools/
chmod 755 ~/.vim/tools/lsp/lsp-manager.sh
```

Start Vim and run:

```vim
:PlugClean
:PlugInstall
:PlugUpdate
```

Restart Vim completely.

Install the MobaXterm language-server profile:

```bash
cd ~/.vim
tools/lsp/lsp-manager.sh install --profile mobaxterm
```

Validate:

```bash
tools/lsp/lsp-manager.sh check --profile mobaxterm
```

Then:

```vim
:KDLspHealth
:LspShowAllServers
:KDModernHealth
```

MobaXterm is intentionally AI-free in this release.

---

## 10. Upgrade from Vim 2.5.0.4

Vim 2.6 is a significant completion/LSP migration, so perform a clean plugin transition.

### 10.1 Replace files

Install:

```text
vimrc-linux-lsp-2.6.0.2
or
vimrc-windows-mobaxterm-lsp-2.6.0.2

vimrc.before.local-1.4.0
tools/lsp/
```

### 10.2 Remove obsolete plugins through vim-plug

Start Vim and run:

```vim
:PlugClean
```

The removed stack should include old ddc/denops and vim-lsp components.

Then:

```vim
:PlugInstall
:PlugUpdate
```

Completely quit all Vim processes and restart.

### 10.3 Install managed language servers

Linux/macOS:

```bash
cd ~/.vim
tools/lsp/lsp-manager.sh install --profile standard
```

MobaXterm:

```bash
cd ~/.vim
tools/lsp/lsp-manager.sh install --profile mobaxterm
```

### 10.4 Validate

```vim
:KDLspHealth
:KDCompletionHealth
:KDModernHealth
:LspShowAllServers
```

`KDCompletionHealth` remains as a compatibility alias for `KDLspHealth`.

### 10.5 Deno cleanup

Deno is no longer required by the Vim completion stack. Do **not** remove Deno merely because Vim 2.6 no longer needs it if another application or workflow still uses it.

---

## 11. Upgrade/recovery from broken Vim 2.6.0.0

Vim 2.6.0.0 contained an invalid npm pin:

```text
typescript-language-server  6.0.0
typescript                  6.0.0   <-- not published as a stable npm package
```

Vim 2.6.0.1 first corrected this to:

```text
typescript-language-server  6.0.0
typescript                  6.0.3
```

If 2.6.0.0 failed during the first language-server installation with:

```text
npm ERR! code ETARGET
npm ERR! notarget No matching version found for typescript@6.0.0
```

replace `tools/lsp/` with the current 2.6.0.2 tree, then remove only the incomplete npm staging directory:

```bash
rm -rf ~/.local/share/vim-lsp/npm

cd ~/.vim
tools/lsp/lsp-manager.sh install --profile standard
```

The already installed private Node runtime does not need to be removed:

```text
~/.local/share/vim-lsp/runtime/node
```

Validate after the retry:

```bash
tools/lsp/lsp-manager.sh check --profile standard
tools/lsp/lsp-manager.sh versions
```

---

## 12. LSP manager architecture

The default manager root is:

```text
~/.local/share/vim-lsp/
```

Layout:

```text
~/.local/share/vim-lsp/
├── bin/                 stable wrappers used by Vim
├── npm/                 pinned npm server installation
├── servers/             native language-server releases
├── runtime/node/        private Node.js runtime
└── cache/               verified downloads
```

Vim prepends `~/.local/share/vim-lsp/bin` to the environment inherited by its child processes when that directory exists.

The LSP manager's private Node runtime is independent from the system Node installation used by GitHub Copilot.

---

## 13. LSP manager commands

General syntax:

```bash
tools/lsp/lsp-manager.sh <install|update|check|list|versions|lock|clean> [options]
```

### Install

```bash
tools/lsp/lsp-manager.sh install --profile standard
```

### Update to the versions pinned by the checked-out configuration

```bash
tools/lsp/lsp-manager.sh update --profile standard
```

### Health/check

```bash
tools/lsp/lsp-manager.sh check --profile standard
```

### List installed wrappers

```bash
tools/lsp/lsp-manager.sh list
```

### Show pinned versions

```bash
tools/lsp/lsp-manager.sh versions
```

### Generate a full npm lockfile

```bash
tools/lsp/lsp-manager.sh lock
```

### Remove the complete managed LSP installation

This deletes the entire manager root and requires explicit acknowledgement:

```bash
tools/lsp/lsp-manager.sh clean --yes
```

Use `clean` only when you intentionally want to rebuild all managed servers and the private Node runtime.

---

## 14. LSP manager profiles

### Standard

```bash
--profile standard
```

Installs:

- npm LSP stack
- `terraform-ls`
- `helm_ls`
- `docker-language-server`

This is the normal Linux/macOS profile.

### MobaXterm

```bash
--profile mobaxterm
```

Uses the same logical server set while selecting Windows-native assets where upstream provides them.

### Minimal

```bash
--profile minimal
```

Installs the npm language-server stack only and skips the native Terraform, Helm, and Docker servers.

---

## 15. LSP manager TLS options

Verified TLS is attempted first.

### Custom corporate CA bundle

```bash
tools/lsp/lsp-manager.sh install --profile standard \
    --ca-bundle /path/to/company-ca.pem
```

### Strict TLS — never use an insecure retry

```bash
tools/lsp/lsp-manager.sh install --profile standard --strict-tls
```

Equivalent:

```bash
tools/lsp/lsp-manager.sh install --profile standard --no-insecure-fallback
```

Without strict mode, the manager can retry a failed verified download with `curl --insecure`. Prefer a correct CA bundle on managed systems.

---

## 16. Custom LSP installation directory

The manager can use another root:

```bash
tools/lsp/lsp-manager.sh install \
    --profile standard \
    --home /some/path/vim-lsp
```

If you do this, Vim must use the same path. Put this in `~/.vimrc.before.local`:

```vim
let g:kd_lsp_home = '/some/path/vim-lsp'
```

The default is:

```vim
let g:kd_lsp_home = expand('~/.local/share/vim-lsp')
```

---

## 17. Managed language servers

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

---

## 18. Version pins in 2.6.0.2

Native/runtime pins in `tools/lsp/versions.conf`:

```text
Node.js                  24.19.0
terraform-ls              0.39.0
docker-language-server    0.20.1
helm_ls                   master
```

Pinned npm packages in `tools/lsp/npm/package.json`:

```text
@ansible/ansible-language-server             26.6.0
@zed-industries/vscode-langservers-extracted 4.10.8
bash-language-server                          5.6.0
pyright                                       1.1.413
typescript                                    6.0.3
typescript-language-server                    6.0.0
vim-language-server                           2.3.1
yaml-language-server                          1.24.0
```

`helm_ls` uses upstream's rolling manual-binary release (`master`) and is therefore integrity-verified but not immutable in the same way as the numeric native server releases.

---

## 19. npm seed lock and reproducible installs

The shipped `tools/lsp/npm/package-lock.json` is a seed lock containing:

```json
"kdSeedLock": true
```

On the first networked install/update, the manager:

1. installs/reuses its pinned private Node runtime;
2. copies the pinned `package.json`;
3. detects the seed lock;
4. generates a complete transitive lock with npm;
5. uses the resulting runtime lock for `npm ci`.

For stronger reproducibility, generate and commit the complete lock once from a trusted networked system:

```bash
cd ~/.vim
tools/lsp/lsp-manager.sh lock
```

This writes the resolved lock back to:

```text
tools/lsp/npm/package-lock.json
```

Commit that file to the Vim configuration repository.

---

## 20. LSP completion behavior

Automatic LSP completion is enabled with `yegappan/lsp`.

Completion keys are context-sensitive:

| Key | Linux/macOS with Copilot | MobaXterm / no Copilot |
|---|---|---|
| `<Tab>` | Accept visible Copilot ghost text; otherwise next LSP popup candidate; otherwise insert a normal Tab | Next LSP popup candidate; otherwise insert a normal Tab |
| `<S-Tab>` | Previous LSP popup candidate | Previous LSP popup candidate |
| `<CR>` | Accept selected LSP popup candidate | Accept selected LSP popup candidate |

`github/copilot.vim`'s `copilot#Accept()` provides the fallback behavior used here: if no Copilot suggestion is displayed, it falls back to popup-next while `pumvisible()` is true and otherwise to a normal Tab. `Ctrl-G` remains available as a secondary full-ghost-text accept key.

For filetypes without an attached managed LSP, Vim's native omnifunc remains available where configured.

---

## 21. LSP navigation mappings

These buffer-local mappings are installed after a language server attaches:

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

Useful native LSP commands include:

```vim
:LspShowAllServers
:LspGotoDefinition
:LspShowReferences
:LspHover
:LspRename
:LspCodeAction
:LspFormat
```

---

## 22. ALE ownership and mappings

ALE remains dedicated to asynchronous external linting/fixing:

```vim
let g:ale_disable_lsp = 1
```

Configured linters include:

| Filetype | ALE linters |
|---|---|
| Ansible | `ansible-lint`, `yamllint` |
| YAML | `yamllint` |
| Python | `ruff` |
| shell | `shellcheck` |
| Dockerfile | `hadolint` |
| Terraform | `terraform`, `tflint` |

### Linux/macOS ALE mappings

The `<leader>a...` namespace is reserved for Codex, so ALE uses:

| Mapping | Action |
|---|---|
| `<leader>zl` | `:ALELint` |
| `<leader>zf` | `:ALEFix` |
| `<leader>zn` | Next ALE finding |
| `<leader>zp` | Previous ALE finding |

### MobaXterm ALE mappings

Because MobaXterm has no AI namespace, it retains:

| Mapping | Action |
|---|---|
| `<leader>al` | `:ALELint` |
| `<leader>af` | `:ALEFix` |
| `<leader>an` | Next ALE finding |
| `<leader>ap` | Previous ALE finding |

---

## 23. Ansible-specific behavior

Ansible files are normally detected as:

```text
yaml.ansible
```

ALE runs:

```text
ansible-lint
yamllint
```

For Ansible buffers only, yamllint's generic `line-length` rule is disabled by a dedicated ALE linter named `yamllint_ansible`. The rule is embedded directly in the linter command, avoiding the FileType-autocmd ordering race that could still expose an initial 80-column warning in 2.6.0.1:

```text
yamllint -d '{extends: default, rules: {line-length: disable}}' ...
```

All other normal yamllint rules remain enabled. Ordinary YAML files keep the normal line-length policy.

The Ansible Language Server remains enabled for completion/navigation/validation, but its internal ansible-lint integration is disabled so ALE remains the single lint owner. As a second guard, the yegappan/lsp `processDiagHandler` removes only diagnostics identified as line-length warnings for Ansible buffers.

Useful checks in an Ansible buffer:

```vim
:set filetype?
:ALEInfo
:LspDiag show
```

`ALEInfo` should show `yamllint_ansible` and `ansible_lint`; it should not show the generic `yamllint` linter for `yaml.ansible`.

Expected filetype:

```text
filetype=yaml.ansible
```

---

## 24. Docker Compose behavior

The following filenames are detected as `dockercompose` while retaining YAML syntax:

```text
docker-compose.yml
docker-compose.yaml
compose.yml
compose.yaml
```

Both YAML Language Server and Docker Language Server are registered for Docker Compose buffers.

Docker Language Server is launched as:

```text
docker-language-server start --stdio
```

---

## 25. Terraform

The Vim plugin group includes:

```text
hashivim/vim-terraform
```

Configured behavior includes Terraform formatting/alignment support, while semantic completion/navigation comes from managed `terraform-ls`.

Ensure the Terraform CLI itself is installed when you want formatting/validation/ALE workflows:

```bash
terraform version
tflint --version
```

LSP manager check:

```bash
tools/lsp/lsp-manager.sh check --profile standard
```

---

## 26. Helm

The Vim plugin group includes:

```text
towolf/vim-helm
```

Semantic support is provided by `helm_ls`.

The Helm CLI is still recommended for chart lint/template commands:

```bash
helm version
```

---

## 27. GitHub Copilot — Linux and macOS

Copilot is optional and is supplied by:

```text
github/copilot.vim
```

It provides inline/multiline ghost-text predictions. The normal LSP popup remains separate.

Full ghost-text acceptance:

```text
Ctrl-G
```

Management mappings:

| Mapping | Action |
|---|---|
| `<leader>cp` | Copilot panel |
| `<leader>cs` | Copilot status |
| `<leader>ce` | Enable |
| `<leader>cd` | Disable |
| `<leader>cm` | Model |
| `<leader>cu` | Upgrade |

### Linux prerequisites

The included helper installs system Node/npm for Copilot and Codex at `/usr/local/bin/codex`:

```bash
chmod 755 install-vim-ai-linux-1.0.1.sh
./install-vim-ai-linux-1.0.1.sh
```

Custom CA:

```bash
./install-vim-ai-linux-1.0.1.sh \
    --ca-bundle /path/to/company-ca.pem
```

Strict TLS:

```bash
./install-vim-ai-linux-1.0.1.sh --strict-tls
```

Skip package installation if prerequisites are already managed separately:

```bash
./install-vim-ai-linux-1.0.1.sh --skip-packages
```

Skip Codex installation and install only Copilot prerequisites:

```bash
./install-vim-ai-linux-1.0.1.sh --skip-codex
```

### macOS prerequisites

```bash
chmod 755 install-vim-copilot-macos.sh
./install-vim-copilot-macos.sh
```

The macOS helper validates Vim support and installs Node via Homebrew if needed.

### Authenticate Copilot

After `:PlugInstall`:

```vim
:Copilot setup
:Copilot status
:KDAIHealth
```

---

## 28. OpenAI Codex — Linux only

The Codex Vim workflow remains Linux-only in 2.6.

The Linux AI installer exposes Codex as:

```text
/usr/local/bin/codex
```

with its managed standalone package cache below:

```text
/usr/local/lib/codex
```

After installation, authenticate:

```bash
codex
```

Choose **Sign in with ChatGPT** when prompted.

Check:

```bash
command -v codex
codex --version
codex login status
```

Expected command path:

```text
/usr/local/bin/codex
```

### Codex Vim mappings

| Mapping | Command | Purpose |
|---|---|---|
| `<leader>aa` | `:AIAsk` | Ask about code/repository |
| `<leader>ae` | `:AIEdit` | Explicit edit |
| `<leader>ax` | `:AIExplain` | Explain code |
| `<leader>af` | `:AIFix` | Diagnose/fix |
| `<leader>ar` | `:AIRefactor` | Refactor |
| `<leader>at` | `:AITest` | Add/improve tests |
| `<leader>ad` | `:AIDocument` | Improve documentation |
| `<leader>ag` | `:AIGitReview` | Review Git worktree |
| `<leader>ap` | `:AIPrompt` | Free-form repository task |
| `<leader>ao` | `:AIOpen` | Open interactive Codex |
| `<leader>as` | `:AIStatus` | AI status |

The noninteractive Codex actions use `read-only` or `workspace-write` sandboxes depending on whether the action should modify files.

---

## 29. AI on MobaXterm

MobaXterm intentionally contains no:

```text
GitHub Copilot
Codex
AI ghost text
AI commands
```

Normal completion is provided by `yegappan/lsp`.

---

## 30. Vim-plug TLS configuration

The vimrc bootstraps vim-plug automatically when it is missing.

Default behavior:

```vim
let g:kd_curl_tls_verify = 1
let g:kd_curl_allow_insecure_fallback = 1
```

For a corporate CA, put this in `~/.vimrc.before.local`:

```vim
let g:kd_curl_ca_bundle = '/path/to/company-ca.pem'
```

For strict verification with no insecure retry:

```vim
let g:kd_curl_tls_verify = 1
let g:kd_curl_allow_insecure_fallback = 0
```

Disabling verification completely is supported but not recommended:

```vim
let g:kd_curl_tls_verify = 0
```

---

## 31. Health commands

### LSP/completion

```vim
:KDLspHealth
:KDCompletionHealth
:LspShowAllServers
```

### General modern-tool health

```vim
:KDModernHealth
```

This checks items such as:

```text
fzf
ripgrep
ctags
yegappan/lsp
managed LSP bin path
terraform
helm
ansible-lint
yamllint
shellcheck
ruff
hadolint
tflint
stale Syntastic
```

### AI

Linux/macOS with Copilot enabled:

```vim
:KDAIHealth
:Copilot status
```

Linux with Codex enabled also reports Codex state/authentication.

---

## 32. Routine maintenance

### Vim plugins

```vim
:PlugUpdate
```

After changing bundle groups:

```vim
:PlugClean
:PlugInstall
```

### Language servers

After changing pinned versions in Git:

```bash
tools/lsp/lsp-manager.sh update --profile standard
```

Check afterwards:

```bash
tools/lsp/lsp-manager.sh check --profile standard
tools/lsp/lsp-manager.sh versions
```

### Complete LSP rebuild

Only when necessary:

```bash
tools/lsp/lsp-manager.sh clean --yes
tools/lsp/lsp-manager.sh install --profile standard
```

---

## 33. Troubleshooting

### `yegappan/lsp` is not declared

Check:

```vim
:KDLspHealth
:version
```

The configuration requires:

```text
Vim 9.0+
+job
+channel
```

### No language server attaches

Check the managed wrappers:

```bash
cd ~/.vim
tools/lsp/lsp-manager.sh check --profile standard
ls -l ~/.local/share/vim-lsp/bin
```

Then in Vim:

```vim
:set filetype?
:KDLspHealth
:LspShowAllServers
:messages
```

### npm `ETARGET` for `typescript@6.0.0`

You are still using the 2.6.0.0 LSP manifest. Replace `tools/lsp/` with the current 2.6.0.2 tree and run:

```bash
rm -rf ~/.local/share/vim-lsp/npm
cd ~/.vim
tools/lsp/lsp-manager.sh install --profile standard
```

Do not remove `~/.local/share/vim-lsp/runtime/node`; it can be reused.

### Old ddc/denops messages still appear

The 2.6 vimrc does not declare ddc or denops. Run:

```vim
:PlugClean
```

Completely exit every Vim process and restart.

If necessary, inspect loaded scripts:

```vim
:filter /ddc\|denops/ scriptnames
```

### Syntastic messages still appear

Syntastic was replaced by ALE. Run:

```vim
:PlugClean
:filter /syntastic/ scriptnames
```

If `:SyntasticCheck` still exists after a complete restart, locate the old runtime with:

```vim
:verbose command SyntasticCheck
```

### Ansible 80-character line-length warning still appears

Confirm the buffer is detected as Ansible:

```vim
:set filetype?
```

Expected:

```text
filetype=yaml.ansible
```

Then inspect:

```vim
:ALEInfo
:LspDiag show
```

For `filetype=yaml.ansible`, `ALEInfo` should list `yamllint_ansible` plus `ansible_lint`. If a line-length item is still visible after upgrading, completely restart Vim first so diagnostics produced by the old session are cleared.

### Copilot does not show ghost text

Check:

```vim
:Copilot status
:KDAIHealth
```

And on the shell:

```bash
node --version
npm --version
```

`<Tab>` accepts visible Copilot ghost text. If no ghost suggestion is visible, it falls back to LSP popup navigation or a normal Tab. `Ctrl-G` remains a secondary full-suggestion accept key.

### Codex is not found

Linux:

```bash
command -v codex
ls -l /usr/local/bin/codex
codex --version
```

If absent, rerun:

```bash
./install-vim-ai-linux-1.0.1.sh
```

### Corporate TLS failures

Use a CA bundle instead of relying on insecure fallback:

```bash
tools/lsp/lsp-manager.sh install --profile standard \
    --ca-bundle /path/to/company-ca.pem
```

For vim-plug add:

```vim
let g:kd_curl_ca_bundle = '/path/to/company-ca.pem'
let g:kd_curl_allow_insecure_fallback = 0
```

---

## 34. Recommended first-run checklist

After a fresh installation or upgrade:

```text
[ ] Correct platform-specific vimrc installed
[ ] vimrc.before.local 1.4.0 installed/reviewed
[ ] tools/lsp tree installed in the Vim repository
[ ] :PlugClean completed when upgrading from 2.5
[ ] :PlugInstall completed
[ ] :PlugUpdate completed
[ ] Vim fully restarted
[ ] lsp-manager install completed with correct profile
[ ] lsp-manager check passes
[ ] :KDLspHealth looks healthy
[ ] :LspShowAllServers shows the expected servers
[ ] :KDModernHealth reviewed
[ ] Ansible file reports filetype=yaml.ansible
[ ] Terraform LSP tested in a .tf file
[ ] Helm LSP tested in a chart/template
[ ] Docker Compose file detected as dockercompose
[ ] Copilot authenticated where enabled
[ ] Codex authenticated on Linux where enabled
```

---

## 35. Related release documentation

The package also contains:

```text
VIM-2.6.0.1-MIGRATION.md
VIM-2.6.0.1-MAINTENANCE.md
VIM-2.6.0.2-MAINTENANCE.md
```

- `README.md` is the primary operational guide.
- `VIM-2.6.0.1-MIGRATION.md` documents the 2.5-to-2.6 architecture transition.
- `VIM-2.6.0.1-MAINTENANCE.md` documents the TypeScript npm pin correction from 2.6.0.0 to 2.6.0.1.
- `VIM-2.6.0.2-MAINTENANCE.md` documents the Ansible line-length and Copilot `<Tab>` corrections.

---

## 36. Important design principles

1. `yegappan/lsp` is the single standard Vim LSP/completion client.
2. Language-server lifecycle is kept outside Vim and version-controlled.
3. The LSP manager uses a private Node runtime so server dependencies do not dictate the system Node version.
4. ALE owns external lint/fix workflows and does not create LSP connections.
5. Ansible LSP does not run its own ansible-lint integration; ALE is the single lint owner.
6. Ansible's generic 80-column warning is disabled only for Ansible buffers.
7. On Linux/macOS, `<Tab>` prefers a visible Copilot ghost-text suggestion and otherwise falls back to LSP popup navigation or a normal Tab.
8. Codex explicit repository editing remains Linux-only in the 2.6 design.
9. MobaXterm remains AI-free.
10. TLS verification is preferred; custom CA bundles are preferred over insecure fallback.
11. Release bundles are distributed as `.tar.gz`.
