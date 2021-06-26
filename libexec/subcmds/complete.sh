# Usage: basher complete <command>
# Summary: Perform a completion for a particular comment
#

basher-complete() {
  case "$1" in
    help)
      util.get_basher_subcommands
      ;;
    package-path)
      basher-_launch list
      ;;
    basher-uninstall)
      basher-_launch list
      ;;
    basher-upgrade)
      basher-_launch list
      ;;
  esac
}
