# Vim Configuration 2.6.0.8

A maintained classic-Vim configuration for Linux, macOS, and Windows through
MobaXterm. The 2.6 series uses a Vim9-native LSP client, an external and pinned
language-server manager, ALE for linting/fixing, optional GitHub Copilot ghost
text on Linux/macOS, and Linux-only OpenAI Codex command integration.

**Release:** 2.6.0.8  
**Date:** 2026-08-23  
**Primary LSP client:** `yegappan/lsp`  
**Language-server manager:** `tools/lsp/lsp-manager.sh` 1.0.4  
**Default managed-LSP home:** `~/.local/share/vim-lsp`

---

## 1. What is new in 2.6.0.8

### YAML/Ansible diagnostics display and yamllint policy fix

Release 2.6.0.8 fixes two related linting behaviors:

1. `line-length` and `comments-indentation` are now disabled for **all YAML
   buffers**, not only buffers detected as `yaml.ansible`. `truthy` remains
   disabled as part of the same maintained YAML style policy.
2. ALE virtual text is completely disabled. Diagnostics are no longer rendered
   at the end of source lines as comment-like text such as:

```text
# E: line too long (122 > 80 characters)
```

ALE still reports meaningful diagnostics in Vim's bottom command/message area
when the cursor is on the affected line, and still maintains the location list.
The setting responsible for removing inline/end-of-line diagnostics is:

```vim
let g:ale_virtualtext_cursor = 'disabled'
let g:ale_echo_cursor = 1
```

The yegappan/lsp diagnostic display follows the same policy: virtual text and
automatic diagnostic popups are disabled, while status-line diagnostics remain
enabled.

The package-controlled yamllint configuration disables:

```text
line-length
comments-indentation
truthy
```

This policy is passed directly to yamllint, so a plain `yaml` buffer cannot fall
back to ALE's default yamllint rules and reintroduce those messages.

### Docker Language Server installation fix retained from 2.6.0.7

The previous LSP manager constructed the Docker Language Server release asset
as:

```text
docker-language-server-linux-amd64
```

Docker 0.20.1 actually publishes versioned asset names, for example:

```text
docker-language-server-linux-amd64-v0.20.1
```

The old filename did not match any release asset. Because the manager verifies
GitHub binaries using the SHA-256 digest attached to the exact asset, the failed
lookup correctly stopped the installation with:

```text
ERROR: GitHub did not publish a SHA256 asset digest for docker/docker-language-server v0.20.1 docker-language-server-linux-amd64; refusing unverified install.
```

`lsp-manager.sh` 1.0.4 now constructs the Docker asset name with the release
version included. SHA-256 verification remains mandatory; there is no insecure
checksum bypass.

For Docker Language Server 0.20.1 the expected upstream asset patterns are:

```text
docker-language-server-linux-amd64-v0.20.1
docker-language-server-linux-arm64-v0.20.1
docker-language-server-darwin-amd64-v0.20.1
docker-language-server-darwin-arm64-v0.20.1
docker-language-server-windows-amd64-v0.20.1.exe
docker-language-server-windows-arm64-v0.20.1.exe
```

### Package cleanup policy

The 2.6.0.8 archive follows the new packaging rules:

- only the latest version of each maintained file is included;
- all ddc-era Vim configuration files are removed;
- no historical `.diff` files are included;
- no `tools/lsp/history/` directory is included;
- scripts live only under `scripts/`;
- LSP tooling lives only under `tools/lsp/`;
- Markdown documentation and Vim configuration files stay in the package root.

The old ddc/denops/vim-lsp stack is not required by this release.

---

## 2. Package layout

After extraction the archive looks like this:

```text
vim-2.6.0.8-package/
├── README.md
├── VIM-2.6.0.8-MAINTENANCE.md
├── vim-2.6.0.8-SHA256SUMS.txt
├── vimrc-linux-lsp
├── vimrc-windows-mobaxterm-lsp
├── vimrc.before.local-1.4.0
├── scripts/
│   ├── install-vim-ai-linux-1.0.2.sh
│   └── install-vim-copilot-macos-1.0.1.sh
└── tools/
    └── lsp/
        ├── lsp-manager.sh
        ├── versions.conf
        └── npm/
            ├── package.json
            └── package-lock.json
```

