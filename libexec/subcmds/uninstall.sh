#!/usr/bin/env bash
# Summary: Uninstalls a package
# Usage: basher uninstall <package>

basher-uninstall() {
  if [ "$#" -ne 1 ]; then
    basher-help uninstall
    exit 1
  fi

  package="$1"

  if [ -z "$package" ]; then
    basher-help uninstall
    exit 1
  fi

  IFS=/ read -r user name <<< "$package"

  if [ -z "$user" ]; then
    basher-help uninstall
    exit 1
  fi

  if [ -z "$name" ]; then
    basher-help uninstall
    exit 1
  fi

  if [ ! -d "$BASHER_PACKAGES_PATH/$package" ]; then
    echo "Package '$package' is not installed"
    exit 1
  fi

  basher-_unlink-man "$package"
  basher-_unlink-bins "$package"
  basher-_unlink-completions "$package"

  rm -rf "$BASHER_PACKAGES_PATH/$package"
}
