# Vim configuration 2.6.0.10

A maintained Vim configuration for Linux, macOS and MobaXterm, with a Vim9-native
LSP architecture based on `yegappan/lsp`, ALE for linting/fixing, platform-aware
AI integration, and reproducible language-server installation.

**Release:** 2.6.0.10  
**Date:** 2026-08-24  
**Completion/LSP client:** `yegappan/lsp`  
**Linux/macOS manager:** `tools/lsp/lsp-manager-linux-macos.sh` 1.1.0  
**MobaXterm manager:** `tools/lsp/lsp-manager-mobaxterm.sh` 1.1.1

---

## 1. Important changes in 2.6.0.10

This release keeps the platform-specific LSP managers introduced previously and
fixes the MobaXterm Node/npm execution and health-check behavior. The manager
now follows the exact execution model confirmed to work in a real MobaXterm
shell: `node.exe` and `npm.cmd` are invoked directly from their MobaXterm POSIX
paths.

The two-manager architecture remains unchanged.

### Linux and macOS

Use:

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
```

This script only supports native Linux and macOS runtimes and assets.

### MobaXterm

Use:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install
```

The MobaXterm manager is intentionally separate because MobaXterm combines a
POSIX/Cygwin-like shell with native Windows executables. Native `node.exe` must
not be given MobaXterm POSIX paths directly.

The previous combined manager could execute a command equivalent to:

```text
node.exe /home/mobaxterm/.local/share/vim-lsp/runtime/node/node_modules/npm/bin/npm-cli.js
```

Windows Node interpreted that POSIX path as a native Windows path such as:

```text
C:\home\mobaxterm\.local\share\vim-lsp\runtime\node\node_modules\npm\bin\npm-cli.js
```

That is not the real MobaXterm home path and caused:

```text
Error: Cannot find module 'C:\home\mobaxterm\...\npm-cli.js'
```

The MobaXterm manager now:

1. installs the official Windows Node ZIP;
2. verifies it against a package-pinned SHA-256 digest;
3. invokes `node.exe` directly from its MobaXterm POSIX path;
4. invokes the Node distribution's own `npm.cmd` directly from its MobaXterm POSIX path;
5. keeps argument boundaries intact by using Bash arrays rather than a reconstructed command string;
6. uses `cygpath -w` only where a native Windows-form path is actually required, such as the npm cache variable;
7. creates MobaXterm shell wrappers that execute the installed `.cmd` language-server shims directly.

This avoids passing a POSIX `npm-cli.js` pathname to `node.exe` and avoids the
extra `cmd.exe` quoting layer that caused the 1.1.0 health-check false failure.

---

## 2. Package layout

The archive intentionally contains only the current versions of files.
Historical versions, old ddc variants and diff/history files are not included.

```text
vim-2.6.0.10-package/
├── README.md
├── VIM-2.6.0.10-MAINTENANCE.md
├── vim-2.6.0.10-SHA256SUMS.txt
├── vimrc-linux-lsp
├── vimrc-windows-mobaxterm-lsp
├── vimrc.before.local-1.4.1
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

### Root directory policy

The archive root is reserved for:

- Vimrc files;
- Markdown documentation;
- release checksum metadata.

Executable helpers belong in `scripts/`. Language-server tooling belongs in
`tools/`.

---

## 3. Supported platforms

| Platform | Vimrc | LSP manager | AI |
|---|---|---|---|
| Linux | `vimrc-linux-lsp` | `lsp-manager-linux-macos.sh` | Copilot + optional Codex CLI |
| macOS | `vimrc-linux-lsp` | `lsp-manager-linux-macos.sh` | Copilot |
| MobaXterm | `vimrc-windows-mobaxterm-lsp` | `lsp-manager-mobaxterm.sh` | intentionally disabled |

The Linux/macOS Vimrc explicitly rejects unsupported platforms. The MobaXterm
variant is dedicated to terminal Vim inside MobaXterm and does not require or
configure X11 Vim.

---

## 4. Vim requirements

The configuration uses Vim9-era functionality and `yegappan/lsp`.

Recommended:

```text
Vim 9.1.1646 or newer
```

A newer Vim 9.2 build is preferred where available.

Check with:

```bash
vim --version | head
```

Inside Vim:

```vim
:version
```

---

## 5. Initial installation

### 5.1 Linux

Back up the current configuration:

```bash
cp -a ~/.vimrc ~/.vimrc.backup 2>/dev/null || true
cp -a ~/.vim ~/.vim.backup 2>/dev/null || true
```

Install the Vimrc:

```bash
cp vimrc-linux-lsp ~/.vimrc
```

Install vim-plug if it is not already available, then start Vim and run:

```vim
:PlugInstall
```

Install the managed language servers:

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
```

