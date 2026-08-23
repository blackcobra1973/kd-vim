#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.0.4"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
VERSIONS_FILE="${SCRIPT_DIR}/versions.conf"
[[ -r "${VERSIONS_FILE}" ]] || VERSIONS_FILE="${SCRIPT_DIR}/lsp-versions.conf"
NPM_PACKAGE_FILE="${SCRIPT_DIR}/npm/package.json"
NPM_LOCK_FILE="${SCRIPT_DIR}/npm/package-lock.json"
[[ -r "${NPM_PACKAGE_FILE}" ]] || NPM_PACKAGE_FILE="${SCRIPT_DIR}/lsp-npm-package.json"
[[ -r "${NPM_LOCK_FILE}" ]] || NPM_LOCK_FILE="${SCRIPT_DIR}/lsp-npm-package-lock.json"
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

# shellcheck disable=SC1090
[[ -r "${VERSIONS_FILE}" ]] && source "${VERSIONS_FILE}"
: "${NODE_VERSION:=24.19.0}"
: "${TERRAFORM_LS_VERSION:=0.39.0}"
: "${DOCKER_LS_VERSION:=0.20.1}"
: "${HELM_LS_VERSION:=master}"

usage() {
  cat <<USAGE
lsp-manager.sh ${SCRIPT_VERSION}

Usage:
  $0 <install|update|check|list|versions|lock|clean> [options]

Options:
  --profile standard|mobaxterm|minimal
  --ca-bundle FILE          Use a custom CA bundle for HTTPS downloads.
  --strict-tls              Never retry a failed download with curl --insecure.
  --no-insecure-fallback    Alias for --strict-tls.
  --yes                     Required by clean; skip confirmation-style safeguards.
  --home DIR                Override VIM LSP manager root (default: ${LSP_HOME}).
  -h, --help

Profiles:
  standard   npm LSP stack + terraform-ls + helm_ls + docker-language-server
  mobaxterm  same server set, using Windows native assets where available
  minimal    npm LSP stack only (no native Terraform/Helm/Docker binaries)

The stable executable interface used by Vim is: ${BIN_DIR}
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

curl_download() {
  (($# == 2)) || die "curl_download requires URL and output path"
  local url
  local out
  url="$1"
  out="$2"
  local -a base=(curl --fail --location --silent --show-error --retry 2 --connect-timeout 20)
  [[ -n "${CA_BUNDLE}" ]] && base+=(--cacert "${CA_BUNDLE}")
  if "${base[@]}" --output "${out}" "${url}"; then return 0; fi
  if (( STRICT_TLS == 0 && ALLOW_INSECURE_FALLBACK == 1 )); then
    warn "Verified TLS failed for ${url}; retrying with curl --insecure. Prefer --ca-bundle for managed environments."
    "${base[@]}" --insecure --output "${out}" "${url}"
  else
    return 1
  fi
}

curl_text() {
  (($# == 2)) || die "curl_text requires URL and output path"
  local url
  local out
  url="$1"
  out="$2"
  curl_download "$url" "$out"
}

platform_detect() {
  local u
  local m
  u="$(uname -s)"
  m="$(uname -m)"
  case "$u" in
    Linux*) OS=linux ;;
    Darwin*) OS=darwin ;;
    CYGWIN*|MINGW*|MSYS*) OS=windows ;;
    *) die "Unsupported OS: ${u}" ;;
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
    windows:amd64) NODE_DIST="win-x64" ;;
    windows:arm64) NODE_DIST="win-arm64" ;;
  esac
}

mkdir_layout() { mkdir -p "$BIN_DIR" "$NPM_DIR" "$SERVER_DIR" "$NODE_HOME" "$CACHE_DIR"; }

install_node() {
  mkdir_layout
  local ext archive url sums expected actual tmpdir
  if [[ "$OS" == windows ]]; then ext=zip; else ext=tar.xz; fi
  archive="node-v${NODE_VERSION}-${NODE_DIST}.${ext}"
  url="https://nodejs.org/dist/v${NODE_VERSION}/${archive}"
  sums="${CACHE_DIR}/node-v${NODE_VERSION}-SHASUMS256.txt"
  curl_text "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt" "$sums" || die "Unable to download Node checksums"
  expected="$(awk -v f="$archive" '$2==f || $2=="*"f {print $1; exit}' "$sums")"
  [[ -n "$expected" ]] || die "No checksum found for ${archive}"
  curl_download "$url" "${CACHE_DIR}/${archive}" || die "Unable to download ${archive}"
  actual="$(sha256_file "${CACHE_DIR}/${archive}")"
  [[ "$actual" == "$expected" ]] || die "Node checksum mismatch for ${archive}"
  rm -rf "$NODE_HOME"; mkdir -p "$NODE_HOME"
  tmpdir="$(mktemp -d)"
  if [[ "$ext" == zip ]]; then
    need unzip; unzip -q "${CACHE_DIR}/${archive}" -d "$tmpdir"
  else
    tar -xJf "${CACHE_DIR}/${archive}" -C "$tmpdir"
  fi
  local extracted
  extracted="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n1)"
  [[ -n "$extracted" ]] || { rm -rf "$tmpdir"; die "Unable to locate extracted Node directory"; }
  cp -a "$extracted"/. "$NODE_HOME"/
  rm -rf "$tmpdir"
  log "Installed private Node ${NODE_VERSION} in ${NODE_HOME}"
}

