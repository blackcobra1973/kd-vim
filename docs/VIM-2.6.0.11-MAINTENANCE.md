# Vim 2.6.0.11 maintenance notes

## MobaXterm LSP manager 1.1.2

- Treats npm TLS independently from curl/wget download TLS.
- Enables Node 24 Windows system CA support with `NODE_USE_SYSTEM_CA=1`.
- `--ca-bundle FILE` is propagated to npm (`npm_config_cafile`) and Node (`NODE_EXTRA_CA_CERTS`).
- npm remains `strict-ssl=true` on the normal path.
- If npm fails with a certificate-chain error and fallback is permitted, only that npm invocation is retried with `npm_config_strict_ssl=false`.
- `--strict-tls` / `--no-insecure-fallback` prohibits the npm insecure retry.
- No npm TLS setting is written to `.npmrc`; the fallback is process-local.
- Preserves direct MobaXterm execution of `node.exe` and `npm.cmd`.
- Preserves correct `check` exit status and profile validation from 1.1.1.

## Packaging policy

- Latest files only.
- No ddc variants.
- No historical diff files.
- Scripts remain under `scripts/`; LSP tooling remains under `tools/lsp/`.