The two `vimrc-*` files are the canonical current deployment files. Historical
or duplicate release-labelled Vimrc snapshots are intentionally not included.

---

## 3. Architecture overview

The 2.6 configuration deliberately separates the Vim client from language
server installation:

```text
                     ┌─────────────────────────────┐
                     │            Vim              │
                     │                             │
                     │ yegappan/lsp  ───────────┐ │
                     │ ALE                     │ │ │
                     │ vim-plug plugins        │ │ │
                     └─────────────────────────┼─┼─┘
                                               │ │
                           LSP protocol         │ │ external linters/fixers
                                               │ │
                     ┌─────────────────────────▼─┐
                     │ ~/.local/share/vim-lsp   │
                     │                          │
                     │ bin/ stable wrappers     │
                     │ runtime/node/            │
                     │ npm/                     │
                     │ servers/                 │
                     │ cache/                   │
                     └──────────────────────────┘
```

### Responsibilities

| Component | Purpose |
|---|---|
| `yegappan/lsp` | Completion, hover, navigation, rename, code actions, formatting, LSP diagnostics |
| `tools/lsp/lsp-manager.sh` | Installs and verifies pinned language-server runtimes |
| ALE | External linting and fixing; LSP mode is explicitly disabled in ALE |
| vim-plug | Installs Vim plugins |
| GitHub Copilot | Optional inline ghost-text AI completion on Linux/macOS |
| Codex CLI integration | Optional deliberate AI actions from Vim on Linux |

The old architecture based on `ddc.vim`, `denops.vim`, Deno, `vim-lsp`, and
`vim-lsp-settings` has been removed from the standard configuration.

---

## 4. Supported platforms

| Capability | Linux | macOS | MobaXterm |
|---|---:|---:|---:|
| Classic Vim | Yes | Yes | Yes |
| `yegappan/lsp` | Yes | Yes | Yes |
| Standard managed LSP profile | Yes | Yes | No |
| MobaXterm managed LSP profile | No | No | Yes |
| ALE | Yes | Yes | Yes |
| GitHub Copilot ghost text | Optional | Optional | Disabled |
| Codex Vim commands | Optional | Disabled | Disabled |
| Deno/denops required | No | No | No |

### Minimum Vim requirements

For the LSP stack:

```text
Vim 9.0+
+job
+channel
```

Check your Vim build:

```bash
vim --version | head
vim --version | grep -E '\+job|\+channel'
```

Inside Vim:

```vim
:version
:KDLspHealth
```

GitHub Copilot additionally requires a sufficiently recent Vim with text
properties; the included macOS helper checks Vim 9.0.0185+ and `+textprop`.

---

## 5. Quick installation

### 5.1 Extract the archive

```bash
tar -xzf vim-2.6.0.8.tar.gz
cd vim-2.6.0.8-package
```

### 5.2 Verify the extracted files

Linux:

```bash
sha256sum -c vim-2.6.0.8-SHA256SUMS.txt
```

macOS:

```bash
shasum -a 256 -c vim-2.6.0.8-SHA256SUMS.txt
```

Do not continue if a checksum fails.

### 5.3 Back up the current Vim configuration

Linux/macOS/MobaXterm shell:

```bash
[ ! -e ~/.vimrc ] || cp -a ~/.vimrc ~/.vimrc.backup-$(date +%Y%m%d-%H%M%S)
[ ! -e ~/.vimrc.before.local ] || cp -a ~/.vimrc.before.local ~/.vimrc.before.local.backup-$(date +%Y%m%d-%H%M%S)
```

If your Windows Vim uses `_vimrc` rather than `.vimrc`, confirm the active file
from Vim before replacing anything:

```vim
:echo $MYVIMRC
```