Then restart Vim and run:

```vim
:KDLspHealth
:KDModernHealth
```

### 5.2 macOS

Use the same Vimrc and manager:

```bash
cp vimrc-linux-lsp ~/.vimrc
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
```

Inside Vim:

```vim
:PlugInstall
:KDLspHealth
:KDModernHealth
```

### 5.3 MobaXterm

Install the dedicated Vimrc:

```bash
cp vimrc-windows-mobaxterm-lsp ~/.vimrc
```

Install plugins:

```vim
:PlugInstall
```

Install language servers with the dedicated manager:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install
```

Do **not** use the Linux/macOS manager from MobaXterm.

After installation:

```bash
tools/lsp/lsp-manager-mobaxterm.sh check
tools/lsp/lsp-manager-mobaxterm.sh list
```

Then restart Vim and run:

```vim
:KDLspHealth
:KDModernHealth
```

---

## 6. LSP manager architecture

The manager installs private, pinned runtime components below:

```text
~/.local/share/vim-lsp/
```

Default layout:

```text
~/.local/share/vim-lsp/
├── bin/
├── cache/
├── npm/
├── runtime/
│   └── node/
└── servers/
```

`bin/` is the stable interface used by Vim. The actual Node runtime and server
versions can be replaced without changing the Vimrc server commands.

### Why use a private Node runtime?

It avoids depending on whichever system Node/npm version happens to be
installed. The package pins the Node version and npm-based language-server
versions so the editor environment is reproducible.

---

## 7. Linux/macOS LSP manager

### 7.1 Install the standard profile

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
```

The standard profile installs:

- the private Node runtime;
- npm language servers;
- `terraform-ls`;
- `helm_ls`;
- `docker-language-server`.

### 7.2 Minimal profile

```bash
tools/lsp/lsp-manager-linux-macos.sh install --profile minimal
```

The minimal profile installs only the Node/npm language-server stack.

### 7.3 Update

```bash
tools/lsp/lsp-manager-linux-macos.sh update --profile standard
```

### 7.4 Check

```bash
tools/lsp/lsp-manager-linux-macos.sh check --profile standard
```

### 7.5 List server wrappers

```bash
tools/lsp/lsp-manager-linux-macos.sh list
```

### 7.6 Show pinned versions

```bash
tools/lsp/lsp-manager-linux-macos.sh versions
```

### 7.7 Rebuild the npm lock

For package maintenance only:

```bash
tools/lsp/lsp-manager-linux-macos.sh lock
```

### 7.8 Clean the managed runtime

This deletes the complete managed LSP tree:

```bash
tools/lsp/lsp-manager-linux-macos.sh clean --yes
```

---

## 8. MobaXterm LSP manager

### 8.1 Normal installation

```bash
tools/lsp/lsp-manager-mobaxterm.sh install
```

