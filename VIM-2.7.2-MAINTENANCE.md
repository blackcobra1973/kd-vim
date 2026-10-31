# Vim package 2.7.2 — maintenance notes

**Package:** 2.7.2  
**Vimrc configuration:** 1.5.2  
**Date:** 2026-10-29  
**Based on:** 2.7.1 / Vimrc 1.5.1

## Change

- Added `g:kd_enable_copilot` and `g:kd_enable_codex` as booleans in all four
  `vimrc.before.local-*` files. Both default to `v:false` everywhere.
- The two flags control the existing AI integration paths; legacy AI bundle names
  are ignored when a corresponding flag is false.
- On Linux and WSL2, each flag enables its corresponding feature independently.
  On macOS, Copilot can be enabled, while Codex commands remain unimplemented.
  On MobaXterm, AI integrations remain unsupported; enabling a flag produces an
  explicit warning instead of silently loading unsupported runtimes.
- Copilot startup options, plugin declarations and maps are inactive until
  Copilot is enabled. Codex commands remain unavailable unless enabled.
- Preserved the existing four OS-separated configurations, Lightline-only
  statusline, `grb256`, ALE/yamllint suppressions and diagnostics at bottom.
- No plugin snapshots, new dependencies, language-server version updates,
  ddc variants, or historical Vimrc versions were introduced.

## Upgrade

Back up and merge your current `~/.vimrc.before.local` with the matching
OS template. Leave both AI flags false for no AI. After enabling Copilot, run
`:PlugInstall`, configure `:Copilot setup`, and restart Vim. For Codex on
Linux/WSL2, install/authenticate the native `codex` CLI separately.

`tools/lsp/` and `scripts/` remain unchanged from 2.7.1.

## Verification scope

Vim 9.1 mock source tests check plugin declarations, AI command registration,
platform exclusions, and disabled-by-default behavior. Actual plugin login,
MobaXterm, macOS and WSL2 native end-to-end execution were not available.