node_cmd() {
  if [[ -x "${NODE_HOME}/bin/node" ]]; then printf '%s\n' "${NODE_HOME}/bin/node"
  elif [[ -x "${NODE_HOME}/node.exe" ]]; then printf '%s\n' "${NODE_HOME}/node.exe"
  else return 1; fi
}

npm_cli() {
  local p
  for p in "${NODE_HOME}/lib/node_modules/npm/bin/npm-cli.js" "${NODE_HOME}/node_modules/npm/bin/npm-cli.js"; do
    [[ -f "$p" ]] && { printf '%s\n' "$p"; return 0; }
  done
  return 1
}

npm_run() {
  local node cli
  node="$(node_cmd)" || die "Private Node runtime not installed"
  cli="$(npm_cli)" || die "npm-cli.js not found in private Node runtime"
  "$node" "$cli" "$@"
}

materialize_runtime_lock() {
  cp "${NPM_PACKAGE_FILE}" "${NPM_DIR}/package.json"
  cp "${NPM_LOCK_FILE}" "${NPM_DIR}/package-lock.json"
  if grep -q '"kdSeedLock"[[:space:]]*:[[:space:]]*true' "${NPM_DIR}/package-lock.json"; then
    log "Expanding seed npm lockfile into a complete transitive lock"
    rm -f "${NPM_DIR}/package-lock.json"
    (cd "$NPM_DIR" && npm_run install --package-lock-only --ignore-scripts --no-audit --no-fund)
  fi
}

install_npm_servers() {
  install_node
  materialize_runtime_lock
  (cd "$NPM_DIR" && npm_run ci --ignore-scripts --no-audit --no-fund)
  local names=(bash-language-server yaml-language-server ansible-language-server pyright-langserver typescript-language-server vscode-json-language-server vscode-html-language-server vscode-css-language-server vim-language-server)
  local n
  for n in "${names[@]}"; do create_npm_wrapper "$n"; done
}

