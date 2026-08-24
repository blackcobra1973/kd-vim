#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="lsp-manager-linux-macos.sh"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
VERSIONS_FILE="${SCRIPT_DIR}/versions.conf"
NPM_PACKAGE_FILE="${SCRIPT_DIR}/npm/package.json"
NPM_LOCK_FILE="${SCRIPT_DIR}/npm/package-lock.json"
LSP_HOME="${VIM_LSP_HOME:-${HOME}/.local/share/vim-lsp}"
BIN_DIR="${LSP_HOME}/bin"
NPM_DIR="${LSP_HOME}/npm"
SERVER_DIR="${LSP_HOME}/servers"
NODE_HOME="${LSP_HOME}/runtime/node"
CACHE_DIR="${LSP_HOME}/cache"
PROFILE="standard"
STRICT_TLS=0
ALLOW_INSECURE_FALLBACK=1
CA_BUNDLE=""
ASSUME_YES=0

[[ -r "${VERSIONS_FILE}" ]] || { echo "ERROR: Missing ${VERSIONS_FILE}" >&2; exit 1; }
[[ -r "${NPM_PACKAGE_FILE}" ]] || { echo "ERROR: Missing ${NPM_PACKAGE_FILE}" >&2; exit 1; }
[[ -r "${NPM_LOCK_FILE}" ]] || { echo "ERROR: Missing ${NPM_LOCK_FILE}" >&2; exit 1; }
# shellcheck disable=SC1090
source "${VERSIONS_FILE}"

usage() {
  cat <<USAGE
${SCRIPT_NAME} ${SCRIPT_VERSION}

Usage:
  $0 <install|update|check|list|versions|lock|clean> [options]

Options:
  --profile standard|minimal
  --ca-bundle FILE          Use a custom CA bundle for HTTPS downloads.
  --strict-tls              Never retry a failed download with curl --insecure.
  --no-insecure-fallback    Alias for --strict-tls.
  --yes                     Required by clean.
  --home DIR                Override manager root (default: ${LSP_HOME}).
  -h, --help

Profiles:
  standard   npm LSP stack + terraform-ls + helm_ls + docker-language-server
  minimal    npm LSP stack only

Supported platforms: Linux and macOS only.
USAGE
}

log() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else die "sha256sum or shasum is required"; fi
}

download_file() {
  (($# == 2)) || die "download_file requires URL and output path"
  local url="$1" out="$2"
  local -a base=(curl --fail --location --silent --show-error --retry 2 --connect-timeout 20)
  [[ -n "${CA_BUNDLE}" ]] && base+=(--cacert "${CA_BUNDLE}")
  if "${base[@]}" --output "${out}" "${url}"; then return 0; fi
  if (( STRICT_TLS == 0 && ALLOW_INSECURE_FALLBACK == 1 )); then
    warn "Verified TLS failed for ${url}; retrying with curl --insecure. Prefer --ca-bundle."
    "${base[@]}" --insecure --output "${out}" "${url}"
  else
    return 1
  fi
}

platform_detect() {
  local u m
  u="$(uname -s)"; m="$(uname -m)"
  case "$u" in
    Linux*) OS=linux ;;
    Darwin*) OS=darwin ;;
    *) die "Unsupported platform for ${SCRIPT_NAME}: ${u}" ;;
  esac
  case "$m" in
    x86_64|amd64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) die "Unsupported architecture: ${m}" ;;
  esac
  case "${OS}:${ARCH}" in
    linux:amd64) NODE_DIST="linux-x64" ;;
    linux:arm64) NODE_DIST="linux-arm64" ;;
    darwin:amd64) NODE_DIST="darwin-x64" ;;
    darwin:arm64) NODE_DIST="darwin-arm64" ;;
  esac
}

mkdir_layout() { mkdir -p "$BIN_DIR" "$NPM_DIR" "$SERVER_DIR" "$NODE_HOME" "$CACHE_DIR"; }

install_node() {
  mkdir_layout
  local archive url sums expected actual tmpdir extracted
  archive="node-v${NODE_VERSION}-${NODE_DIST}.tar.xz"
  url="https://nodejs.org/dist/v${NODE_VERSION}/${archive}"
  sums="${CACHE_DIR}/node-v${NODE_VERSION}-SHASUMS256.txt"
  download_file "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" "$sums" || die "Unable to download Node checksums"
  expected="$(awk -v f="$archive" '$2==f || $2=="*"f {print $1; exit}' "$sums")"
  [[ -n "$expected" ]] || die "No checksum found for ${archive}"
  download_file "$url" "${CACHE_DIR}/${archive}" || die "Unable to download ${archive}"
  actual="$(sha256_file "${CACHE_DIR}/${archive}")"
  [[ "$actual" == "$expected" ]] || die "Node checksum mismatch for ${archive}"
  rm -rf "$NODE_HOME"; mkdir -p "$NODE_HOME"
  tmpdir="$(mktemp -d)"
  tar -xJf "${CACHE_DIR}/${archive}" -C "$tmpdir"
  extracted="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n1)"
  [[ -n "$extracted" ]] || { rm -rf "$tmpdir"; die "Unable to locate extracted Node directory"; }
  cp -a "$extracted"/. "$NODE_HOME"/
  rm -rf "$tmpdir"
  log "Installed private Node ${NODE_VERSION} in ${NODE_HOME}"
}