---

## 6. Linux installation

### 6.1 Install the Vim files

```bash
cp vimrc-linux-lsp ~/.vimrc
cp vimrc.before.local-1.4.0 ~/.vimrc.before.local
```

### 6.2 Required base commands

The configuration and LSP manager expect these commands to be available where
applicable:

```text
vim
git
curl
tar
unzip
sha256sum or shasum
```

For Node extraction on Unix, the system `tar` must support xz archives.

Recommended development utilities include:

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

They are not all mandatory. Missing optional tools are reported by
`:KDModernHealth` and only affect the corresponding feature.

### 6.3 Install Vim plugins

Start Vim and run:

```vim
:PlugInstall
```

For a non-interactive first installation:

```bash
vim +PlugInstall +qall
```

The vimrc can bootstrap vim-plug automatically when it is missing. Git is still
required for plugin installation.

### 6.4 Install the language servers

Recommended:

```bash
tools/lsp/lsp-manager.sh install --profile standard --strict-tls
```

If your network uses a private CA:

```bash
tools/lsp/lsp-manager.sh install \
  --profile standard \
  --ca-bundle /path/to/company-ca-bundle.pem
```

The default manager retains a compatibility TLS fallback unless
`--strict-tls`/`--no-insecure-fallback` is supplied. For a managed environment,
a trusted CA bundle is preferable to allowing `curl --insecure`.

### 6.5 Validate

From the shell:

```bash
tools/lsp/lsp-manager.sh check --profile standard
tools/lsp/lsp-manager.sh list
tools/lsp/lsp-manager.sh versions
```

From Vim:

```vim
:KDLspHealth
:KDModernHealth
```

---

## 7. macOS installation

### 7.1 Install the Vim files

```bash
cp vimrc-linux-lsp ~/.vimrc
cp vimrc.before.local-1.4.0 ~/.vimrc.before.local
```

The Linux-labelled vimrc is intentionally the shared Unix configuration and
contains explicit Linux/macOS platform checks. Linux-only Codex integration is
filtered out automatically on macOS.

### 7.2 Install Vim plugins

```bash
vim +PlugInstall +qall
```

### 7.3 Install managed language servers

```bash
tools/lsp/lsp-manager.sh install --profile standard --strict-tls
```

Both Intel (`amd64`) and Apple Silicon (`arm64`) are detected automatically.

### 7.4 Optional GitHub Copilot prerequisites

The helper script installs/checks the Node.js prerequisite used by
`github/copilot.vim`:

```bash
scripts/install-vim-copilot-macos-1.0.1.sh
```

Then inside Vim:

```vim
:PlugInstall
:Copilot setup
:KDAIHealth
```

Codex Vim commands remain disabled on macOS in this configuration.

---

## 8. MobaXterm installation

MobaXterm uses its dedicated Vim configuration and LSP profile.

### 8.1 Confirm the active Vim configuration path

Inside MobaXterm Vim:

```vim
:echo $MYVIMRC
```

For a normal MobaXterm shell installation the target is commonly `~/.vimrc`.
Use the path returned by `$MYVIMRC` if your setup differs.

### 8.2 Install the configuration

```bash
cp vimrc-windows-mobaxterm-lsp ~/.vimrc
cp vimrc.before.local-1.4.0 ~/.vimrc.before.local
```

The MobaXterm vimrc strips both AI bundle groups, so neither Copilot nor Codex
is loaded there.

### 8.3 Install plugins

```bash
vim +PlugInstall +qall
```

### 8.4 Install language servers

```bash
tools/lsp/lsp-manager.sh install --profile mobaxterm
```

The manager detects the MobaXterm/MSYS/Cygwin-style environment and uses native
Windows assets where available. Ensure `curl`, `unzip`, and a SHA-256 utility
are available in the shell.

### 8.5 Validate

```bash
tools/lsp/lsp-manager.sh check --profile mobaxterm
```

Inside Vim:

```vim
:KDLspHealth
:KDModernHealth
```

---

