# Vim 2.5.0.2 — Linux/macOS AI integration

## Scope

Version 2.5.0.2 corrects the 2.5 AI platform boundary while preserving the 2.4.0.1 modernization baseline. GitHub Copilot ghost-text completion is enabled on both Linux and macOS; the explicit OpenAI Codex Vim command integration remains Linux-only.

- **Linux:** GitHub Copilot for continuous inline/multiline ghost-text predictions, plus OpenAI Codex CLI for deliberate code/repository tasks.
- **macOS:** GitHub Copilot for continuous inline/multiline ghost-text predictions. The `codex` bundle is filtered out in 2.5.
- **Windows/MobaXterm:** remains completely AI-free. ddc, vim-lsp, ALE, fzf, Terraform, Helm, Git and the other 2.4 features remain available.

## Architecture

| Responsibility | Component | Notes |
| --- | --- | --- |
| Normal semantic completion | ddc.vim + vim-lsp | ddc is used on Vim 9.1.1646+; older supported Vim builds fall back to vim-lsp/native omni-completion. |
| Inline AI prediction | github/copilot.vim | Ghost text; does not take ownership of `<Tab>`. |
| Deliberate AI tasks | OpenAI Codex CLI | Explain, fix, edit, refactor, tests, docs, Git review and free-form repository tasks. |
| Linting/fixing | ALE | Linux/macOS mappings use `<leader>z...` to reserve the AI namespace. |

## Prerequisites

### Existing Vim stack

- Vim meeting the existing 2.4 requirements.
- Current ddc/denops prerequisites are Vim 9.1.1646+ with +job/+channel, Deno 2.3+, and denops.vim 8+. Debian 13 stock Vim 9.1.1230/1244 therefore uses the vim-lsp/native omni fallback; Vim 9.2 enables the full ddc path.

### GitHub Copilot — Linux and macOS

- Vim 9.0.0185 or newer with `+textprop` (required for Vim ghost text).
- Node.js and npm.
- GitHub Copilot access/subscription.
- Authenticate from Vim with `:Copilot setup`.

On macOS the supplied `install-vim-copilot-macos.sh` can validate Vim and install Node.js through Homebrew when Node is not already present.

### OpenAI Codex CLI

Install with the supplied `install-vim-ai-linux.sh`, or use the current official OpenAI standalone installer. On first use run `codex` and choose **Sign in with ChatGPT**.

The Vim integration intentionally uses the ChatGPT-authenticated CLI rather than an OpenAI API key.

## Installation

### Linux — Copilot + Codex

```bash
chmod 755 install-vim-ai-linux.sh
./install-vim-ai-linux.sh
```

For a corporate CA:

```bash
./install-vim-ai-linux.sh --ca-bundle /path/to/company-ca.pem
```

To prohibit the optional insecure curl fallback:

```bash
./install-vim-ai-linux.sh --strict-tls
```

### macOS — Copilot ghost text

```bash
chmod 755 install-vim-copilot-macos.sh
./install-vim-copilot-macos.sh
```

Alternatively, when Node.js is already managed independently, verify `node --version` and `npm --version` and proceed directly to Vim plugin installation.

Then install/update Vim plugins:

```vim
:PlugInstall
:PlugUpdate
```

Authenticate Copilot on both Linux and macOS:

```vim
:Copilot setup
```

On Linux also authenticate Codex from the shell:

```bash
codex
```

Choose **Sign in with ChatGPT** on first use.

Finally:

```vim
:KDAIHealth
```

## Copilot mappings

`ddc.vim` remains the owner of `<Tab>`. The configuration sets `g:copilot_no_tab_map = v:true` and uses:

| Mapping | Action |
| --- | --- |
| `<C-G>` | Accept the complete Copilot suggestion |
| `<leader>cp` | Open Copilot panel |
| `<leader>cs` | Copilot status |
| `<leader>ce` | Enable Copilot |
| `<leader>cd` | Disable Copilot |
| `<leader>cm` | Select completion model when available |
| `<leader>cu` | Upgrade Copilot language server |

