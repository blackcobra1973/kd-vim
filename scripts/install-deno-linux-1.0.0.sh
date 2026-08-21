#!/usr/bin/env bash
#
# install-deno-linux.sh
# Version: 1.0.0 - 2026-08-21
#
# Installs the official Deno standalone Linux binary on:
#   - RHEL 9 / RHEL 10
#   - AlmaLinux 9 / AlmaLinux 10
#   - Debian 13
#
# The installer does NOT use AppImage and does NOT require FUSE/fusermount.
# TLS certificate validation is always attempted first.  An optional custom CA
# can be tried next, followed by an explicitly controlled insecure fallback.
#
set -Eeuo pipefail

SCRIPT_VERSION='1.0.0'
MIN_DENO_VERSION='2.3.0'
INSTALL_PREFIX="${DENO_INSTALL_PREFIX:-/usr/local}"
REQUESTED_VERSION="${DENO_VERSION:-latest}"
CA_BUNDLE="${DENO_CA_BUNDLE:-}"
ALLOW_INSECURE_FALLBACK="${DENO_ALLOW_INSECURE_FALLBACK:-1}"
FORCE=0

log()  { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<USAGE
install-deno-linux.sh version ${SCRIPT_VERSION}

Usage: $0 [options]

Options:
  --version VERSION       Install a specific stable version (for example 2.9.5
                          or v2.9.5). Default: latest stable.
  --prefix PATH           Installation prefix. Default: /usr/local
                          (binary becomes PATH/bin/deno).
  --ca-bundle FILE        Additional/custom CA bundle to try after the normal
                          system trust store.
  --strict-tls            Never retry a failed HTTPS download with -k/--insecure.
  --insecure-fallback     Allow one --insecure retry after verified TLS fails
                          (default; a warning is printed).
  --force                 Reinstall even when the requested version is present.
  -h, --help              Show this help.

Environment equivalents:
  DENO_VERSION
  DENO_INSTALL_PREFIX
  DENO_CA_BUNDLE
  DENO_ALLOW_INSECURE_FALLBACK=0|1
USAGE
}

while (($#)); do
  case "$1" in
    --version)
      (($# >= 2)) || die '--version requires an argument'
      REQUESTED_VERSION="$2"; shift 2 ;;
    --prefix)
      (($# >= 2)) || die '--prefix requires an argument'
      INSTALL_PREFIX="$2"; shift 2 ;;
    --ca-bundle)
      (($# >= 2)) || die '--ca-bundle requires an argument'
      CA_BUNDLE="$2"; shift 2 ;;
    --strict-tls)
      ALLOW_INSECURE_FALLBACK=0; shift ;;
    --insecure-fallback)
      ALLOW_INSECURE_FALLBACK=1; shift ;;
    --force)
      FORCE=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      die "Unknown option: $1" ;;
  esac
done

[[ "$ALLOW_INSECURE_FALLBACK" =~ ^[01]$ ]] || \
  die 'DENO_ALLOW_INSECURE_FALLBACK must be 0 or 1'

if [[ -n "$CA_BUNDLE" ]]; then
  [[ -r "$CA_BUNDLE" ]] || die "CA bundle is not readable: $CA_BUNDLE"
fi

[[ -r /etc/os-release ]] || die '/etc/os-release is required'
# shellcheck disable=SC1091
source /etc/os-release
OS_ID="${ID:-unknown}"
OS_VERSION="${VERSION_ID:-unknown}"
OS_MAJOR="${OS_VERSION%%.*}"

case "$OS_ID:$OS_MAJOR" in
  rhel:9|rhel:10|almalinux:9|almalinux:10|debian:13) ;;
  *) die "Unsupported OS for this script: ${PRETTY_NAME:-$OS_ID $OS_VERSION}" ;;
esac

case "$(uname -m)" in
  x86_64|amd64) DENO_TARGET='x86_64-unknown-linux-gnu' ;;
  aarch64|arm64) DENO_TARGET='aarch64-unknown-linux-gnu' ;;
  *) die "Unsupported CPU architecture for the official Deno Linux binary: $(uname -m)" ;;
esac

as_root() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    die "Root privileges are required for: $*"
  fi
}

install_dependencies() {
  local missing=0
  for cmd in curl unzip sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || missing=1
  done

  # ca-certificates is not represented by a single portable command, so install
  # the small prerequisite set when any required command is missing.
  if ((missing == 0)); then
    return 0
  fi

  case "$OS_ID" in
    rhel|almalinux)
      log 'Installing required packages with dnf'
      as_root dnf -y install ca-certificates curl unzip coreutils
      ;;
    debian)
      log 'Installing required packages with apt'
      as_root env DEBIAN_FRONTEND=noninteractive apt-get update
      as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl unzip coreutils
      ;;
  esac
}

