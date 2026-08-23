# Vim 2.6.0.2 Maintenance Release

**Date:** 2026-08-23  
**Base release:** Vim 2.6.0.1

## Summary

Vim 2.6.0.2 contains two user-facing corrections:

1. Ansible buffers no longer report the generic YAML `line-length` warning.
2. On Linux and macOS, `<Tab>` once again accepts visible GitHub Copilot ghost text while preserving yegappan/lsp popup completion fallback behavior.

No language-server versions changed in this release. `lsp-manager.sh` remains version 1.0.1 and `vimrc.before.local` remains version 1.4.0.

## Ansible line-length correction

Vim 2.6.0.1 configured `b:ale_yaml_yamllint_options` from a `FileType yaml.ansible` autocmd. ALE can also react to the same `FileType` event, so its first lint could run before that buffer-local option was installed.

2.6.0.2 removes that timing dependency. A dedicated ALE linter named `yamllint_ansible` is registered for Ansible and always executes yamllint with:

```text
-d '{extends: default, rules: {line-length: disable}}'
```

The `yaml.ansible` ALE linter list is now:

```text
yamllint_ansible
ansible_lint
```

All other yamllint rules remain active. Generic YAML buffers still use the ordinary `yamllint` definition and retain its normal policy.

As an additional guard, the `ansible-language-server` entry uses yegappan/lsp's `processDiagHandler` to discard only diagnostics that identify themselves as line-length warnings. Other LSP diagnostics are preserved.

After upgrading, completely restart Vim to clear diagnostics produced by the old session. Then verify in an Ansible buffer:

```vim
:set filetype?
:ALEInfo
:LspDiag show
```

Expected filetype:

```text
filetype=yaml.ansible
```

`ALEInfo` should list `yamllint_ansible` and `ansible_lint`.

## Copilot `<Tab>` correction

2.6.0.1 intentionally left `<Tab>` entirely to yegappan/lsp and used `Ctrl-G` for Copilot acceptance. This did not match the desired workflow.

2.6.0.2 keeps `g:copilot_no_tab_map = v:true` so the plugin does not install an uncontrolled mapping, then explicitly maps:

```vim
imap <silent><script><expr> <Tab> copilot#Accept()
```

Current `github/copilot.vim` implements the desired fallback inside `copilot#Accept()`:

- visible Copilot suggestion: accept the ghost text;
- no Copilot suggestion + Vim popup visible: return `<C-N>` and move to the next LSP candidate;
- no Copilot suggestion + no popup: insert a normal Tab.

`Ctrl-G` remains available as a second full-suggestion accept mapping.

MobaXterm remains AI-free and therefore retains its normal popup-aware `<Tab>` mapping.

## Upgrade

Replace the platform vimrc with the 2.6.0.2 version, then fully restart Vim.

Linux/macOS:

```bash
cp vimrc-linux-lsp-2.6.0.2 ~/.vim/vimrc
```

MobaXterm:

```bash
cp vimrc-windows-mobaxterm-lsp-2.6.0.2 ~/.vim/vimrc
```

No LSP server reinstall is required for this maintenance release.

Useful validation commands:

```vim
:KDLspHealth
:KDModernHealth
:ALEInfo
:Copilot status
```
