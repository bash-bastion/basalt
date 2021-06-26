#!/usr/bin/env bash
# Summary: Perform a completion for a particular comment
# Usage: basher complete <command>

set -e
source basher-_util

basher-complete() {
  case "$1" in
    help)
      util.get_basher_subcommands
      ;;
    package-path)
      basher-list
      ;;
    basher-uninstall)
      basher-list
      ;;
    basher-upgrade)
      basher-list
      ;;
  esac
}