create_npm_wrapper() {
  (($# == 1)) || die "create_npm_wrapper requires exactly one executable name"
  local wrapper_name
  local target
  wrapper_name="$1"
  target="${BIN_DIR}/${wrapper_name}"
  cat > "$target" <<WRAP
#!/usr/bin/env bash
set -e
export PATH="${NODE_HOME}/bin:${NODE_HOME}:\$PATH"
base="${NPM_DIR}/node_modules/.bin/${wrapper_name}"
if [[ -x "\$base" ]]; then exec "\$base" "\$@"; fi
if [[ -f "\${base}.cmd" ]]; then
  if command -v cygpath >/dev/null 2>&1 && command -v cmd.exe >/dev/null 2>&1; then
    exec cmd.exe /c "\$(cygpath -w "\${base}.cmd")" "\$@"
  fi
  exec "\${base}.cmd" "\$@"
fi
echo "Missing npm language-server executable: ${wrapper_name}" >&2
exit 127
WRAP
  chmod 0755 "$target"
}

install_terraform_ls() {
  local osname
  local archname
  local asset
  local base
  local sums
  local expected
  local dest
  local bin
  if [[ "$OS" == windows ]]; then osname=windows; else osname="$OS"; fi
  archname="$ARCH"
  asset="terraform-ls_${TERRAFORM_LS_VERSION}_${osname}_${archname}.zip"
  base="https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION}"
  sums="${CACHE_DIR}/terraform-ls_${TERRAFORM_LS_VERSION}_SHA256SUMS"
  curl_download "${base}/terraform-ls_${TERRAFORM_LS_VERSION}_SHA256SUMS" "$sums" || die "Unable to download terraform-ls checksums"
  expected="$(awk -v f="$asset" '$2==f || $2=="*"f {print $1; exit}' "$sums")"
  [[ -n "$expected" ]] || die "No terraform-ls checksum for ${asset}"
  curl_download "${base}/${asset}" "${CACHE_DIR}/${asset}" || die "Unable to download ${asset}"
  [[ "$(sha256_file "${CACHE_DIR}/${asset}")" == "$expected" ]] || die "terraform-ls checksum mismatch"
  dest="${SERVER_DIR}/terraform-ls/${TERRAFORM_LS_VERSION}"
  rm -rf "$dest"
  mkdir -p "$dest"
  unzip -q "${CACHE_DIR}/${asset}" -d "$dest"
  bin="$(find "$dest" -maxdepth 2 -type f \( -name terraform-ls -o -name terraform-ls.exe \) | head -n1)"
  [[ -n "$bin" ]] || die "terraform-ls binary missing after extraction"
  chmod 0755 "$bin" 2>/dev/null || true
  ln -sf "$bin" "${BIN_DIR}/terraform-ls"
}

github_asset_digest() {
  (($# == 3)) || die "github_asset_digest requires repo, tag, and asset"
  local repo
  local tag
  local asset
  local json
  repo="$1"
  tag="$2"
  asset="$3"
  json="${CACHE_DIR}/github-${repo//\//_}-${tag}.json"
  curl_download "https://api.github.com/repos/${repo}/releases/tags/${tag}" "$json" || return 1
  awk -v want="$asset" '
    index($0, "\"name\"") { hit = index($0, "\"" want "\"") > 0 }
    hit && index($0, "\"digest\"") {
      if (match($0, /sha256:[0-9a-fA-F]+/)) {print substr($0,RSTART+7,RLENGTH-7); exit}
    }
  ' "$json"
}

install_github_binary() {
  (($# == 4)) || die "install_github_binary requires repo, tag, asset, and output name"
  local repo
  local tag
  local asset
  local output_name
  local url
  local file
  local digest
  local actual
  local dest
  repo="$1"
  tag="$2"
  asset="$3"
  output_name="$4"
  url="https://github.com/${repo}/releases/download/${tag}/${asset}"
  file="${CACHE_DIR}/${asset}"
  digest="$(github_asset_digest "$repo" "$tag" "$asset" || true)"
  [[ -n "$digest" ]] || die "GitHub did not publish a SHA256 asset digest for ${repo} ${tag} ${asset}; refusing unverified install"
  curl_download "$url" "$file" || die "Unable to download ${url}"
  actual="$(sha256_file "$file")"
  [[ "$actual" == "$digest" ]] || die "SHA256 mismatch for ${asset}"
  dest="${SERVER_DIR}/${output_name}/${tag}"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp "$file" "${dest}/${output_name}$([[ "$OS" == windows ]] && printf '.exe')"
  chmod 0755 "${dest}/${output_name}"* 2>/dev/null || true
  ln -sf "$(find "$dest" -maxdepth 1 -type f | head -n1)" "${BIN_DIR}/${output_name}"
}

install_helm_ls() {
  local osname
  local asset
  osname="$OS"
  [[ "$OS" == windows ]] && osname=windows
  asset="helm_ls_${osname}_${ARCH}"
  [[ "$OS" == windows ]] && asset+=".exe"
  install_github_binary "mrjosh/helm-ls" "$HELM_LS_VERSION" "$asset" "helm_ls"
}

install_docker_ls() {
  local osname
  local asset
  osname="$OS"
  [[ "$OS" == windows ]] && osname=windows
  # Docker release assets include the release version in the filename.
  # Example for v0.20.1: docker-language-server-linux-amd64-v0.20.1
  # The previous unversioned filename made GitHub digest lookup miss the asset
  # and fail closed with "did not publish a SHA256 asset digest".
  asset="docker-language-server-${osname}-${ARCH}-v${DOCKER_LS_VERSION}"
  [[ "$OS" == windows ]] && asset+=".exe"
  install_github_binary "docker/docker-language-server" "v${DOCKER_LS_VERSION}" "$asset" "docker-language-server"
}

install_profile() {
  case "$PROFILE" in
    standard|mobaxterm|minimal) ;;
    *) die "Unknown profile: $PROFILE" ;;
  esac
  mkdir_layout
  install_npm_servers
  if [[ "$PROFILE" != minimal ]]; then
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
  printf 'lsp-manager: %s\n' "$SCRIPT_VERSION"
  printf 'platform:    %s/%s\n' "$OS" "$ARCH"
  printf 'profile:     %s\n' "$PROFILE"
  printf 'home:        %s\n' "$LSP_HOME"
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
  cp "${NPM_PACKAGE_FILE}" "${NPM_DIR}/package.json"
  rm -f "${NPM_DIR}/package-lock.json"
  (cd "$NPM_DIR" && npm_run install --package-lock-only --ignore-scripts --no-audit --no-fund)
  cp "${NPM_DIR}/package-lock.json" "${NPM_LOCK_FILE}"
  log "Wrote complete lockfile: ${NPM_LOCK_FILE}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ACTION="${1:-}"
[[ -n "$ACTION" ]] || { usage; exit 2; }
shift || true
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

[[ "$ACTION" == "help" ]] || log "lsp-manager.sh version ${SCRIPT_VERSION}"

case "$ACTION" in
  install|update) need curl; platform_detect; install_profile ;;
  check) check_install ;;
  list) list_servers ;;
  versions) show_versions ;;
  lock) need curl; lock_source ;;
  clean)
    (( ASSUME_YES == 1 )) || die "clean deletes ${LSP_HOME}; rerun with --yes"
    rm -rf "$LSP_HOME"; log "Removed ${LSP_HOME}" ;;
  help) usage ;;
  *) usage; die "Unknown action: $ACTION" ;;
esac