node_cmd() { [[ -x "${NODE_HOME}/bin/node" ]] && printf '%s\n' "${NODE_HOME}/bin/node" || return 1; }

npm_cli() {
  local p="${NODE_HOME}/lib/node_modules/npm/bin/npm-cli.js"
  [[ -f "$p" ]] && printf '%s\n' "$p" || return 1
}

npm_run() {
  local node cli
  node="$(node_cmd)" || die "Private Node runtime not installed"
  cli="$(npm_cli)" || die "npm-cli.js not found in private Node runtime"
  "$node" "$cli" "$@"
}

materialize_runtime_lock() {
  cp "$NPM_PACKAGE_FILE" "${NPM_DIR}/package.json"
  cp "$NPM_LOCK_FILE" "${NPM_DIR}/package-lock.json"
  if grep -q '"kdSeedLock"[[:space:]]*:[[:space:]]*true' "${NPM_DIR}/package-lock.json"; then
    log "Expanding seed npm lockfile into a complete transitive lock"
    rm -f "${NPM_DIR}/package-lock.json"
    (cd "$NPM_DIR" && npm_run install --package-lock-only --ignore-scripts --no-audit --no-fund)
  fi
}

create_npm_wrapper() {
  local wrapper_name="$1" target="${BIN_DIR}/$1"
  cat > "$target" <<WRAP
#!/usr/bin/env bash
set -e
export PATH="${NODE_HOME}/bin:\$PATH"
base="${NPM_DIR}/node_modules/.bin/${wrapper_name}"
if [[ -x "\$base" ]]; then exec "\$base" "\$@"; fi
echo "Missing npm language-server executable: ${wrapper_name}" >&2
exit 127
WRAP
  chmod 0755 "$target"
}

install_npm_servers() {
  install_node
  materialize_runtime_lock
  (cd "$NPM_DIR" && npm_run ci --ignore-scripts --no-audit --no-fund)
  local names=(bash-language-server yaml-language-server ansible-language-server pyright-langserver typescript-language-server vscode-json-language-server vscode-html-language-server vscode-css-language-server vim-language-server)
  local n
  for n in "${names[@]}"; do create_npm_wrapper "$n"; done
}

install_terraform_ls() {
  local asset base sums expected dest bin
  asset="terraform-ls_${TERRAFORM_LS_VERSION}_${OS}_${ARCH}.zip"
  base="https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION}"
  sums="${CACHE_DIR}/terraform-ls_${TERRAFORM_LS_VERSION}_SHA256SUMS"
  download_file "${base}/terraform-ls_${TERRAFORM_LS_VERSION}_SHA256SUMS" "$sums" || die "Unable to download terraform-ls checksums"
  expected="$(awk -v f="$asset" '$2==f || $2=="*"f {print $1; exit}' "$sums")"
  [[ -n "$expected" ]] || die "No terraform-ls checksum for ${asset}"
  download_file "${base}/${asset}" "${CACHE_DIR}/${asset}" || die "Unable to download ${asset}"
  [[ "$(sha256_file "${CACHE_DIR}/${asset}")" == "$expected" ]] || die "terraform-ls checksum mismatch"
  dest="${SERVER_DIR}/terraform-ls/${TERRAFORM_LS_VERSION}"
  rm -rf "$dest"; mkdir -p "$dest"
  unzip -q "${CACHE_DIR}/${asset}" -d "$dest"
  bin="$(find "$dest" -maxdepth 2 -type f -name terraform-ls | head -n1)"
  [[ -n "$bin" ]] || die "terraform-ls binary missing after extraction"
  chmod 0755 "$bin"
  ln -sf "$bin" "${BIN_DIR}/terraform-ls"
}

github_asset_digest() {
  local repo="$1" tag="$2" asset="$3" json
  json="${CACHE_DIR}/github-${repo//\//_}-${tag}.json"
  download_file "https://api.github.com/repos/${repo}/releases/tags/${tag}" "$json" || return 1
  awk -v want="$asset" '
    index($0, "\"name\"") { hit = index($0, "\"" want "\"") > 0 }
    hit && index($0, "\"digest\"") {
      if (match($0, /sha256:[0-9a-fA-F]+/)) {print substr($0,RSTART+7,RLENGTH-7); exit}
    }
  ' "$json"
}