Copilot's standard Alt mappings remain available for next/previous suggestion, accepting a word/line, and manually requesting a suggestion.

## Codex commands and mappings — Linux only

| Mapping | Command | Default access | Purpose |
| --- | --- | --- | --- |
| `<leader>aa` | `:AIAsk` | read-only | Ask a question about the current code/repository |
| `<leader>ae` | `:AIEdit` | workspace-write | Apply an explicit edit instruction |
| `<leader>ax` | `:AIExplain` | read-only | Explain current line/visual range |
| `<leader>af` | `:AIFix` | workspace-write | Diagnose and fix a defect |
| `<leader>ar` | `:AIRefactor` | workspace-write | Refactor to an explicit goal |
| `<leader>at` | `:AITest` | workspace-write | Add/improve relevant tests and run validation |
| `<leader>ad` | `:AIDocument` | workspace-write | Improve comments/documentation without changing behavior |
| `<leader>ag` | `:AIGitReview` | read-only | Review current Git worktree changes |
| `<leader>ap` | `:AIPrompt` | workspace-write | Free-form repository task |
| `<leader>ao` | `:AIOpen` | interactive | Open the full interactive Codex CLI in a Vim terminal |
| `<leader>as` | `:AIStatus` | read-only | Show Copilot/Node/Codex/auth health |

`AIEdit`, `AIFix`, `AIRefactor`, `AITest`, and `AIDocument` accept `!` to target the entire current file instead of the current line/range, for example:

```vim
:AIRefactor! simplify error handling without changing public behavior
```

Visual-mode mappings are supplied for edit, explain, fix, refactor, test and document operations.

## Codex execution policy — Linux only

Non-interactive commands use:

```text
codex exec --ephemeral --sandbox <policy> -C <repository-root> <prompt>
```

- Read-only tasks use `--sandbox read-only`.
- File-changing tasks use `--sandbox workspace-write`.
- `--ephemeral` prevents persistence of the exec session rollout files.
- `-C` points Codex at the detected Git repository root, falling back to the current working directory.
- The Vim integration never uses `danger-full-access` or the sandbox-bypass options.
- A Codex task is refused while the current Vim buffer has unsaved changes, avoiding stale on-disk input and accidental overwrite of unsaved edits.
- On completion Vim runs `checktime` so externally modified files are detected.

## ALE namespace change on Linux/macOS

2.4 used `<leader>a...` for ALE. The finalized 2.5 AI design reserves that prefix for AI. Because Copilot/AI status now exists on both Linux and macOS in this shared vimrc, both platforms use:

| Mapping | ALE action |
| --- | --- |
| `<leader>zl` | `:ALELint` |
| `<leader>zf` | `:ALEFix` |
| `<leader>zn` | next ALE finding |
| `<leader>zp` | previous ALE finding |

MobaXterm has no AI collision and retains its existing 2.4 ALE mappings.

## Platform behavior

| Feature | Linux | macOS | MobaXterm/Windows |
| --- | ---: | ---: | ---: |
| Completion | ddc on Vim 9.1.1646+, otherwise vim-lsp/omni | ddc on Vim 9.1.1646+, otherwise vim-lsp/omni | ddc on Vim 9.1.1646+, otherwise vim-lsp/omni |
| ALE | Yes | Yes | Yes |
| Copilot plugin | Yes | Yes | No |
| Copilot ghost text | Yes | Yes | No |
| Codex CLI Vim commands | Yes | No | No |
| `:KDAIHealth` | Yes | Yes | No |

The shared `vimrc.before.local` includes both AI bundle names. On macOS the Linux/macOS vimrc filters only `codex`, leaving `github_copilot` enabled. The MobaXterm vimrc strips both AI bundle names before plugin declarations are processed.
