#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.1.0"
SCRIPT_NAME="lsp-manager-mobaxterm.sh"
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
PROFILE="mobaxterm"
STRICT_TLS=0
ALLOW_INSECURE_FALLBACK=1
CA_BUNDLE=""
ASSUME_YES=0
TLS_FALLBACK_WARNED=0

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
  --profile mobaxterm|minimal
  --ca-bundle FILE          Use a custom CA bundle for curl/wget.
  --strict-tls              Never use an insecure TLS fallback.
  --no-insecure-fallback    Alias for --strict-tls.
  --yes                     Required by clean.
  --home DIR                Override manager root (default: ${LSP_HOME}).
  -h, --help

Profiles:
  mobaxterm  npm LSP stack + Windows terraform-ls + helm_ls + docker-language-server
  minimal    npm LSP stack only

This manager is specifically for MobaXterm/Cygwin/MSYS on Windows.
It executes the private Windows Node distribution through cmd.exe and uses
cygpath for every native Windows path passed to node/npm.
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

try_wget() {
  local insecure="$1" url="$2" out="$3"
  command -v wget >/dev/null 2>&1 || return 1
  local -a args=(wget -q --tries=2 --timeout=30 -O "$out")
  [[ -n "$CA_BUNDLE" ]] && args+=(--ca-certificate="$CA_BUNDLE")
  [[ "$insecure" == 1 ]] && args+=(--no-check-certificate)
  "${args[@]}" "$url" >/dev/null 2>&1
}

try_curl() {
  local insecure="$1" url="$2" out="$3"
  command -v curl >/dev/null 2>&1 || return 1
  local -a args=(curl --fail --location --silent --show-error --retry 2 --connect-timeout 20)
  [[ -n "$CA_BUNDLE" ]] && args+=(--cacert "$CA_BUNDLE")
  [[ "$insecure" == 1 ]] && args+=(--insecure)
  "${args[@]}" --output "$out" "$url" >/dev/null 2>&1
}

download_file() {
  (($# == 2)) || die "download_file requires URL and output path"
  local url="$1" out="$2" tmp="${2}.part"
  rm -f "$tmp"

  # MobaXterm environments often have a curl CA chain mismatch while wget has
  # a usable CA store, so prefer verified wget first and verified curl second.
  if try_wget 0 "$url" "$tmp" || try_curl 0 "$url" "$tmp"; then
    mv -f "$tmp" "$out"
    return 0
  fi

  rm -f "$tmp"
  if (( STRICT_TLS == 1 || ALLOW_INSECURE_FALLBACK == 0 )); then return 1; fi
  if (( TLS_FALLBACK_WARNED == 0 )); then
    warn "Verified TLS failed in MobaXterm; using the configured insecure transport fallback. Downloads are still checked against pinned or upstream SHA256 digests. Use --ca-bundle FILE to restore full TLS verification."
    TLS_FALLBACK_WARNED=1
  fi
  if try_wget 1 "$url" "$tmp" || try_curl 1 "$url" "$tmp"; then
    mv -f "$tmp" "$out"
    return 0
  fi
  rm -f "$tmp"
  return 1
}

platform_detect() {
  local u m
  u="$(uname -s)"; m="$(uname -m)"
  case "$u" in
    CYGWIN*|MINGW*|MSYS*) ;;
    *)
      # MobaXterm can report a custom Unix-like uname. Accept it only when the
      # required Windows bridge commands are present.
      command -v cygpath >/dev/null 2>&1 && command -v cmd.exe >/dev/null 2>&1 || die "${SCRIPT_NAME} requires MobaXterm/Cygwin/MSYS with cygpath and cmd.exe"
      ;;
  esac
  case "$m" in
    x86_64|amd64) ARCH=amd64; NODE_DIST="win-x64"; NODE_PIN="${NODE_WIN_X64_SHA256:-}" ;;
    aarch64|arm64) ARCH=arm64; NODE_DIST="win-arm64"; NODE_PIN="${NODE_WIN_ARM64_SHA256:-}" ;;
    *) die "Unsupported architecture: ${m}" ;;
  esac
  OS=windows
  need cygpath
  need cmd.exe
}

mkdir_layout() { mkdir -p "$BIN_DIR" "$NPM_DIR" "$SERVER_DIR" "$NODE_HOME" "$CACHE_DIR"; }

winpath() { cygpath -w "$1"; }

install_node() {
  mkdir_layout
  local archive url actual tmpdir extracted
  archive="node-v${NODE_VERSION}-${NODE_DIST}.zip"
  url="https://nodejs.org/dist/v${NODE_VERSION}/${archive}"
  [[ -n "$NODE_PIN" ]] || die "No pinned SHA256 configured for ${archive} in versions.conf"
  download_file "$url" "${CACHE_DIR}/${archive}" || die "Unable to download ${archive}"
  actual="$(sha256_file "${CACHE_DIR}/${archive}")"
  [[ "$actual" == "$NODE_PIN" ]] || die "Node checksum mismatch for ${archive}: expected ${NODE_PIN}, got ${actual}"
  rm -rf "$NODE_HOME"; mkdir -p "$NODE_HOME"
  tmpdir="$(mktemp -d)"
  unzip -q "${CACHE_DIR}/${archive}" -d "$tmpdir"
  extracted="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n1)"
  [[ -n "$extracted" ]] || { rm -rf "$tmpdir"; die "Unable to locate extracted Node directory"; }
  cp -a "$extracted"/. "$NODE_HOME"/
  rm -rf "$tmpdir"
  [[ -f "${NODE_HOME}/node.exe" ]] || die "node.exe missing from private Node runtime"
  [[ -f "${NODE_HOME}/npm.cmd" ]] || die "npm.cmd missing from private Node runtime"
  log "Installed private Windows Node ${NODE_VERSION} in ${NODE_HOME}"
}