The default profile is `mobaxterm`, so this is equivalent to:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install --profile mobaxterm
```

### 8.2 Minimal profile

```bash
tools/lsp/lsp-manager-mobaxterm.sh install --profile minimal
```

### 8.3 Update

```bash
tools/lsp/lsp-manager-mobaxterm.sh update
```

### 8.4 Check

```bash
tools/lsp/lsp-manager-mobaxterm.sh check --profile mobaxterm
```

The check executes the private runtime exactly as MobaXterm does from the
interactive shell:

```bash
~/.local/share/vim-lsp/runtime/node/node.exe --version
~/.local/share/vim-lsp/runtime/node/npm.cmd --version
```

A healthy runtime therefore reports both versions, for example:

```text
node:        /home/mobaxterm/.local/share/vim-lsp/runtime/node/node.exe (v24.19.0)
npm bridge:  /home/mobaxterm/.local/share/vim-lsp/runtime/node/npm.cmd (11.17.0)
```

`check` also validates every server required by the selected profile. It returns
exit status `0` only when Node, npm and all required servers are available. An
incomplete installation returns exit status `1` and ends with a summary such as:

```text
status:      FAILED (12 required components unavailable)
```

A complete profile ends with:

```text
status:      OK
```

### 8.5 List

```bash
tools/lsp/lsp-manager-mobaxterm.sh list
```

### 8.6 Versions

```bash
tools/lsp/lsp-manager-mobaxterm.sh versions
```

### 8.7 Clean

```bash
tools/lsp/lsp-manager-mobaxterm.sh clean --yes
```

---

## 9. MobaXterm Node/npm path handling

This is an important implementation detail.

MobaXterm provides a Windows-command bridge that lets its shell execute both
Windows PE binaries and `.cmd` files directly from MobaXterm POSIX paths. For
this runtime the supported calls are therefore simply:

```bash
/home/mobaxterm/.local/share/vim-lsp/runtime/node/node.exe --version
/home/mobaxterm/.local/share/vim-lsp/runtime/node/npm.cmd --version
```

The manager deliberately does **not** run:

```bash
node.exe /home/mobaxterm/.../npm-cli.js
```

because native Windows Node can reinterpret that POSIX path as
`C:\home\mobaxterm\...`, which is not the MobaXterm home mapping.

It also does not add an unnecessary `cmd.exe /c` layer around normal Node/npm
operations. Direct execution preserves MobaXterm's working path translation and
keeps each command-line argument separate. `cygpath -w` remains available for
values that native Windows tools must consume as path strings, such as the
private npm cache path.

This is why the MobaXterm and Linux/macOS managers remain separate scripts.

---

## 10. MobaXterm TLS and self-signed certificate chains

MobaXterm installations can contain a curl/OpenSSL CA configuration that does
not trust a local enterprise, proxy or inspection CA. Typical output is:

```text
curl: (60) SSL certificate problem: self-signed certificate in certificate chain
```

The dedicated MobaXterm manager handles downloads in this order:

1. verified `wget`, when available;
2. verified `curl`;
3. if both verified methods fail and insecure fallback is allowed, an insecure
   transport retry is attempted;
4. only one concise warning is printed for the fallback instead of repeating
   the complete curl certificate error for every file.

### Recommended solution: provide the CA bundle

If you have the correct PEM CA chain:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install \
  --ca-bundle /path/to/company-ca-bundle.pem
```

This is preferred because normal TLS certificate verification stays enabled.

### Enforce verified TLS only

```bash
tools/lsp/lsp-manager-mobaxterm.sh install --strict-tls
```

or:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install --no-insecure-fallback
```

If the MobaXterm CA store still cannot validate the server certificate, the
install will stop rather than use the fallback.

### Node integrity during TLS fallback

The package pins the SHA-256 values for both official Node 24.19.0 Windows ZIPs
in `tools/lsp/versions.conf`.

For x64:

```text
57f71ab3652e797d84acddc79c81cc9ff1c6ddb2a1974cdb83f00fee9bff4c73
```

For ARM64:

```text
8502f4a50b458d4cc38ed8f2001556c2cd239d464920f74017926ccb1e1c157f
```

The downloaded Node archive must match the appropriate pinned value before it
is extracted.

---

## 11. Managed server versions

The central pins are stored in:

```text
tools/lsp/versions.conf
```

Current native/runtime pins include:

| Component | Version |
|---|---:|
| Node | 24.19.0 |
| terraform-ls | 0.39.0 |
| Docker Language Server | 0.20.1 |
| helm-ls | rolling `master` release |

Pinned npm packages are stored in:

```text
tools/lsp/npm/package.json
```

They include the Ansible, Bash, YAML, Python, TypeScript, JSON, HTML, CSS and Vim
language-server components used by this configuration.

Display the exact current pins with:

```bash
tools/lsp/lsp-manager-linux-macos.sh versions
```

or on MobaXterm:

```bash
tools/lsp/lsp-manager-mobaxterm.sh versions
```

---

## 12. Docker Language Server verification

Docker Language Server release assets include the release version in the
filename. For version 0.20.1, for example:

```text
docker-language-server-linux-amd64-v0.20.1
```

The managers build the versioned asset name before retrieving GitHub release
metadata and require a SHA-256 asset digest. If GitHub does not provide a digest
for the exact selected asset, installation fails closed rather than silently
installing an unverified binary.

---

## 13. Vim LSP behavior

`yegappan/lsp` is the only LSP/completion client in the standard configuration.
The old ddc/denops stack is not included.

Important LSP behavior:

```vim
'autoComplete': v:true
'showDiagInPopup': v:false
'showDiagOnStatusLine': v:true
'showDiagWithVirtualText': v:false
```

This means:

- LSP completion remains enabled;
- diagnostic popups are not automatically opened;
- diagnostic virtual text is disabled;
- diagnostics can be shown in the bottom/status area instead.

### Core LSP mappings

| Mapping | Action |
|---|---|
| `gd` | go to definition |
| `gr` | show references |
| `gi` | go to implementation |
| `gt` | go to type definition |
| `K` | hover information |
| `<leader>rn` | rename |
| `[g` | previous diagnostic |
| `]g` | next diagnostic |
| `<leader>ca` | code action |
| `<leader>lf` | format |

---

## 14. Completion behavior

The Vim popup menu is used for completion.

When the popup menu is visible:

| Key | Behavior |
|---|---|
| `Tab` | next completion item |
| `Shift-Tab` | previous completion item |
| `Enter` | accept completion |
| `Esc` | close/accept popup state and return to normal editing |

On Linux/macOS, when GitHub Copilot is active, Copilot's ghost-text acceptance
mapping takes precedence where configured.

MobaXterm contains no AI plugin group, so completion there is purely Vim/LSP.

---

## 15. ALE linting policy

ALE is used for external linting and fixing, not as a second LSP client.

The configuration explicitly sets:

```vim
let g:ale_disable_lsp = 1
let g:ale_linters_explicit = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 1
```

### Diagnostic presentation

ALE virtual/end-of-line diagnostic text is disabled:

```vim
let g:ale_virtualtext_cursor = 'disabled'
```

Diagnostics are echoed in the bottom Vim message area:

```vim
let g:ale_echo_cursor = 1
let g:ale_echo_msg_format = '[%linter%] %severity%: %s'
```

The location list is maintained, but it is not automatically opened:

```vim
let g:ale_open_list = 0
let g:ale_set_loclist = 1
```

Therefore text such as this must not be rendered at the end of your YAML line:

```text
# E: line too long (122 > 80 characters)
```

### YAML/yamllint rules intentionally suppressed

The package disables these yamllint style rules for YAML and Ansible YAML:

- `line-length`;
- `comments-indentation`;
- `truthy`.

The configuration is equivalent to:

```vim
let g:ale_yaml_yamllint_options = "-d '{extends: default, rules: {line-length: disable, comments-indentation: disable, truthy: disable}}'"
```

So messages such as these should not be shown:

```text
[yamllint] Warning: comment not indented like content
line too long (122 > 80 characters)
truthy value should be one of ...
```

Other real YAML/Ansible issues remain enabled.

### ALE mappings

| Mapping | Action |
|---|---|
| `<leader>zl` | run ALE lint |
| `<leader>zf` | run ALE fix |
| `<leader>zn` | next ALE issue |
| `<leader>zp` | previous ALE issue |

---

## 16. Health commands

### LSP health

```vim
:KDLspHealth
```

Compatibility alias:

```vim
:KDCompletionHealth
```

### Modern tooling health

```vim
:KDModernHealth
```

### AI health on Linux/macOS

```vim
:KDAIHealth
```

MobaXterm intentionally has no AI configuration.

---

## 17. Useful plugin mappings

### FZF

| Mapping | Action |
|---|---|
| `<leader>ff` | files |
| `<leader>fg` | Git files |
| `<leader>fb` | buffers |
| `<leader>fl` | lines |
| `<leader>fh` | history |
| `<leader>fc` | commits |
| `<leader>fr` | ripgrep search |

### Git/Fugitive

| Mapping | Action |
|---|---|
| `<leader>gs` | Git status/interface |
| `<leader>gd` | Git diff split |
| `<leader>gc` | commit |
| `<leader>gb` | blame |
| `<leader>gl` | Git log |
| `<leader>gp` | push |
| `<leader>gr` | read from Git |
| `<leader>gw` | write/stage |
| `<leader>ge` | edit Git object |
| `<leader>gi` | interactive add for current file |

### GitGutter

| Mapping | Action |
|---|---|
| `<leader>gg` | toggle GitGutter |
| `]h` | next hunk |
| `[h` | previous hunk |
| `<leader>hp` | preview hunk |
| `<leader>hs` | stage hunk |
| `<leader>hu` | undo hunk |

### Undotree

```text
F5
<leader>u
```

Both toggle Undotree.

### NERDTree

```text
F7
```

Toggles NERDTree.

---

## 18. AI integration

### Linux

The Linux configuration can use:

- GitHub Copilot for inline ghost-text completion;
- OpenAI Codex CLI for deliberate code tasks.

Helper:

```bash
scripts/install-vim-ai-linux-1.0.2.sh
```

### macOS

The macOS profile keeps Copilot but filters out the Linux Codex bundle.

Helper:

```bash
scripts/install-vim-copilot-macos-1.0.1.sh
```

### MobaXterm

AI groups are intentionally excluded. There is no Copilot or Codex setup in the
MobaXterm Vimrc.

---

## 19. Copilot mappings

When Copilot is enabled on Linux/macOS:

| Mapping | Action |
|---|---|
| `Tab` | accept Copilot suggestion |
| `Ctrl-G` | alternate accept |
| `<leader>cp` | Copilot panel |
| `<leader>cs` | status |
| `<leader>ce` | enable |
| `<leader>cd` | disable |
| `<leader>cm` | model |
| `<leader>cu` | upgrade |

---

## 20. Codex commands on Linux

The Linux Vimrc provides commands such as:

```vim
:AIAsk
:AIEdit
:AIExplain
:AIFix
:AIRefactor
:AITest
:AIDocument
:AIGitReview
:AIPrompt
:AIOpen
```

These use the external Codex CLI and are not part of MobaXterm.

---

## 21. Updating an existing installation

Recommended sequence:

1. extract the new package;
2. compare your local customizations;
3. replace the appropriate Vimrc;
4. run `:PlugUpdate` or `:PlugInstall`;
5. update the managed language-server runtime;
6. fully exit and restart Vim;
7. run the health commands.

Linux/macOS:

```bash
cp vimrc-linux-lsp ~/.vimrc
tools/lsp/lsp-manager-linux-macos.sh update --profile standard
```

MobaXterm:

```bash
cp vimrc-windows-mobaxterm-lsp ~/.vimrc
tools/lsp/lsp-manager-mobaxterm.sh update
```

---

## 22. Troubleshooting MobaXterm

### `Cannot find module C:\home\mobaxterm\...\npm-cli.js`

You are using the old combined manager or an old installed copy.

Check which manager files exist:

```bash
find tools/lsp -maxdepth 1 -type f -name 'lsp-manager*.sh' -print
```

For 2.6.0.10 you should use:

```text
tools/lsp/lsp-manager-mobaxterm.sh
```

Clean the old managed runtime if necessary:

```bash
tools/lsp/lsp-manager-mobaxterm.sh clean --yes
```

Then reinstall:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install
```

### TLS self-signed certificate warning

Best solution:

```bash
tools/lsp/lsp-manager-mobaxterm.sh install \
  --ca-bundle /path/to/your-ca-chain.pem
```

If no custom CA bundle is supplied, the manager can fall back to unverified
transport but still performs the configured checksum/digest validation.

### `cygpath` missing

The MobaXterm manager requires:

```bash
command -v cygpath
command -v cmd.exe
```

Both must succeed.

### `node: ... ()` or `npm bridge: ... (FAILED)` while manual commands work

This was a manager 1.1.0 health-check bug. Version 1.1.1 executes the two
commands directly instead of wrapping them in `cmd.exe`. Verify the installed
manager version:

```bash
tools/lsp/lsp-manager-mobaxterm.sh --help | head
```

Then rerun:

```bash
tools/lsp/lsp-manager-mobaxterm.sh check --profile mobaxterm
echo $?
```

If servers have not yet been installed, Node/npm should show their real
versions but the command will correctly return `1` until all servers required
by the profile exist.

### `npm.cmd missing from private Node runtime`

Remove the partial runtime and reinstall:

```bash
rm -rf ~/.local/share/vim-lsp/runtime/node
tools/lsp/lsp-manager-mobaxterm.sh install
```

### Check private Node

```bash
tools/lsp/lsp-manager-mobaxterm.sh check
```

---

## 23. Troubleshooting Linux/macOS

### Wrong manager

Do not run the MobaXterm manager on Linux/macOS. Use:

```bash
tools/lsp/lsp-manager-linux-macos.sh check --profile standard
```

### Language server not found

```bash
tools/lsp/lsp-manager-linux-macos.sh list
ls -la ~/.local/share/vim-lsp/bin
```

Then inside Vim:

```vim
:KDLspHealth
```

### Rebuild everything

```bash
tools/lsp/lsp-manager-linux-macos.sh clean --yes
tools/lsp/lsp-manager-linux-macos.sh install --profile standard
```

---

## 24. Troubleshooting diagnostics

### End-of-line `# E:` text still appears

Confirm the active setting:

```vim
:echo g:ale_virtualtext_cursor
```

Expected:

```text
disabled
```

Also check:

```vim
:ALEInfo
```

Fully close and restart Vim after replacing the Vimrc; settings from an already
running Vim process are not retroactively unloaded.

### yamllint still reports line length/comments indentation/truthy

Check:

```vim
:echo g:ale_yaml_yamllint_options
```

Run:

```vim
:ALEInfo
```

Ensure the current 2.6.0.10 Vimrc is actually loaded.

---

## 25. Package checksum verification

The package includes an internal checksum list:

```text
vim-2.6.0.10-SHA256SUMS.txt
```

From the extracted package directory:

```bash
sha256sum -c vim-2.6.0.10-SHA256SUMS.txt
```

On macOS, if GNU `sha256sum` is unavailable, verify individual files with:

```bash
shasum -a 256 <file>
```

---

## 26. Maintainer validation

Before creating a new release, at minimum run:

```bash
bash -n tools/lsp/lsp-manager-linux-macos.sh
bash -n tools/lsp/lsp-manager-mobaxterm.sh
bash -n scripts/install-vim-ai-linux-1.0.2.sh
bash -n scripts/install-vim-copilot-macos-1.0.1.sh
```

Check help/version output:

```bash
tools/lsp/lsp-manager-linux-macos.sh --help
tools/lsp/lsp-manager-mobaxterm.sh --help
```

Check the package for obsolete content:

```bash
find . -iname '*ddc*' -o -iname '*.diff'
```

The result should be empty.

Verify there is no old combined manager:

```bash
find tools/lsp -maxdepth 1 -type f -name 'lsp-manager.sh'
```

The result should be empty.

---

## 27. Release packaging policy

Future release archives should continue to follow these rules:

- include only the latest version of each file;
- do not include ddc versions/files;
- do not include historical diff files;
- do not include old release snapshots;
- keep scripts under `scripts/`;
- keep language-server tooling under `tools/lsp/`;
- keep Vimrc files and Markdown documentation at the archive root;
- provide separate Linux/macOS and MobaXterm LSP managers;
- retain checksum verification for downloaded runtimes and native binaries.