## 9. LSP manager reference

The manager is:

```text
tools/lsp/lsp-manager.sh
```

Current manager version:

```text
1.0.4
```

Display help:

```bash
tools/lsp/lsp-manager.sh --help
```

Expected first line:

```text
lsp-manager.sh 1.0.4
```

### 9.1 Profiles

| Profile | Intended use | Native binaries |
|---|---|---|
| `standard` | Linux/macOS | Terraform LS, Helm LS, Docker LS |
| `mobaxterm` | MobaXterm/Windows shell | Windows-native assets where available |
| `minimal` | Only npm language servers | No Terraform/Helm/Docker binaries |

### 9.2 Actions

#### Install

```bash
tools/lsp/lsp-manager.sh install --profile standard
```

Creates/recreates the pinned managed runtime.

#### Update

```bash
tools/lsp/lsp-manager.sh update --profile standard
```

`update` installs the versions currently pinned by this package. It does **not**
silently move to whatever upstream version happens to be newest.

#### Check

```bash
tools/lsp/lsp-manager.sh check --profile standard
```

Shows manager version, detected platform, managed home, private Node runtime,
and server paths.

#### List

```bash
tools/lsp/lsp-manager.sh list
```

Shows the stable executable path for every managed server.

#### Versions

```bash
tools/lsp/lsp-manager.sh versions
```

Displays native version pins plus npm package pins.

#### Lock

```bash
tools/lsp/lsp-manager.sh lock
```

Maintenance command. Expands/regenerates the npm lock data in the package tool
tree. Normal users do not need this for installation.

#### Clean

```bash
tools/lsp/lsp-manager.sh clean --yes
```

Deletes the complete managed LSP home. The `--yes` flag is mandatory.

### 9.3 Manager options

```text
--profile standard|mobaxterm|minimal
--ca-bundle FILE
--strict-tls
--no-insecure-fallback
--yes
--home DIR
-h, --help
```

`--home DIR` changes the manager root for that invocation. The Vim configuration
uses `~/.local/share/vim-lsp` unless `g:kd_lsp_home` is overridden before the
main vimrc loads.

---

## 10. Managed LSP filesystem

Default layout:

```text
~/.local/share/vim-lsp/
├── bin/               # stable server entry points used by Vim
├── cache/             # downloaded archives/assets and release metadata
├── npm/               # pinned npm language-server installation
├── runtime/
│   └── node/          # manager-owned private Node.js runtime
└── servers/           # native language-server binaries by version/tag
```

The manager-owned Node runtime is intentionally separate from the operating
system Node installation. Updating or replacing system Node therefore does not
silently change the managed npm LSP runtime.

Vim prepends the managed `bin/` directory to the PATH it exposes to child
processes when that directory exists.

---

## 11. Pinned language-server versions

Native/runtime pins from `tools/lsp/versions.conf`:

| Component | Pin |
|---|---:|
| Private Node.js | 24.19.0 |
| terraform-ls | 0.39.0 |
| docker-language-server | 0.20.1 |
| helm-ls | `master` release tag |

Pinned npm packages from `tools/lsp/npm/package.json`:

| Package | Version | Main executable(s) |
|---|---:|---|
| `@ansible/ansible-language-server` | 26.6.0 | `ansible-language-server` |
| `@zed-industries/vscode-langservers-extracted` | 4.10.8 | JSON/HTML/CSS language servers |
| `bash-language-server` | 5.6.0 | `bash-language-server` |
| `pyright` | 1.1.413 | `pyright-langserver` |
| `typescript` | 6.0.3 | TypeScript runtime |
| `typescript-language-server` | 6.0.0 | `typescript-language-server` |
| `vim-language-server` | 2.3.1 | `vim-language-server` |
| `yaml-language-server` | 1.24.0 | `yaml-language-server` |

Vim expects the following stable manager executables:

```text
bash-language-server
yaml-language-server
ansible-language-server
pyright-langserver
typescript-language-server
vscode-json-language-server
vscode-html-language-server
vscode-css-language-server
vim-language-server
terraform-ls
helm_ls
docker-language-server
```