node_cmd() { [[ -f "${NODE_HOME}/node.exe" ]] && printf '%s\n' "${NODE_HOME}/node.exe" || return 1; }
npm_cmd() { [[ -f "${NODE_HOME}/npm.cmd" ]] && printf '%s\n' "${NODE_HOME}/npm.cmd" || return 1; }

node_run() {
  local node node_win
  node="$(node_cmd)" || die "Private Node runtime not installed"
  node_win="$(winpath "$node")"
  cmd.exe /d /s /c "\"${node_win}\" $*"
}

npm_run() {
  local npm npm_win cwd_win
  npm="$(npm_cmd)" || die "npm.cmd not found in private Node runtime"
  npm_win="$(winpath "$npm")"
  cwd_win="$(winpath "$PWD")"
  # Do not invoke node.exe with a POSIX npm-cli.js path. Native node.exe would
  # reinterpret /home/... as C:\\home\\..., which is not MobaXterm's real home.
  # npm.cmd resolves node.exe and npm-cli.js relative to its own Windows path.
  (
    mkdir -p "${CACHE_DIR}/npm-cache"
    export npm_config_cache="$(winpath "${CACHE_DIR}/npm-cache")"
    cmd.exe /d /s /c "cd /d \"${cwd_win}\" && call \"${npm_win}\" $*"
  )
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
set -euo pipefail
base="${NPM_DIR}/node_modules/.bin/${wrapper_name}"
if [[ -f "\${base}.cmd" ]]; then
  exec cmd.exe /d /s /c "\$(cygpath -w "\${base}.cmd")" "\$@"
fi
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
  asset="terraform-ls_${TERRAFORM_LS_VERSION}_windows_${ARCH}.zip"
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
  bin="$(find "$dest" -maxdepth 2 -type f -name 'terraform-ls.exe' | head -n1)"
  [[ -n "$bin" ]] || die "terraform-ls.exe missing after extraction"
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
  local url file digest actual dest target
  url="https://github.com/${repo}/releases/download/${tag}/${asset}"
  file="${CACHE_DIR}/${asset}"
  digest="$(github_asset_digest "$repo" "$tag" "$asset" || true)"
  [[ -n "$digest" ]] || die "GitHub did not publish a SHA256 asset digest for ${repo} ${tag} ${asset}; refusing unverified install"
  download_file "$url" "$file" || die "Unable to download ${url}"
  actual="$(sha256_file "$file")"
  [[ "$actual" == "$digest" ]] || die "SHA256 mismatch for ${asset}"
  dest="${SERVER_DIR}/${output_name}/${tag}"
  rm -rf "$dest"; mkdir -p "$dest"
  target="${dest}/${output_name}.exe"
  cp "$file" "$target"
  ln -sf "$target" "${BIN_DIR}/${output_name}"
}

install_helm_ls() {
  install_github_binary "mrjosh/helm-ls" "$HELM_LS_VERSION" "helm_ls_windows_${ARCH}.exe" "helm_ls"
}

install_docker_ls() {
  local asset="docker-language-server-windows-${ARCH}-v${DOCKER_LS_VERSION}.exe"
  install_github_binary "docker/docker-language-server" "v${DOCKER_LS_VERSION}" "$asset" "docker-language-server"
}

install_profile() {
  case "$PROFILE" in mobaxterm|minimal) ;; *) die "Unknown profile: $PROFILE" ;; esac
  mkdir_layout
  install_npm_servers
  if [[ "$PROFILE" == mobaxterm ]]; then
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
  printf 'platform:    MobaXterm/Windows %s\n' "$ARCH"
  printf 'profile:     %s\n' "$PROFILE"
  printf 'home:        %s\n' "$LSP_HOME"
  local node node_win
  if node="$(node_cmd 2>/dev/null)"; then
    node_win="$(winpath "$node")"
    printf 'node:        %s (%s)\n' "$node" "$(cmd.exe /d /s /c "\"${node_win}\" --version" 2>/dev/null | tr -d '\r' || true)"
  else
    printf 'node:        NOT INSTALLED\n'
  fi
  local npm npm_win npm_version
  if npm="$(npm_cmd 2>/dev/null)"; then
    npm_win="$(winpath "$npm")"
    npm_version="$(cmd.exe /d /s /c "call \"${npm_win}\" --version" 2>/dev/null | tr -d '\r' || true)"
    printf 'npm bridge:  %s (%s)\n' "$npm" "${npm_version:-FAILED}"
  else
    printf 'npm bridge:  NOT INSTALLED\n'
  fi
  list_servers
}

show_versions() {
  cat "$VERSIONS_FILE"
  printf '\nPinned npm packages:\n'
  sed -n '/"dependencies"/,/}/p' "$NPM_PACKAGE_FILE"
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
  install|update) platform_detect; need unzip; install_profile ;;
  check) check_install ;;
  list) list_servers ;;
  versions) show_versions ;;
  lock) platform_detect; lock_source ;;
  clean) (( ASSUME_YES == 1 )) || die "clean deletes ${LSP_HOME}; rerun with --yes"; rm -rf "$LSP_HOME"; log "Removed ${LSP_HOME}" ;;
  help) usage ;;
  *) usage; die "Unknown action: $ACTION" ;;
esac
