# Vim configuration 1.5.2.1 — distribution package 2.7.2.1

**Release date:** 2026-10-31  
**Editor:** classic Vim 9.x, not Neovim  
**LSP client:** `yegappan/lsp`  
**Asynchronous linting:** `dense-analysis/ale`  
**Plugin manager:** `vim-plug`  
**Targets:** native Linux, native macOS, Windows MobaXterm, Windows WSL2

This is the complete installation, migration, operating and troubleshooting manual for
package **2.7.2.1**. The Vim configuration itself is **1.5.2.1**. They are different
version numbers on purpose. No older Vimrc snapshots or ddc variants are included.

## Table of contents

1. [What changed](#1-what-changed)
2. [Choose exactly one platform](#2-choose-exactly-one-platform)
3. [Package contents](#3-package-contents)
4. [Requirements and prerequisites](#4-requirements-and-prerequisites)
5. [Install and migrate safely](#5-install-and-migrate-safely)
6. [Linux](#6-linux)
7. [macOS](#7-macos)
8. [Windows MobaXterm](#8-windows-mobaxterm)
9. [Windows WSL2](#9-windows-wsl2)
10. [LSP manager and server lifecycle](#10-lsp-manager-and-server-lifecycle)
11. [Plugin and completion architecture](#11-plugin-and-completion-architecture)
12. [YAML, Ansible and diagnostic display](#12-yaml-ansible-and-diagnostic-display)
13. [Lightline and colorscheme](#13-lightline-and-colorscheme)
14. [GitHub Copilot and Codex](#14-github-copilot-and-codex)
15. [Keyboard shortcuts and health commands](#15-keyboard-shortcuts-and-health-commands)
16. [Certificates, proxies and security](#16-certificates-proxies-and-security)
17. [Troubleshooting](#17-troubleshooting)
18. [Updating, backing up and rolling back](#18-updating-backing-up-and-rolling-back)
19. [Validation and release policy](#19-validation-and-release-policy)

## 1. What changed

Hotfix 2.7.2.1 restores the manual `:FixWhitespace` command, removes the misleading trailing-space dots, and restores MobaXterm npm TLS/CA compatibility. Existing AI defaults,
plugin choices, and language-server versions are unchanged.

This is a focused maintenance hotfix for 2.7.2, incorporating the whitespace corrections and MobaXterm TLS compatibility fix.
**OS isolation is unchanged:** Linux, macOS, MobaXterm and WSL2 have
separate and complete Vimrc files. The language-server pins and YAML/Ansible diagnostic policy remain unchanged. The MobaXterm manager is updated to 1.1.3 to restore Node/npm CA support.
Copilot and Codex are now opt-in and **off by default on all platforms**.

- **Lightline is now the only statusline.** The older plugin declarations,
  option switches, code blocks and the Vimrc's competing hand-written
  `statusline` have been removed. `grb256` remains your default editor theme;
  Lightline uses its `wombat` palette for the bar.
- **Fern** replaces NERDTree as the default file explorer.
- **Stargate** replaces EasyMotion as the default jump helper. It uses popup
  labels instead of modifying buffer text, so it doesn't disturb diagnostics.
- **Expand Region** replaces archived Wildfire for growing/shrinking a selection.
- Native Vim `listchars` is the default whitespace visualization, instead of
  an indent plugin; **no `trail:.` or `nbsp:.` dot markers remain**. The original space-based indent guides remain optional.
  `Yggdroot/indentLine` was deliberately NOT added: upstream archived it, and
  its conceal semantics can obscure YAML/JSON markup.
- `vim-over`, NERDTree, EasyMotion, Wildfire, and vim-indent-guides can still
  be selected individually with the documented options below.
- JavaScript is simplified to `pangloss/vim-javascript`; LESS, JST and
  CoffeeScript are now separate opt-in groups. Rails, Haml, Rust and Cucumber
  are also opt-in, rather than loaded by default.
- Retired the unused SnipMate and YouCompleteMe alternative completion branches,
  leaving `yegappan/lsp` and ALE as the default clients.
- Copilot/Codex now use boolean flags in `vimrc.before.local`; neither loads by
  default, regardless of old bundle names or previous default bundle lists.
- All other intended optional bundles have been preserved. **No plugin version
  snapshots, SHA pins or plugin reproducibility feature have been introduced.**

**Versioning:** the Vimrc files have configuration revision **1.5.2.1** and the
full archive is release **2.7.2.1**. The two LSP manager scripts have independent versions; the MobaXterm manager is now 1.1.3, while Linux/macOS stays 1.1.0. You do not need to reinstall language servers just
because plugin declarations changed.

## 2. Choose exactly one platform

| Target runtime | Vimrc to install as `~/.vimrc` | Local template to install as `~/.vimrc.before.local` | LSP manager | AI |
|---|---|---|---|---|
| Native Linux | `vimrc-linux-lsp` | `vimrc.before.local-linux` | `lsp-manager-linux-macos.sh` | Copilot/Codex opt-in (both off) |
| Native macOS | `vimrc-macos-lsp` | `vimrc.before.local-macos` | `lsp-manager-linux-macos.sh` | Copilot opt-in (off) |
| Windows MobaXterm terminal Vim | `vimrc-windows-mobaxterm-lsp` | `vimrc.before.local-mobaxterm` | `lsp-manager-mobaxterm.sh` | AI unsupported (off) |
| WSL2 Linux distribution | `vimrc-wsl2-lsp` | `vimrc.before.local-wsl2` | `lsp-manager-linux-macos.sh` | Copilot/Codex opt-in (both off) |

**Do not mix the files.** Install exactly one pair. All Vimrc files are
self-contained and include their own plugin declarations and behavior. A
separate shared Vimrc library is deliberately NOT required.

**WSL2 is not MobaXterm.** Vim and language servers inside WSL2 are Linux
executables. Use Linux `node`, npm and `terraform-ls`, never the Windows
`node.exe` or the MobaXterm `npm.cmd` bridge.

## 3. Package contents

```text
vim-2.7.2.1-package/
├── README.md
├── VIM-2.7.2.1-MAINTENANCE.md
├── vim-2.7.2.1-SHA256SUMS.txt
├── vimrc-linux-lsp
├── vimrc-macos-lsp
├── vimrc-windows-mobaxterm-lsp
├── vimrc-wsl2-lsp
├── vimrc.before.local-linux
├── vimrc.before.local-macos
├── vimrc.before.local-mobaxterm
├── vimrc.before.local-wsl2
├── scripts/
│   ├── install-vim-ai-linux-1.0.2.sh
│   └── install-vim-copilot-macos-1.0.1.sh
└── tools/
    └── lsp/
        ├── lsp-manager-linux-macos.sh
        ├── lsp-manager-mobaxterm.sh
        ├── versions.conf
        └── npm/
            ├── package.json
            └── package-lock.json
```

Only the latest version of each item is packaged. No `ddc`, denops,
previous-version files, historical `.diff` artifacts, or stale merged manager.
All scripts belong under `scripts/`; manager tooling and npm metadata belong
under `tools/lsp/`; Vimrc files, manual and release metadata are at the root.

## 4. Requirements and prerequisites

Use Vim **9.0+** with `+job` and `+channel` for yegappan/lsp. Vim 9.1 is a
sensible baseline. The Copilot Vim extension needs at least Vim 9.0.0185,
`+textprop`, and a compatible Node.js (GitHub currently documents Node 18+).

Check:

```bash
vim --version | head -n 6
vim --version | grep -E '\+job|\+channel|\+textprop'
command -v git curl
```

Common optional utilities: `rg` (ripgrep), `fzf` >= 0.54, Universal Ctags,
`ansible-lint`, `yamllint`, `shellcheck`, `ruff`, `hadolint`, `tflint`,
Terraform, Helm and Git. A tool is only needed if you use its feature.

The LSP manager provisions its own Node runtime under
`~/.local/share/vim-lsp/`; it does not require overwriting system Node.
GitHub Copilot runs through its own plugin, which also needs `node` on PATH.

### Files and paths

| Path | Purpose |
|---|---|
| `~/.vimrc` | Main Vim configuration chosen for this OS |
| `~/.vimrc.before.local` | OS-specific bundles, statusline and theme settings, sourced early |
| `~/.vimrc.local` | User modifications sourced near the end |
| `~/.gvimrc.local` | GUI-only overrides where available |
| `~/.vim/autoload/plug.vim` | vim-plug manager code |
| `~/.vim/plugged/` | Plugins installed by vim-plug |
| `~/.local/share/vim-lsp/` | Independently managed language-server runtime |
| `~/.local/share/vim-lsp/bin/` | Stable language-server wrappers |

## 5. Install and migrate safely

These steps do not remove your existing profile or plugin tree:

1. Unpack the release to a working directory.
2. Back up the current `~/.vimrc`, `~/.vimrc.before.local`, and
   `~/.vimrc.local` if present.
3. Copy the matching Vimrc and matching local template, not all four profiles.
4. Compare customizations from your old local files before overwriting them.
5. Exit Vim completely and restart it; then run `:PlugInstall` or
   `:PlugUpdate`, followed by `:PlugClean` **after** reviewing removal prompts.
6. Install/check the OS's language servers using the matching manager.
7. Run `:KDLspHealth`, `:KDModernHealth` and, where supported,
   `:KDAIHealth`.

Back up first:

```bash
stamp=$(date +%Y%m%d-%H%M%S)
[ ! -f "$HOME/.vimrc" ] || cp -p "$HOME/.vimrc" "$HOME/.vimrc.$stamp.bak"
[ ! -f "$HOME/.vimrc.before.local" ] || cp -p "$HOME/.vimrc.before.local" "$HOME/.vimrc.before.local.$stamp.bak"
[ ! -f "$HOME/.vimrc.local" ] || cp -p "$HOME/.vimrc.local" "$HOME/.vimrc.local.$stamp.bak"
```

If your old local profile had extra custom variables, merge them into the
new OS-specific template; do not blindly discard site-specific settings.

## 6. Linux

From the extracted `vim-2.7.2.1-package/` directory:

```bash
cp -p vimrc-linux-lsp "$HOME/.vimrc"
cp -p vimrc.before.local-linux "$HOME/.vimrc.before.local"
vim
```

Inside Vim:

```vim
:PlugInstall
:KDLspHealth
:KDModernHealth
```

Install the standard managed LSP set:

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
tools/lsp/lsp-manager-linux-macos.sh check
```

For only the npm-based LSP servers:

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile minimal
```

Optional Linux AI prerequisites script:

```bash
bash scripts/install-vim-ai-linux-1.0.2.sh --help
```

Review its supported options and installation actions before running it.
Linux uses POSIX wrappers for the managed servers and never routes npm through
`cmd.exe`.

## 7. macOS

Use Homebrew or your normal package manager for Vim 9.x, Git, curl, and any
other desired utilities. From the extracted package:

```bash
cp -p vimrc-macos-lsp "$HOME/.vimrc"
cp -p vimrc.before.local-macos "$HOME/.vimrc.before.local"
vim
```

Then:

```vim
:PlugInstall
:KDLspHealth
:KDAIHealth
```

Install native macOS language servers:

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
tools/lsp/lsp-manager-linux-macos.sh check
```

Optional Copilot prerequisite installer:

```bash
bash scripts/install-vim-copilot-macos-1.0.1.sh
```

The macOS Vimrc uses macOS fonts and GitHub Copilot. It does not include the
Linux-only Codex Vim command implementation or Linux GUI `wmctrl` mappings.

## 8. Windows MobaXterm

Use **the MobaXterm terminal Vim**, not WSL2's Vim. Copy the MobaXterm
profile into its persistent home:

```bash
cp -p vimrc-windows-mobaxterm-lsp "$HOME/.vimrc"
cp -p vimrc.before.local-mobaxterm "$HOME/.vimrc.before.local"
vim
```

Inside Vim:

```vim
:PlugInstall
:KDLspHealth
:KDModernHealth
```

Install server wrappers and the Windows Node runtime:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install --profile mobaxterm
tools/lsp/lsp-manager-mobaxterm.sh check
```

The MobaXterm manager translates POSIX paths using `cygpath -w`, launches
native Windows `node.exe` and `npm.cmd` via `cmd.exe`, and verifies downloaded
archives with official/pinned SHA-256 hashes. Never run the Linux/macOS manager
inside MobaXterm.

**Important:** MobaXterm's root directory may be ephemeral unless its home
folder is persisted. Ensure your `~/.vim` and `~/.local/share/vim-lsp`
location is retained between sessions.

This MobaXterm Vimrc has no supported Copilot/Codex integration. Setting either AI flag to true reports a warning but does not enable AI.

## 9. Windows WSL2

Open the WSL2 **Linux distribution shell** and execute the following there
(not in PowerShell, CMD, or a MobaXterm shell):

```bash
uname -r
cat /proc/sys/kernel/osrelease
cp -p vimrc-wsl2-lsp "$HOME/.vimrc"
cp -p vimrc.before.local-wsl2 "$HOME/.vimrc.before.local"
vim
```

The WSL2 Vimrc checks for a WSL2 kernel before configuring Vim. The check
prevents accidental loading on a conventional Linux host or WSL1.

Inside Vim:

```vim
:PlugInstall
:KDLspHealth
:KDModernHealth
:KDAIHealth
```

Install **Linux** LSP binaries inside the WSL2 distribution:

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
tools/lsp/lsp-manager-linux-macos.sh check
```

Do not reuse an LSP home from a Windows drive. The default Linux
`~/.local/share/vim-lsp` is preferable. Keep source repos in the WSL2 Linux
filesystem for responsive file watching where practical. The separate WSL2
profile also accepts CRLF files by using `fileformats=unix,dos`.

The Linux AI installer is optional; review it and its use of `sudo` first.

## 10. LSP manager and server lifecycle

Two platform-specific **manager** scripts exist: Linux/macOS version **1.1.0** and MobaXterm version **1.1.3**. They own server deployment and are NOT Vimrc files:

| Action | Linux / macOS / WSL2 | MobaXterm |
|---|---|---|
| Full profile | `install --profile standard` | `install --profile mobaxterm` |
| Minimal profile | `install --profile minimal` | `install --profile minimal` |
| Check health | `check` | `check` |
| List binary wrappers | `list` | `list` |
| Show pinned versions | `versions` | `versions` |
| Reinstall/update | `update` | `update` |
| Refresh npm seed lock | `lock` | `lock` |
| Delete manager root | `clean --yes` | `clean --yes` |

Prefix the action with the appropriate full script path. For example:

```bash
tools/lsp/lsp-manager-linux-macos.sh versions
tools/lsp/lsp-manager-linux-macos.sh update --profile standard
tools/lsp/lsp-manager-linux-macos.sh list
```

MobaXterm equivalent:

```bash
tools/lsp/lsp-manager-mobaxterm.sh versions
tools/lsp/lsp-manager-mobaxterm.sh update
tools/lsp/lsp-manager-mobaxterm.sh list
```

`clean --yes` is **destructive**: it deletes the complete managed LSP root,
not just one server. It does not intentionally delete `~/.vimrc` or your
regular plugins. Back up custom files in the manager root before cleaning it.

### Reproducibility and integrity

`versions.conf` pins Node and standalone language server versions;
`tools/lsp/npm/package.json` pins npm top-level dependencies. The included
`package-lock.json` is a seed lock and is expanded into a full transitive lock
on first install; full offline reproducibility is therefore **not** claimed.

The npm seed metadata uses `2.7.2-patch.1` because npm package versions require SemVer, whereas the distribution release is named `2.7.2.1`. npm dependency versions have not been upgraded.

The Docker Language Server asset has a version suffix in its name. That was
fixed in the previous manager version: `docker-language-server-${OS}-${ARCH}-v${DOCKER_LS_VERSION}`
(with `.exe` on MobaXterm). The manager refuses installation if a published
GitHub SHA-256 digest cannot be verified. Node archives are also checksum
verified before extraction.

The default managed Node pin remains `24.19.0` until it is explicitly tested
and changed in a later manager release. It is *not* automatically updated to
whatever upstream advertises as the newest version.

### CA bundle and strict TLS examples

```bash
# Linux/macOS/WSL2
 tools/lsp/lsp-manager-linux-macos.sh install --profile standard \
   --ca-bundle "$HOME/.config/certs/internal-ca.pem" --strict-tls

# MobaXterm
 tools/lsp/lsp-manager-mobaxterm.sh install --profile mobaxterm \
   --ca-bundle "$HOME/company-ca-bundle.pem" --strict-tls
```

### MobaXterm npm/Node CA behavior (manager 1.1.3)

The MobaXterm manager first invokes Windows Node/npm via its real `npm.cmd`
through `cmd.exe`, with `NODE_USE_SYSTEM_CA=1` so Node 24 trusts CAs in the
Windows certificate store. With `--ca-bundle FILE`, the path is translated
using `cygpath -w` and passed as **both** `NODE_EXTRA_CA_CERTS` and
`npm_config_cafile`; the downloader still uses that bundle for curl/wget.
Verified npm installs always use `npm_config_strict_ssl=true` first.

Only when npm fails with a recognized certificate-chain error, and only
without `--strict-tls` / `--no-insecure-fallback`, the manager logs an explicit
warning and retries that **single npm command** with
`npm_config_strict_ssl=false`. It does not persist the exception to `.npmrc`
and does not disable Node TLS validation globally. That exception cannot
replace trustworthy CA configuration: use a CA bundle or import the
authorized proxy root certificate in the Windows trust store.

For example, on MobaXterm:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install --profile mobaxterm \
  --ca-bundle "$HOME/company-ca-bundle.pem" --strict-tls
```

`npm ci` still uses package integrity metadata for packages whose lock entries
include it; the included **seed** npm lock expands via the registry on first
install and cannot be considered completely reproducible or independently
authenticated if the TLS exception is used.

## 11. Plugin and completion architecture

Interactive LSP completion remains `yegappan/lsp`. ALE remains the separate
asynchronous lint/fix engine. The previous editor-specific `yamllint` rules and
bottom-only diagnostics are preserved, including the disabled ALE virtual
text. The older Denops/ddc and alternative completion stacks are not packaged.

### Default plugin groups, by operating system

| OS | Default groups |
|---|---|
| Linux | `general`, `lsp`, `ale`, `programming`, `markdown`, `ansible`, `python`, `docker`, `javascript`, `html`, `terraform`, `helm` |
| macOS | Same standard non-AI bundles as Linux |
| MobaXterm | Same non-AI bundles as Linux; AI unsupported |
| WSL2 | Same default set as Linux, using native WSL2 executables |

`general` includes Fern, Stargate, Expand Region, Lightline, FZF, Fugitive's
companion GitGutter, Surround, Repeat, Lexima, visual-multi, Undotree, Sleuth,
Matchup, conflict markers and the existing themes. `programming` includes
Fugitive, GV, Commentary, Tabular, Rainbow and conditional Tagbar (when
`ctags` is installed). FZF with ripgrep, Ansible syntax, Python syntax,
Terraform, Helm and Markdown retain their previous behavior.

### Choosing one plugin implementation per feature

All four selectors must be placed in the **matching**
`~/.vimrc.before.local` file. If not specified, the new default is selected.

| Feature | Default (no setting required) | Previous plugin option |
|---|---|---|
| File browser | `lambdalisue/vim-fern` | `preservim/nerdtree` |
| On-screen jump | `monkoose/vim9-stargate` | `easymotion/vim-easymotion` |
| Expand selection | `terryma/vim-expand-region` | `gcmt/wildfire.vim` (archived) |
| Whitespace/indentation display | Native Vim `listchars` (no plugin) | `preservim/vim-indent-guides` |

To use **all four previous plugins** instead of the new defaults, add:

```vim
let g:kd_explorer = 'nerdtree'
let g:kd_motion = 'easymotion'
let g:kd_selection = 'wildfire'
let g:kd_indent_display = 'vim-indent-guides'
```

For any other mixture, simply include the settings you want to change. The
four selectors are independent and mutually exclusive for each feature, so
no single Vim session tries to load two competing plugins for one feature.
Invalid selector values are rejected during configuration loading.

The standard mappings are: `<F7>` toggles the current file browser,
`<leader>nf` reveals the current file, `<leader>nb` opens the browser;
`<leader>j` and `<leader>J` provide one-/two-character motion search;
`<leader>+` expands text selections and `<leader>-` contracts them when
Expand Region is selected. `<F8>` toggles the optional legacy indentation
plugin when installed. Stargate's `<Cmd>` mappings also work in Visual and
operator-pending modes. Fern's `:Fern . -drawer -toggle -keep` is used for the
browser; NERDTree has its original commands when selected instead.

**Indentation note:** Native `listchars` renders tabs and a distinctive marker
for nonbreaking spaces, **not dots at the end of lines**. Ordinary trailing spaces
remain visually blank until removed on save. It does **not** draw every two-space YAML indentation
level. Choose `g:kd_indent_display = 'vim-indent-guides'` if you still want
vertical markers in space-indented code. The legacy plugin starts disabled,
and `<F8>` toggles it. We do not enable `conceal` to fake guides.

### Whitespace cleanup (2.7.2.1 bugfix)

The function **`FixWhitespace()`** is restored in all four platform Vimrc files.
Use `:FixWhitespace` in normal mode to clean the current editable buffer. It
removes trailing **spaces and tabs** from all lines and removes surplus empty
lines at the end of the buffer. It does **not** remove indentation or spaces
inside text; it preserves the cursor, view and previous search pattern.

On `:write`, the same cleanup is automatic for common code and configuration
filetypes, including `yaml`, `yaml.ansible`, `yml`, Python, shell scripts, Vim,
JSON, and Terraform. Markdown and other prose, `diff`/patch files and Makefiles
are deliberately **excluded** from automatic cleanup because trailing spaces
can have meaning in them. A manual `:FixWhitespace` is still available for them
if that is what you intend. A compatibility function named
`StripTrailingWhitespace()` remains for existing user mappings.

To opt out of automatic save cleanup for any buffer, set this in the relevant
`~/.vimrc.before.local` file:

```vim
let g:kd_keep_trailing_whitespace = 1
```

The native `listchars` still shows tab characters and uses `+` for NBSP, but
never renders the ordinary trailing spaces as `.` characters. No file contents
are changed merely by opening or typing in a buffer.

### Optional plugin bundles

All of these are available, but are deliberately off unless added to
`g:kd_bundle_groups` in the appropriate `vimrc.before.local`:

| Group | Plugins or purpose |
|---|---|
| `rails` | Ruby on Rails (Ruby syntax remains available without this group) |
| `haml` | Haml support; basic HTML/CSS remains in `html` |
| `javascript_less` | LESS syntax |
| `javascript_jst` | JST/EJS template syntax |
| `javascript_coffee` | CoffeeScript syntax |
| `rust` | rust.vim |
| `cucumber` | Cucumber syntax and pipe alignment |
| `vim_over` | Legacy interactive substitute interface |
| `extra` | Sessionman, Bufferline, Abolish, indent and user text objects |
| `writing` | Reedes writing helpers |
| `colorschemes` | Additional colorschemes; `grb256` works without this group |
| `gist` | GitHub Gist client and dependency |
| `php` | PIV, namespace and Twig syntax |
| `go`, `scala`, `haskell`, `puppet`, `elixir`, `asciidoc` | Respective language-specific integrations |

The standard PHP, Go and miscellaneous syntax autocmds built into Vim are not
removed merely because these optional plugins are off. The `docker` group
continues to use Vim's native Dockerfile syntax and the external Docker LS.
`markdown` still gets Tabular even when `programming` is switched off.

Example: install Rust, Cucumber and legacy vim-over without enabling every
miscellaneous plugin:

```vim
let g:kd_bundle_groups += ['rust', 'cucumber', 'vim_over']
```

In Vim, after updating the plugin declarations:

```vim
:PlugInstall
:PlugStatus
:PlugClean
```

**Review** the `:PlugClean` list before approving deletions. You can keep
unused plugin directories installed without loading them until ready to
clean up. We intentionally did not generate a `PlugSnapshot` or pin plugin
Git commits in this release.

### Where yegappan/lsp finds servers

The Vimrc adds `~/.local/share/vim-lsp/bin` to PATH when present and prefers
managed wrappers for Bash, YAML, Ansible, Pyright, TypeScript, VS Code
extracted LSPs, Vim, Terraform, Helm and Docker. Run `:KDLspHealth` to inspect
resolved paths. Language servers are managed by the OS-specific manager under
`tools/lsp/`, independently of Vim plugins.

## 12. YAML, Ansible and diagnostic display

The following three **yamllint style rules remain disabled** in both ordinary
YAML buffers and `yaml.ansible` buffers:

```yaml
rules:
  line-length: disable
  comments-indentation: disable
  truthy: disable
```

The Vimrc configures ALE's yamllint invocation and filters matching
LSP/ALE diagnostics defensively. Other meaningful errors (such as YAML parse
failures) are retained.

Messages are displayed **at the bottom of Vim**, for example:

```text
[yamllint] Error: syntax error: expected a block end
```

Messages must never be visually appended to the end of a source line as
`# E: ...`. These settings stay enabled in every platform profile:

```vim
let g:ale_virtualtext_cursor = 'disabled'
let g:ale_echo_cursor = 1
let g:ale_echo_msg_format = '[%linter%] %severity%: %s'
let g:ale_open_list = 0
let g:ale_set_loclist = 1
```

For yegappan/lsp, diagnostic popups and virtual text are disabled while
status-line reporting stays on:

```vim
'showDiagInPopup': v:false
'showDiagOnStatusLine': v:true
'showDiagWithVirtualText': v:false
```

Changing the Vimrc does not change your global `~/.config/yamllint/config` or
CI yamllint rules. This is the editor-specific policy.

## 13. Lightline and colorscheme

**Lightline is the only statusline implementation** in all four profiles.
The installed before-local templates preserve:

```vim
let g:kd_use_lightline = 1
let g:kd_colorscheme = 'grb256'
```

`g:kd_use_lightline` remains for continuity with your previous local files,
but is no longer a statusline selector: Lightline is always declared when the
`general` bundle is enabled. `grb256` stays the editor's default colorscheme.
The Lightline palette is `wombat`, and its existing optional patched-font
separators are preserved. Install a font containing those glyphs if necessary.
There is no competing hand-written Vim statusline or second statusline plugin.

You may change `g:kd_colorscheme` in `~/.vimrc.before.local` without editing
the four platform-specific Vimrc files.

## 14. GitHub Copilot and Codex

**All AI functionality is disabled by default.** Each matching OS-specific
`vimrc.before.local-*` template contains these independent booleans:

```vim
let g:kd_enable_copilot = v:false
let g:kd_enable_codex = v:false
```

Use `v:true` (or `1`) to opt in, and `v:false` (or `0`) to turn a feature off.
These are true feature switches, not just plugin preferences: when off, the
Copilot plugin is not declared, Copilot-specific options/mappings are absent,
and Codex Vim commands are not defined. Old `github_copilot` or `codex` entries
in `g:kd_bundle_groups` **cannot** bypass these booleans.

| Platform | `kd_enable_copilot = v:true` | `kd_enable_codex = v:true` |
|---|---|---|
| Linux | Loads GitHub Copilot | Adds native Codex CLI Vim commands |
| macOS | Loads GitHub Copilot | Unsupported; warning (no commands added) |
| WSL2 | Loads Copilot in Linux | Adds native Linux Codex CLI Vim commands |
| MobaXterm | Unsupported; warning | Unsupported; warning |

To enable Copilot only (Linux, macOS or WSL2), edit your installed
`~/.vimrc.before.local`:

```vim
let g:kd_enable_copilot = v:true
let g:kd_enable_codex = v:false
```

To enable only Codex CLI (Linux/WSL2):

```vim
let g:kd_enable_copilot = v:false
let g:kd_enable_codex = v:true
```

To enable both on Linux/WSL2, set both flags to `v:true`. Restart Vim after
changing them. Run `:PlugInstall` when Copilot is newly enabled; only run
`:PlugClean` after reviewing its proposed removals. Disabling a flag does not
uninstall any previously installed plugin or CLI.

The Copilot plugin requires an available compatible `node` on PATH and a
completed GitHub authorization. Once activated and installed, run:

```vim
:Copilot setup
:Copilot status
:KDAIHealth
```

Copilot `<Tab>`/`<C-G>` acceptance and `<leader>c...` mappings are defined
only when the option is on **and** the Copilot plugin has been installed.
LSP completion remains independent of Copilot.

Codex is not a vim-plug plugin; it is an optional Vim command integration for
the separately installed and authenticated `codex` CLI. When enabled on Linux
or WSL2, commands include `:AIAsk`, `:AIEdit`, `:AIExplain`, `:AIFix`,
`:AIRefactor`, `:AITest`, `:AIDocument`, `:AIGitReview`, `:AIPrompt` and `:AIOpen`.
Codex commands can interact with local repository files, and write commands
can change files. Save buffers and review Git changes as before.

The AI installer helpers under `scripts/` are **manual tools**; flipping a
boolean does not automatically run an installer, download runtimes or perform
GitHub/OpenAI authentication.

## 15. Keyboard shortcuts and health commands

| Mapping / command | Action |
|---|---|
| `<F7>` | Toggle selected file-browser implementation (Fern by default) |
| `<leader>nf`, `<leader>nb` | Reveal current file / open selected browser |
| `<leader>j`, `<leader>J` | One-/two-character on-screen jump (Stargate by default) |
| `<leader>+`, `<leader>-` | Expand/shrink selection (Expand Region; shrink in Visual mode) |
| `<F8>` | Toggle original vim-indent-guides if selected; not mapped for native guides |
| `:KDLspHealth` | Vim version and managed language-server availability |
| `:KDCompletionHealth` | Alias for `:KDLspHealth` |
| `:KDModernHealth` | Installed utility and Vim plugin diagnostic checks |
| `:KDAIHealth` | AI availability (defined when a supported AI feature is enabled) |
| `gd`, `gr`, `gi`, `gt`, `K` | LSP definition, references, implementation, type, hover |
| `[g`, `]g` | Previous/next LSP diagnostic |
| `<leader>rn`, `<leader>ca`, `<leader>lf` | LSP rename, code action, formatting |
| `<leader>zl`, `<leader>zf` | ALE lint and ALE fix |
| `<leader>zn`, `<leader>zp` | Next/previous ALE diagnostic |
| `<leader>cp`, `<leader>cs` | Copilot panel/status on supported profiles |
| `<leader>as` | AI status on supported profiles |

The default leader is a comma unless you override `g:kd_leader`. Existing
project-specific mappings outside the plugin replacements remain intact.

## 16. Certificates, proxies and security

For MobaXterm npm, manager **1.1.3** enables Windows system trust, propagates `--ca-bundle`, and has a guarded one-command npm `strict-ssl=false` fallback.

The safest way to handle an internal TLS-intercepting proxy is to install its
trust anchor in the platform CA store or use a complete trusted bundle with
`--ca-bundle`. The LSP managers also support `--strict-tls`, which disables
transport fallback. Without it, the old manager behavior may retry with
insecure transport after verified TLS fails. Although certain archives are
checksum verified, this is **not equivalent** to authenticated HTTPS for all
registry/API communication. Prefer verified TLS.

The Vimrc's first-run vim-plug bootstrap likewise has a legacy optional
insecure fallback. To turn it off in your installed local template:

```vim
let g:kd_curl_allow_insecure_fallback = 0
```

To specify your own curl trust bundle:

```vim
let g:kd_curl_ca_bundle = expand('~/.config/certs/internal-ca.pem')
```

Use only a trusted, independently obtained CA bundle. Do not hardcode
secrets or access tokens in the archive.

## 17. Troubleshooting

### `Cannot find module C:\home\mobaxterm\...\npm-cli.js`

You are running an old combined manager, reusing an incompatible runtime,
or the Windows path bridge is broken. On MobaXterm, run the **MobaXterm**
manager from this package:

```bash
tools/lsp/lsp-manager-mobaxterm.sh check
tools/lsp/lsp-manager-mobaxterm.sh clean --yes  # Only if safe to delete the old manager root
tools/lsp/lsp-manager-mobaxterm.sh install
```

The script needs `cygpath` and `cmd.exe`. A failed `check` may help identify
missing executables before cleaning anything.

### Curl error 60 / self-signed certificate in chain

Export a trusted corporate CA bundle, provide it with `--ca-bundle` and
prefer `--strict-tls`. Avoid relying on `--insecure` permanently.

### No diagnostics in a YAML file

Confirm `:set filetype?`, installed `yamllint`, the `ale` bundle and
`:ALEInfo`. The configuration only suppresses the **three** unwanted style
rules; real errors should still appear when the cursor is on the line.

### Diagnostics appear at the end of source lines

Check:

```vim
:echo get(g:, 'ale_virtualtext_cursor', '<missing>')
:echo get(g:, 'ale_echo_cursor', '<missing>')
:verbose let g:ale_virtualtext_cursor
```

Look for a later `.vimrc.local` override or an old Vim session. Exit all Vim
processes and restart after replacing the configuration.

### LSP server exists but is not found

Run `:KDLspHealth`, inspect `~/.local/share/vim-lsp/bin`, and call the matching
manager's `list` and `check`. Check filetypes with `:set ft?` and confirm the
selected bundle includes `lsp`.

### A macOS or WSL2 profile exits immediately

These profiles fail closed on the wrong OS. Ensure you did not copy the native
Linux, macOS, MobaXterm or WSL2 profile to a different target. Check
`uname -s` and `uname -r` in that environment.

### Lightline or `grb256` is missing

Run:

```vim
:echo get(g:, 'kd_use_lightline', 0)
:echo get(g:, 'kd_colorscheme', '')
:PlugStatus
:colorscheme grb256
```

Ensure the matching `vimrc.before.local-*` template was copied to
`~/.vimrc.before.local` and that the `general` plugin bundle is installed.

## 18. Updating, backing up and rolling back

- Back up `~/.vimrc*` and any custom user file first.
- Use the matching release's Vimrc and local template for the current OS.
- The manager's `install/update` operations are independent of copying Vimrc.
- After changing plugin declarations, run `:PlugInstall` and review `:PlugClean`.
- Existing plugin directories may remain on disk after upgrade. `:PlugClean`
  removes only vim-plug-managed plugins that are no longer selected; confirm
  its interactive removal list before proceeding.
- Restart Vim completely before investigating stale diagnostic or AI mappings.
- Rollback by copying your previous backup files back into place, restarting
  Vim, and re-running `:PlugStatus`. Avoid automatically downgrading a working
  language-server installation just because the Vimrc was rolled back.

## 19. Validation and release policy

For **2.7.2.1** the archive includes the latest versions of files only:

- one standalone Vimrc and one before-local template for each of the four OSes;
- two maintained LSP manager scripts (native Linux/macOS and MobaXterm);
- current auxiliary scripts in `scripts/`;
- current pinned LSP metadata and npm seed under `tools/lsp/`;
- README, maintenance document and release SHA256SUMS in the archive root.

No old `ddc`, obsolete manager, historical diff or duplicate release snapshots.
The release was syntax/source-tested on a Linux Vim 9.1 host with temporary
plugin stubs for all four profiles, each under new-default, old-plugin and
optional-language scenarios. macOS, WSL2 and MobaXterm profiles were simulated for source
parsing and option assertions; **native end-to-end installations on those
operating systems have not been executed in this build environment**.

To verify the completed tar.gz after download:

```bash
sha256sum -c vim-2.7.2.1.tar.gz.sha256
tar -tzf vim-2.7.2.1.tar.gz
```

To verify contents after extraction:

```bash
cd vim-2.7.2.1-package
sha256sum -c vim-2.7.2.1-SHA256SUMS.txt
```

On macOS without GNU `sha256sum`, use `shasum -a 256` for individual files.

---

**Maintenance principle:** keep platform differences entirely within the
respective platform Vimrc and local template. Never bring back a mixed Linux /
macOS / MobaXterm / WSL2 single Vimrc or duplicate old files in the tarball.