---

## 12. Download verification model

The manager fails closed when it cannot obtain a trustworthy checksum.

### Node.js

The archive is verified against the matching official Node
`SHASUMS256.txt` entry.

### terraform-ls

The downloaded ZIP is verified against HashiCorp's published
`SHA256SUMS` file for the pinned version.

### GitHub native binaries

For GitHub release binaries such as Helm LS and Docker Language Server, the
manager reads the SHA-256 asset digest from GitHub release metadata and compares
it with the locally downloaded file.

If no digest is found, installation stops rather than accepting an unverified
binary.

### Why the Docker 0.20.1 error happened

The 2.6.0.6 manager searched release metadata using a filename that Docker did
not publish. Therefore it could not find the digest. The 2.6.0.8 manager uses
the real versioned filename and keeps the same mandatory digest check.

---

## 13. Vim LSP configuration

When `yegappan/lsp` attaches to a buffer, the configuration adds these
buffer-local mappings:

| Mapping | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Show references |
| `gi` | Go to implementation |
| `gt` | Go to type definition |
| `K` | Hover information |
| `<leader>rn` | Rename symbol |
| `[g` | Previous diagnostic |
| `]g` | Next diagnostic |
| `<leader>ca` | Code action |
| `<leader>lf` | LSP format |

The manager wrappers are preferred over system-installed language servers. If a
managed executable is not present, the vimrc can fall back to an executable
found in PATH.

### Filetype/server mapping

| Filetype | LSP server |
|---|---|
| Shell | bash-language-server |
| YAML / Compose | yaml-language-server |
| Ansible | ansible-language-server |
| Python | pyright |
| JavaScript/TypeScript | typescript-language-server |
| JSON | vscode-json-language-server |
| HTML | vscode-html-language-server |
| CSS/SCSS/Less | vscode-css-language-server |
| Vim script | vim-language-server |
| Terraform | terraform-ls |
| Helm | helm_ls |
| Dockerfile / Compose | docker-language-server |

Compose filenames such as these are explicitly detected:

```text
docker-compose.yml
docker-compose.yaml
compose.yml
compose.yaml
```

---

## 14. ALE linting and fixing

ALE is retained as the external linter/fixer layer and is configured with:

```vim
let g:ale_disable_lsp = 1
```

This avoids having two competing LSP clients.

Important ALE mappings:

| Mapping | Action |
|---|---|
| `<leader>zl` | Run ALE lint |
| `<leader>zf` | Run ALE fixer |
| `<leader>zn` | Next ALE diagnostic |
| `<leader>zp` | Previous ALE diagnostic |

### YAML/Ansible policy

The same yamllint policy is used for normal YAML and Ansible YAML buffers. The
following style-only rules are intentionally suppressed everywhere in Vim:

```text
line-length
comments-indentation
truthy
```

This means messages such as `comment not indented like content` and `line too
long (...)` are not reported by the Vim yamllint integration. All other
configured YAML and Ansible diagnostics stay enabled.

### Diagnostic presentation

ALE diagnostics are deliberately **not** drawn beside source code. In
particular, Vim will not append virtual text such as `# E: ...` to the end of a
line. ALE is configured to echo the active diagnostic in the bottom
command/message area instead:

```vim
let g:ale_echo_cursor = 1
let g:ale_virtualtext_cursor = 'disabled'
let g:ale_cursor_detail = 0
let g:ale_open_list = 0
let g:ale_set_loclist = 1
```

The LSP client is configured consistently:

```vim
showDiagInPopup: false
showDiagOnStatusLine: true
showDiagWithVirtualText: false
```

Recommended external Ansible tooling:

```text
yamllint
ansible-lint
```

Other optional ALE tools include `shellcheck`, `ruff`, `hadolint`, `terraform`,
and `tflint`.

---

## 15. Git, search, and navigation mappings

Frequently used mappings from the standard configuration include:

### FZF

| Mapping | Action |
|---|---|
| `<leader>ff` | Files |
| `<leader>fg` | Git files |
| `<leader>fb` | Buffers |
| `<leader>fl` | Lines |
| `<leader>fh` | History |
| `<leader>fc` | Commits |
| `<leader>fr` | Ripgrep search, when `rg` exists |

### Git/Fugitive

| Mapping | Action |
|---|---|
| `<leader>gs` | Git status/interface |
| `<leader>gd` | Git diff split |
| `<leader>gc` | Git commit |
| `<leader>gb` | Git blame |
| `<leader>gl` | Git log |
| `<leader>gp` | Git push |
| `<leader>gr` | Git read |
| `<leader>gw` | Git write |
| `<leader>ge` | Git edit |
| `<leader>gi` | Interactive add/patch for current file |
| `<leader>gv` | GV history |

### GitGutter

| Mapping | Action |
|---|---|
| `]h` | Next hunk |
| `[h` | Previous hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hu` | Undo hunk |

### Miscellaneous

| Mapping | Action |
|---|---|
| `<F5>` / `<leader>u` | Toggle Undotree |
| `<leader>tt` | Toggle Tagbar when Ctags is available |
| `<leader>w` | Save file |
| `<leader>/` | Clear/toggle search highlighting |

---

## 16. Terraform and Helm

Terraform mappings:

| Mapping | Action |
|---|---|
| `<leader>tf` | `TerraformFmt` |
| `<leader>tv` | `Terraform validate` |

Helm mappings when the Helm CLI is available:

| Mapping | Action |
|---|---|
| `<leader>hl` | `helm lint` on chart directory |
| `<leader>ht` | `helm template` on chart directory |

Language intelligence is provided by `terraform-ls` and `helm_ls`; CLI tools
are still useful for lint/validate/template operations.

---

## 17. AI integration

AI is intentionally separate from normal LSP completion.

### Linux

The standard profile may enable both:

```text
github/copilot.vim
OpenAI Codex CLI integration
```

Optional helper:

```bash
scripts/install-vim-ai-linux-1.0.2.sh
```

Useful options:

```text
--ca-bundle FILE
--strict-tls
--skip-packages
--skip-codex
```

After prerequisites are ready:

```vim
:PlugInstall
:Copilot setup
:KDAIHealth
```

Copilot mappings:

| Mapping | Action |
|---|---|
| `<Tab>` | Accept visible Copilot ghost text; otherwise keep popup/Tab fallback behavior |
| `<C-G>` | Accept Copilot suggestion without the normal fallback |
| `<leader>cp` | Copilot panel |
| `<leader>cs` | Copilot status |
| `<leader>ce` | Enable Copilot |
| `<leader>cd` | Disable Copilot |
| `<leader>cm` | Copilot model |
| `<leader>cu` | Copilot upgrade |

Codex mappings on Linux:

| Mapping | Action |
|---|---|
| `<leader>as` | AI status |
| `<leader>aa` | Ask |
| `<leader>ae` | Edit |
| `<leader>ax` | Explain |
| `<leader>af` | Fix |
| `<leader>ar` | Refactor |
| `<leader>at` | Generate/test task |
| `<leader>ad` | Document |
| `<leader>ag` | Git review |
| `<leader>ap` | Custom prompt |
| `<leader>ao` | Open Codex terminal/session |

### macOS

The standard Unix vimrc keeps GitHub Copilot but removes the Linux-only Codex
bundle automatically.

Optional helper:

```bash
scripts/install-vim-copilot-macos-1.0.1.sh
```

### MobaXterm

AI groups are removed. MobaXterm uses regular Vim/LSP completion only.

---

## 18. Bundle-group customization

`vimrc.before.local-1.4.0` defines the standard profile:

```vim
let g:kd_bundle_groups = [
      \ 'general',
      \ 'lsp',
      \ 'ale',
      \ 'programming',
      \ 'markdown',
      \ 'ruby',
      \ 'ansible',
      \ 'python',
      \ 'docker',
      \ 'javascript',
      \ 'html',
      \ 'terraform',
      \ 'helm',
      \ 'misc',
      \ 'github_copilot',
      \ 'codex',
      \ ]
