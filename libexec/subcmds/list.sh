#!/usr/bin/env bash
#
# Summary: List installed packages
# Usage: basher list

source basher-_util

basher-list() {
  util.show_help_if_flag_passed 'list' "$@"

  for package_path in "$BASHER_PACKAGES_PATH"/*/*; do
    username="${package_path%/*}"; username="${username##*/}"
    package="${package_path##*/}"
    printf "%s\n" "$username/$package"
  done
}
