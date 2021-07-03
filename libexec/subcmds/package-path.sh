#!/usr/bin/env bash
#
# Summary: Outputs the path for a package
# Usage: source "$(basher package-path <package>)/file.sh"

basher-package-path() {
  util.test_mock

  if [ "$#" -ne 1 ]; then
    basher-help package-path
    exit 1
  fi

  local package="$1"

  echo "$BASHER_PACKAGES_PATH/$package"
}