install_github_binary() {
  local repo="$1" tag="$2" asset="$3" output_name="$4"
  local url file digest actual dest
  url="https://github.com/${repo}/releases/download/${tag}/${asset}"
  file="${CACHE_DIR}/${asset}"
  digest="$(github_asset_digest "$repo" "$tag" "$asset" || true)"
  [[ -n "$digest" ]] || die "GitHub did not publish a SHA256 asset digest for ${repo} ${tag} ${asset}; refusing unverified install"
  download_file "$url" "$file" || die "Unable to download ${url}"
  actual="$(sha256_file "$file")"
  [[ "$actual" == "$digest" ]] || die "SHA256 mismatch for ${asset}"
  dest="${SERVER_DIR}/${output_name}/${tag}"
  rm -rf "$dest"; mkdir -p "$dest"
  cp "$file" "${dest}/${output_name}"
  chmod 0755 "${dest}/${output_name}"
  ln -sf "${dest}/${output_name}" "${BIN_DIR}/${output_name}"
}

install_helm_ls() {
  install_github_binary "mrjosh/helm-ls" "$HELM_LS_VERSION" "helm_ls_${OS}_${ARCH}" "helm_ls"
}

install_docker_ls() {
  local asset="docker-language-server-${OS}-${ARCH}-v${DOCKER_LS_VERSION}"
  install_github_binary "docker/docker-language-server" "v${DOCKER_LS_VERSION}" "$asset" "docker-language-server"
}

install_profile() {
  case "$PROFILE" in standard|minimal) ;; *) die "Unknown profile: $PROFILE" ;; esac
  mkdir_layout
  install_npm_servers
  if [[ "$PROFILE" == standard ]]; then
    install_terraform_ls
    install_helm_ls
    install_docker_ls
  fi
  log "LSP profile '${PROFILE}' installed under ${LSP_HOME}"
}

list_servers() {
  local names=(bash-language-server yaml-language-server ansible-language-server pyright-langserver typescript-language-server vscode-json-language-server vscode-html-language-server vscode-css-language-server vim-language-server terraform-ls helm_ls docker-language-server)
  printf '%-30s %s\n' SERVER PATH
  local n p
  for n in "${names[@]}"; do
    p="${BIN_DIR}/${n}"
    [[ -e "$p" || -L "$p" ]] && printf '%-30s %s\n' "$n" "$p" || printf '%-30s %s\n' "$n" 'NOT INSTALLED'
  done
}

check_install() {
  platform_detect
  printf '%s: %s\n' "$SCRIPT_NAME" "$SCRIPT_VERSION"
  printf 'platform:    %s/%s\n' "$OS" "$ARCH"
  printf 'profile:     %s\n' "$PROFILE"
  printf 'home:        %s\n' "$LSP_HOME"
  local node
  if node="$(node_cmd 2>/dev/null)"; then printf 'node:        %s (%s)\n' "$node" "$($node --version 2>/dev/null || true)"; else printf 'node:        NOT INSTALLED\n'; fi
  list_servers
}

show_versions() {
  cat "$VERSIONS_FILE"
  printf '\nPinned npm packages:\n'
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$NPM_PACKAGE_FILE" <<'PY'
import json,sys
p=json.load(open(sys.argv[1]))
for k,v in sorted(p['dependencies'].items()): print(f'{k}={v}')
PY
  else
    sed -n '/"dependencies"/,/}/p' "$NPM_PACKAGE_FILE"
  fi
}

lock_source() {
  platform_detect; mkdir_layout; install_node
  cp "$NPM_PACKAGE_FILE" "${NPM_DIR}/package.json"
  rm -f "${NPM_DIR}/package-lock.json"
  (cd "$NPM_DIR" && npm_run install --package-lock-only --ignore-scripts --no-audit --no-fund)
  cp "${NPM_DIR}/package-lock.json" "$NPM_LOCK_FILE"
  log "Wrote complete lockfile: ${NPM_LOCK_FILE}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then usage; exit 0; fi
ACTION="${1:-}"; [[ -n "$ACTION" ]] || { usage; exit 2; }; shift || true
while (($#)); do
  case "$1" in
    --profile) PROFILE="${2:?}"; shift 2 ;;
    --ca-bundle) CA_BUNDLE="${2:?}"; shift 2 ;;
    --strict-tls|--no-insecure-fallback) STRICT_TLS=1; ALLOW_INSECURE_FALLBACK=0; shift ;;
    --yes) ASSUME_YES=1; shift ;;
    --home) LSP_HOME="${2:?}"; BIN_DIR="${LSP_HOME}/bin"; NPM_DIR="${LSP_HOME}/npm"; SERVER_DIR="${LSP_HOME}/servers"; NODE_HOME="${LSP_HOME}/runtime/node"; CACHE_DIR="${LSP_HOME}/cache"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done
[[ "$ACTION" == help ]] || log "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
case "$ACTION" in
  install|update) need curl; need unzip; platform_detect; install_profile ;;
  check) check_install ;;
  list) list_servers ;;
  versions) show_versions ;;
  lock) need curl; platform_detect; lock_source ;;
  clean) (( ASSUME_YES == 1 )) || die "clean deletes ${LSP_HOME}; rerun with --yes"; rm -rf "$LSP_HOME"; log "Removed ${LSP_HOME}" ;;
  help) usage ;;
  *) usage; die "Unknown action: $ACTION" ;;
esac