fetch() {
  local url="$1" output="$2"
  local -a base=(curl --fail --silent --show-error --location --retry 3 --retry-delay 1)

  # Preferred path: system trust store and normal certificate validation.
  if "${base[@]}" --output "$output" "$url"; then
    return 0
  fi

  # Optional second verified path for corporate/private CA environments.
  if [[ -n "$CA_BUNDLE" ]]; then
    warn "System CA validation failed for $url; retrying with CA bundle $CA_BUNDLE"
    if "${base[@]}" --cacert "$CA_BUNDLE" --output "$output" "$url"; then
      return 0
    fi
  fi

  if [[ "$ALLOW_INSECURE_FALLBACK" == 1 ]]; then
    warn "TLS validation failed for $url; retrying once with --insecure"
    "${base[@]}" --insecure --output "$output" "$url"
    return 0
  fi

  die "Unable to download with certificate validation: $url"
}

version_ge() {
  # Return success when $1 >= $2. Versions are numeric x.y.z strings.
  local a="$1" b="$2"
  local IFS=.
  local -a av bv
  read -r -a av <<<"$a"
  read -r -a bv <<<"$b"
  local i ai bi
  for i in 0 1 2; do
    ai="${av[$i]:-0}"; bi="${bv[$i]:-0}"
    ((10#$ai > 10#$bi)) && return 0
    ((10#$ai < 10#$bi)) && return 1
  done
  return 0
}

install_dependencies

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

if [[ "$REQUESTED_VERSION" == latest ]]; then
  log 'Resolving latest stable Deno release'
  fetch 'https://dl.deno.land/release-latest.txt' "$tmpdir/release-latest.txt"
  REQUESTED_VERSION="$(tr -d '[:space:]' < "$tmpdir/release-latest.txt")"
fi

REQUESTED_VERSION="${REQUESTED_VERSION#v}"
[[ "$REQUESTED_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
  die "Invalid Deno version: $REQUESTED_VERSION"
version_ge "$REQUESTED_VERSION" "$MIN_DENO_VERSION" || \
  die "Deno $REQUESTED_VERSION is too old; ddc.vim requires Deno >= $MIN_DENO_VERSION"

if command -v deno >/dev/null 2>&1 && ((FORCE == 0)); then
  current_version="$(deno --version 2>/dev/null | awk 'NR==1 {print $2}')"
  if [[ "$current_version" == "$REQUESTED_VERSION" ]]; then
    log "Deno $current_version is already installed at $(command -v deno)"
    exit 0
  fi
fi

release="v${REQUESTED_VERSION}"
asset="deno-${DENO_TARGET}.zip"
base_url="https://github.com/denoland/deno/releases/download/${release}"

log "Installing Deno ${release} for ${DENO_TARGET} on ${PRETTY_NAME:-$OS_ID}"
fetch "${base_url}/${asset}" "$tmpdir/$asset"
fetch "${base_url}/${asset}.sha256sum" "$tmpdir/${asset}.sha256sum"

log 'Verifying SHA-256 checksum'
(
  cd "$tmpdir"
  sha256sum --check "${asset}.sha256sum"
)

unzip -q "$tmpdir/$asset" -d "$tmpdir/unpacked"
[[ -f "$tmpdir/unpacked/deno" ]] || die 'Downloaded archive did not contain an executable deno binary'

install_dir="${INSTALL_PREFIX%/}/bin"
if [[ -w "$install_dir" ]] || { [[ ! -e "$install_dir" ]] && [[ -w "$(dirname "$install_dir")" ]]; }; then
  mkdir -p "$install_dir"
  install -m 0755 "$tmpdir/unpacked/deno" "$install_dir/deno"
else
  as_root mkdir -p "$install_dir"
  as_root install -m 0755 "$tmpdir/unpacked/deno" "$install_dir/deno"
fi

installed_version="$($install_dir/deno --version | awk 'NR==1 {print $2}')"
version_ge "$installed_version" "$MIN_DENO_VERSION" || \
  die "Installed Deno is unexpectedly too old: $installed_version"

log "Installed: $install_dir/deno"
"$install_dir/deno" --version

cat <<EOF2

Deno installation is complete.
For Vim/denops/ddc, verify inside Vim with:
  :echo exepath('deno')
  :KDCompletionHealth

No FUSE package or fusermount compatibility link is required by this Deno installation.
EOF2
