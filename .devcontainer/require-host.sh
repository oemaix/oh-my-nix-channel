#!/bin/sh
# Host-side initializeCommand. NixOS only. Writes .devcontainer/host-user.
set -eu
script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
root=${DEVCONTAINER_CHECK_ROOT:-}

die() {
  echo "$*" >&2
  exit 1
}

host_path() {
  printf '%s%s' "$root" "$1"
}

[ -x "$(host_path /run/current-system/sw/bin/nix)" ] \
  || die "This devcontainer requires a NixOS host. /run/current-system/sw/bin/nix is missing."

printf '%s\n' "$(id -un)" > "${DEVCONTAINER_HOST_USER_FILE:-$script_dir/host-user}"
