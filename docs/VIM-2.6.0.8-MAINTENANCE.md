# Vim 2.6.0.8 Maintenance Notes

**Date:** 2026-08-23

## Changes

- Fixed YAML/Ansible lint policy so `line-length`, `comments-indentation`, and
  `truthy` are suppressed for both normal `yaml` and `yaml.ansible` buffers.
- Added a package-controlled `yamllint` configuration through ALE's supported
  `g:ale_yaml_yamllint_options` setting.
- Retained a defensive custom yamllint handler so the three intentionally
  ignored style diagnostics are also filtered from parsed output.
- Disabled ALE virtual text completely with
  `g:ale_virtualtext_cursor = 'disabled'`.
- Kept ALE diagnostic echoing at the bottom of Vim with
  `g:ale_echo_cursor = 1` and location-list updates enabled.
- Disabled yegappan/lsp diagnostic virtual text and automatic diagnostic
  popups; enabled status-line diagnostics instead.
- Kept the Docker Language Server v0.20.1 asset-name/SHA-256 fix from 2.6.0.7.
- Removed duplicate version-labelled Vimrc snapshots from the package. The
  canonical `vimrc-linux-lsp` and `vimrc-windows-mobaxterm-lsp` files are now
  the only Vimrc variants in the archive.
- Preserved the package rules: no ddc variants, no historical diff files,
  scripts only in `scripts/`, and tooling only in `tools/`.

## Expected diagnostic behavior

The following style-only messages must not appear for YAML or Ansible YAML:

```text
[yamllint] Warning: comment not indented like content
line too long (... > ... characters)
truthy value should be one of ...
```

No ALE diagnostic text may be rendered at the end of a source line. In
particular, text like this must not appear beside the YAML source:

```text
# E: line too long (122 > 80 characters)
```

Other valid diagnostics remain enabled and are echoed in the bottom Vim
command/message area when the cursor is on the affected line.

## Validation targets

```bash
bash -n tools/lsp/lsp-manager.sh
bash -n scripts/install-vim-ai-linux-1.0.2.sh
bash -n scripts/install-vim-copilot-macos-1.0.1.sh
tools/lsp/lsp-manager.sh --help
tools/lsp/lsp-manager.sh versions
```

Useful runtime checks inside Vim:

```vim
:echo g:ale_virtualtext_cursor
:echo g:ale_echo_cursor
:echo g:ale_yaml_yamllint_options
:ALEInfo
```

Expected virtual-text value:

```text
disabled
```
