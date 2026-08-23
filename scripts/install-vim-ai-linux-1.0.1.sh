#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.0.1"
CA_BUNDLE="${KD_CURL_CA_BUNDLE:-}"
ALLOW_INSECURE_FALLBACK="${KD_CURL_ALLOW_INSECURE_FALLBACK:-1}"
SKIP_PACKAGES=0
SKIP_CODEX=0

usage() {
  cat <<USAGE
install-vim-ai-linux.sh version ${SCRIPT_VERSION}

Installs Linux prerequisites for Vim 2.5.0.3 AI support:
  - Node.js + npm for github/copilot.vim
  - OpenAI Codex CLI via the official standalone installer, exposed as /usr/local/bin/codex

Supported package-manager families:
  - RHEL / AlmaLinux 9 and 10 (dnf)
  - Debian 13 and derivatives (apt)

Usage:
  $0 [options]

Options:
  --ca-bundle FILE       Use FILE as the CA bundle for the Codex installer download.
  --strict-tls           Never retry the Codex installer download with --insecure.
  --skip-packages        Do not install curl/git/nodejs/npm/ca-certificates.
  --skip-codex           Do not install/update the Codex CLI.
  -h, --help             Show this help.

Environment equivalents:
  KD_CURL_CA_BUNDLE=/path/to/ca.pem
  KD_CURL_ALLOW_INSECURE_FALLBACK=0|1
USAGE
}

log() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while (($#)); do
  case "$1" in
    --ca-bundle)
      (($# >= 2)) || die "--ca-bundle requires a file"
      CA_BUNDLE="$2"; shift 2 ;;
    --strict-tls)
      ALLOW_INSECURE_FALLBACK=0; shift ;;
    --skip-packages)
      SKIP_PACKAGES=1; shift ;;
    --skip-codex)
      SKIP_CODEX=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

[[ "$(uname -s)" == "Linux" ]] || die "This installer is intentionally Linux-only."

if [[ -n "$CA_BUNDLE" && ! -r "$CA_BUNDLE" ]]; then
  die "CA bundle is not readable: $CA_BUNDLE"
fi

run_privileged() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    die "Root privileges are required for package installation (sudo not found)."
  fi
}

if (( ! SKIP_PACKAGES )); then
  if command -v dnf >/dev/null 2>&1; then
    log "Installing RHEL/AlmaLinux prerequisites with dnf"
    run_privileged dnf install -y ca-certificates curl git nodejs npm
  elif command -v apt-get >/dev/null 2>&1; then
    log "Installing Debian prerequisites with apt"
    run_privileged apt-get update
    run_privileged apt-get install -y ca-certificates curl git nodejs npm
  else
    die "Neither dnf nor apt-get was found. Use --skip-packages after installing curl, git, node and npm manually."
  fi
fi

for cmd in curl git node npm; do
  command -v "$cmd" >/dev/null 2>&1 || die "Required command not found after prerequisite step: $cmd"
done

log "Node.js: $(node --version)"
log "npm: $(npm --version)"

if (( ! SKIP_CODEX )); then
  CODEX_INSTALL_URL='https://chatgpt.com/codex/install.sh'
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT
  installer="$tmpdir/codex-install.sh"

  curl_args=(--fail --location --silent --show-error)
  if [[ -n "$CA_BUNDLE" ]]; then
    curl_args+=(--cacert "$CA_BUNDLE")
  fi

  log "Downloading the official OpenAI Codex CLI installer with TLS verification"
  if ! curl "${curl_args[@]}" "$CODEX_INSTALL_URL" -o "$installer"; then
    if [[ "$ALLOW_INSECURE_FALLBACK" == "1" ]]; then
      warn "Verified TLS download failed. Retrying once with --insecure because fallback is enabled."
      curl --fail --location --silent --show-error --insecure "$CODEX_INSTALL_URL" -o "$installer"
    else
      die "Codex installer download failed and insecure fallback is disabled."
    fi
  fi

  [[ -s "$installer" ]] || die "Downloaded Codex installer is empty."
  chmod 700 "$installer"
  # The official standalone installer supports CODEX_INSTALL_DIR.  Keep the
  # managed package cache outside /root so /usr/local/bin/codex remains usable
  # for non-root users as well.
  CODEX_SYSTEM_HOME='/usr/local/lib/codex'
  CODEX_INSTALL_DIR='/usr/local/bin'

  log "Running the official OpenAI Codex CLI installer"
  log "Codex command path: ${CODEX_INSTALL_DIR}/codex"
  log "Codex managed package cache: ${CODEX_SYSTEM_HOME}/packages/standalone"
  run_privileged mkdir -p "$CODEX_INSTALL_DIR" "$CODEX_SYSTEM_HOME"
  run_privileged env \
    CODEX_NON_INTERACTIVE=1 \
    CODEX_INSTALL_DIR="$CODEX_INSTALL_DIR" \
    CODEX_HOME="$CODEX_SYSTEM_HOME" \
    sh "$installer"
fi

if (( ! SKIP_CODEX )); then
  if [[ -x /usr/local/bin/codex ]]; then
    log "Codex CLI: $(/usr/local/bin/codex --version 2>/dev/null || true)"
  else
    die "Codex installation completed without creating /usr/local/bin/codex"
  fi
else
  log "Skipping Codex installation/update as requested"
fi

cat <<'NEXT'

Next steps for Vim 2.5.0.3:
  1. Run: codex
     On first use choose "Sign in with ChatGPT".
  2. Start Vim and run: :PlugInstall
  3. Run: :Copilot setup
  4. Run: :KDAIHealth

Copilot is installed by vim-plug from the Vim configuration; this script only
installs its Node.js/npm runtime prerequisites and installs Codex at /usr/local/bin/codex.
NEXT
