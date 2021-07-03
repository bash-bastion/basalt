#!/usr/bin/env bash
#
# Summary: List installed packages
# Usage: basher list

basher-list() {
  util.test_mock

  util.show_help_if_flag_passed 'list' "$@"

  for package_path in "$BASHER_PACKAGES_PATH"/*/*; do
    username="${package_path%/*}"; username="${username##*/}"
    package="${package_path##*/}"
    printf "%s\n" "$username/$package"
  done
}
