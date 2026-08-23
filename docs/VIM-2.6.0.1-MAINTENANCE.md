# Vim 2.6.0.1 — LSP npm pin correction

Version: 2.6.0.1  
Date: 2026-08-23

## Fix

Vim 2.6.0.0 pinned these two packages together:

```text
typescript-language-server  6.0.0
typescript                  6.0.0
```

`typescript-language-server@6.0.0` exists, but stable `typescript@6.0.0` was
never published to npm. As a result, the first seed-lock expansion failed with:

```text
npm ERR! code ETARGET
npm ERR! notarget No matching version found for typescript@6.0.0.
```

2.6.0.1 changes only the TypeScript runtime pin:

```text
typescript-language-server  6.0.0
typescript                  6.0.3
```

This matches the current TypeScript Language Server 6.0.0 development/runtime
baseline (`typescript: ^6.0.3`) while avoiding an unnecessary jump to TypeScript
7.x.

All other npm language-server pins from 2.6.0.0 are unchanged.

## Upgrade on a host where 2.6.0.0 failed

Replace `tools/lsp/` with the 2.6.0.1 version, then remove only the incomplete
npm staging directory created by the failed run:

```bash
rm -rf ~/.local/share/vim-lsp/npm

tools/lsp/lsp-manager.sh install --profile standard
```

The private Node 24.19.0 runtime already installed under
`~/.local/share/vim-lsp/runtime/node` does not need to be removed; the manager
will reuse it.

After a successful install:

```bash
tools/lsp/lsp-manager.sh check --profile standard
tools/lsp/lsp-manager.sh versions
```

Then in Vim:

```vim
:KDLspHealth
:LspShowAllServers
```