```

Edit `~/.vimrc.before.local` to remove groups you do not need.

Additional supported optional groups in the vimrc include:

```text
extra
colorschemes
writing
gist
snipmate
youcompleteme
php
scala
haskell
puppet
go
elixir
asciidoc
```

The recommended 2.6 completion path is the `lsp` group. `youcompleteme` and
`snipmate` remain optional legacy alternatives and are not part of the standard
profile.

---

## 19. Local override files

The main vimrc reads local overrides so site-specific settings do not need to be
merged into the maintained file.

### Before-local file

```text
~/.vimrc.before.local
```

Use this for options that must exist before plugin declarations, especially:

```text
g:kd_bundle_groups
g:kd_lsp_home
statusline/theme choices
curl CA/fallback settings
```

### Local plugin bundle file

```text
~/.vimrc.bundles.local
```

Use this for additional local vim-plug declarations.

Keeping personal/site-specific changes in local files makes future replacement
of the main vimrc much simpler.

---

## 20. Health and troubleshooting commands

### `:KDLspHealth`

Shows:

- Vim version/capability state;
- managed LSP root and `bin/` path;
- whether `yegappan/lsp` is declared;
- each expected server and its resolved executable path.

Compatibility alias:

```vim
:KDCompletionHealth
```

### `:KDModernHealth`

Checks important external tools such as:

```text
fzf
rg
ctags
terraform
helm
ansible-lint
yamllint
shellcheck
ruff
hadolint
tflint
```

It also reports if stale Syntastic state is still loaded.

### `:KDAIHealth`

On supported platforms, checks Copilot and Codex integration state.

---

## 21. Troubleshooting

### Error: Docker Language Server SHA256 digest not published

Old error:

```text
ERROR: GitHub did not publish a SHA256 asset digest for docker/docker-language-server v0.20.1 docker-language-server-linux-amd64; refusing unverified install.
```

Check the manager version:

```bash
tools/lsp/lsp-manager.sh --help | head -n 1
```

Required:

```text
lsp-manager.sh 1.0.4
```

Then rerun:

```bash
tools/lsp/lsp-manager.sh install --profile standard --strict-tls
```

Do not work around this error by disabling SHA-256 verification.

### A stale manager still runs

Find all copies:

```bash
find . "$HOME" -name lsp-manager.sh -type f -print 2>/dev/null
```

Verify the exact file you execute:

```bash
./tools/lsp/lsp-manager.sh --help | head -n 1
```

### Language server is not installed

```bash
tools/lsp/lsp-manager.sh check --profile standard
tools/lsp/lsp-manager.sh list
```

Then reinstall:

```bash
tools/lsp/lsp-manager.sh install --profile standard
```

### Corporate/self-signed CA errors

Preferred solution:

```bash
tools/lsp/lsp-manager.sh install \
  --profile standard \
  --ca-bundle /path/to/internal-ca-bundle.pem
