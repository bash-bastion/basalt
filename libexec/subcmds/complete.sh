# Usage: basher complete <command>
# Summary: Perform a completion for a particular comment
#

basher-complete() {
  util.test_mock

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
