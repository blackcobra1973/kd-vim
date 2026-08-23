#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.0.1"

echo "install-vim-copilot-macos.sh version ${SCRIPT_VERSION}"

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

[[ "$(uname -s)" == "Darwin" ]] || die "This installer is for macOS only."

command -v vim >/dev/null 2>&1 || die "vim is not available on PATH."

if ! vim -Nu NONE -n -es \
    -c "if !has('patch-9.0.0185') || !has('textprop') | cquit 2 | endif" \
    -c 'qa!' >/dev/null 2>&1; then
    die "GitHub Copilot ghost text requires Vim 9.0.0185+ with +textprop."
fi

echo "==> Vim capability check: OK"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    command -v brew >/dev/null 2>&1 || die "Node.js/npm are missing and Homebrew is not installed. Install a current supported Node.js release and rerun."
    echo "==> Installing Node.js with Homebrew"
    brew install node
else
    echo "==> Node.js already installed: $(node --version)"
    echo "==> npm already installed: $(npm --version)"
fi

command -v node >/dev/null 2>&1 || die "Node.js installation did not provide 'node'."
command -v npm >/dev/null 2>&1 || die "Node.js installation did not provide 'npm'."

cat <<'NEXT'

macOS Copilot prerequisites are ready.

Next steps:
  1. Start Vim with the 2.6.0.7 configuration.
  2. Run :PlugInstall (or :PlugUpdate).
  3. Run :Copilot setup and authenticate your GitHub Copilot account.
  4. Run :KDAIHealth.

The 2.6 macOS profile enables GitHub Copilot ghost-text completion only.
The OpenAI Codex Vim command integration remains Linux-only.
NEXT