```

Forbid fallback entirely:

```bash
tools/lsp/lsp-manager.sh install --profile standard --strict-tls
```

### `unzip` is missing

Install/provide `unzip`; it is required for native ZIP payloads such as
terraform-ls and for Windows Node distributions.

### Vim has no `+job` or `+channel`

Install a full Vim build rather than a minimal/`tiny` build. Recheck:

```bash
vim --version | grep -E '\+job|\+channel'
```

### Plugins are missing after replacing the vimrc

Inside Vim:

```vim
:PlugInstall
```

For stale plugins that were removed from the maintained configuration:

```vim
:PlugClean
```

Review the list before confirming removal.

### A suppressed yamllint warning unexpectedly returns

The maintained Vim policy suppresses `line-length`, `comments-indentation`, and
`truthy` for both `yaml` and `yaml.ansible`. First confirm the active filetype:

```vim
:set filetype?
```

Then inspect the active ALE configuration:

```vim
:ALEInfo
```

For a current 2.6.0.8 configuration, ALE virtual text must report as disabled
and yamllint must be invoked with the package-controlled rule overrides. If an
old Vim instance was still running during the upgrade, exit **all** Vim
instances and start Vim again before testing.

### Docker Compose LSP does not start

Confirm the filename and filetype:

```vim
:set filetype?
```

Expected for recognized Compose files:

```text
dockercompose
```

Also check:

```vim
:KDLspHealth
```

and from the shell:

```bash
tools/lsp/lsp-manager.sh list | grep docker
```

---

## 22. Updating the configuration

Recommended workflow for a future package:

1. Extract the new archive into a separate directory.
2. Verify the archive and package checksums.
3. Compare your local `~/.vimrc.before.local` with the new shipped default.
4. Back up the current main vimrc.
5. Replace the main vimrc with the new canonical file.
6. Run `:PlugUpdate`.
7. Run the current package's `tools/lsp/lsp-manager.sh update` with the correct profile.
8. Run `:PlugClean` only after reviewing plugins that will be removed.
9. Run `:KDLspHealth`, `:KDModernHealth`, and, when applicable, `:KDAIHealth`.

Linux/macOS main vimrc:

```bash
cp vimrc-linux-lsp ~/.vimrc
```

MobaXterm main vimrc:

```bash
cp vimrc-windows-mobaxterm-lsp ~/.vimrc
```

---

## 23. Updating language-server pins

Normal users should consume the package pins unchanged. For package
maintenance:

### Native versions

Edit:

```text
tools/lsp/versions.conf
```

### npm versions

Edit:

```text
tools/lsp/npm/package.json
```

Then regenerate the lock seed/lock data as appropriate using:

```bash
tools/lsp/lsp-manager.sh lock
```

After any version change, test at least:

```bash
bash -n tools/lsp/lsp-manager.sh
tools/lsp/lsp-manager.sh --help
tools/lsp/lsp-manager.sh versions
tools/lsp/lsp-manager.sh install --profile standard
tools/lsp/lsp-manager.sh check --profile standard
```

For MobaXterm support, also validate the `mobaxterm` profile and Windows asset
names.

---

## 24. Security recommendations

1. Keep SHA-256 verification enabled for downloaded language-server assets.
2. Prefer `--strict-tls` on normal Internet connections.
3. In networks with TLS interception, install/trust the organization CA or use
   `--ca-bundle` rather than relying on `curl --insecure`.
4. Review changes to `versions.conf` and npm package pins before running an
   update.
5. Do not run `clean --yes` unless you intend to remove the complete managed
   LSP runtime.
6. Keep personal overrides in local Vim files instead of editing the maintained
   main vimrc in place.
7. Keep only current scripts/tools in redistributed tar packages; do not re-add
   old ddc files or historical tool copies.

---

## 25. Upstream projects

Primary upstream components used by this configuration:

- Vim: https://www.vim.org/
- vim-plug: https://github.com/junegunn/vim-plug
- yegappan/lsp: https://github.com/yegappan/lsp
- ALE: https://github.com/dense-analysis/ale
- Docker Language Server: https://github.com/docker/docker-language-server
- terraform-ls: https://github.com/hashicorp/terraform-ls
- helm-ls: https://github.com/mrjosh/helm-ls
- GitHub Copilot Vim plugin: https://github.com/github/copilot.vim
- OpenAI Codex: https://openai.com/codex/

---

## 26. Release-maintenance rules

For future Vim tar.gz releases:

- include only the latest maintained version of each file;
- do not include ddc configuration variants;
- keep scripts under `scripts/`;
- keep LSP/tool payload under `tools/`;
- keep Markdown files and Vim configuration files in the package root;
- do not keep historical diffs/tool history inside the release archive;
- regenerate the package SHA-256 manifest after every content change.

These rules are part of the maintained package format from 2.6.0.8 onward.
