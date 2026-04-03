#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/officecli/office-cli-skills.git}"
SKILL_NAME="${1:-office-cli}"
DEST_ROOT="${DEST_ROOT:-${HOME}/.codex/skills}"
AUTO_INSTALL_BINARY="${AUTO_INSTALL_BINARY:-1}"
DIST_REPO="${DIST_REPO:-officecli/office-cli-dist}"
HOMEBREW_TAP_REPO="${HOMEBREW_TAP_REPO:-officecli/homebrew-office-cli}"
HOMEBREW_TAP_NAME="${HOMEBREW_TAP_NAME:-officecli/office-cli}"
HOMEBREW_FORMULA="${HOMEBREW_FORMULA:-officecli/office-cli/office-cli}"
LINUX_PREFIX="${LINUX_PREFIX:-${HOME}/.local}"
LINUX_BIN_DIR="${LINUX_BIN_DIR:-${LINUX_PREFIX}/bin}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

install_skill() {
  local tmpdir src dest

  need_cmd git
  need_cmd cp
  need_cmd mkdir

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' RETURN

  git clone --depth 1 "${REPO_URL}" "${tmpdir}/repo" >/dev/null 2>&1

  src="${tmpdir}/repo/skills/${SKILL_NAME}"
  dest="${DEST_ROOT}/${SKILL_NAME}"

  if [[ ! -d "${src}" ]]; then
    echo "skill not found: ${SKILL_NAME}" >&2
    exit 1
  fi

  mkdir -p "${DEST_ROOT}"
  rm -rf "${dest}"
  cp -R "${src}" "${dest}"

  echo "installed skill to ${dest}"
}

install_binary_linux() {
  install_binary_via_dist
}

install_binary_via_dist() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "warning: curl not found, skipped office-cli binary auto-install" >&2
    return 1
  fi

  if curl -fsSL "https://raw.githubusercontent.com/${DIST_REPO}/main/scripts/install-office-cli.sh"     | PREFIX="${LINUX_PREFIX}" BIN_DIR="${LINUX_BIN_DIR}" INSTALL_DIR="${LINUX_BIN_DIR}" DIST_REPO="${DIST_REPO}" bash; then
    if [[ ":$PATH:" != *":${LINUX_BIN_DIR}:"* ]]; then
      echo "note: add ${LINUX_BIN_DIR} to PATH to use office-cli directly"
    fi
    return 0
  fi

  echo "warning: failed to auto-install office-cli binary from public dist" >&2
  return 1
}

install_binary_macos() {
  if command -v brew >/dev/null 2>&1; then
    brew untap "${HOMEBREW_TAP_NAME}" >/dev/null 2>&1 || true
    brew tap "${HOMEBREW_TAP_NAME}" >/dev/null

    local tap_repo
    tap_repo="$(brew --repository "${HOMEBREW_TAP_NAME}" 2>/dev/null || true)"
    if [[ -n "${tap_repo}" ]]; then
      rm -f "${tap_repo}/Formula/cli-office.rb"
    fi

    if brew install "${HOMEBREW_FORMULA}" >/dev/null 2>&1 || brew upgrade "${HOMEBREW_FORMULA}" >/dev/null 2>&1; then
      command -v office-cli >/dev/null 2>&1 && return 0
    fi

    echo "warning: brew install failed, falling back to direct binary install" >&2
  else
    echo "warning: Homebrew not found, falling back to direct binary install" >&2
  fi

  install_binary_via_dist
}

auto_install_binary_if_missing() {
  local os_name

  if [[ "${AUTO_INSTALL_BINARY}" != "1" ]]; then
    echo "skipped office-cli binary auto-install (AUTO_INSTALL_BINARY=${AUTO_INSTALL_BINARY})"
    return 0
  fi

  if command -v office-cli >/dev/null 2>&1; then
    echo "office-cli binary already available: $(command -v office-cli)"
    return 0
  fi

  os_name="$(uname -s)"
  case "${os_name}" in
    Linux)
      install_binary_linux || return 0
      ;;
    Darwin)
      install_binary_macos || return 0
      ;;
    *)
      echo "warning: unsupported OS for automatic office-cli install: ${os_name}" >&2
      return 0
      ;;
  esac

  if command -v office-cli >/dev/null 2>&1; then
    echo "installed office-cli binary: $(command -v office-cli)"
  else
    echo "warning: office-cli binary auto-install completed without a usable PATH entry" >&2
  fi
}

install_skill
auto_install_binary_if_missing

echo "restart Codex to pick up the new skill"
