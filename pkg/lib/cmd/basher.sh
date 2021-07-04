# shellcheck shell=bash
#
# Summary: A package manager for shell scripts
#
# Usage: basher <command> [<args>]

set -ETeo pipefail
shopt -s nullglob extglob

main() {
  export BASHER_ROOT="${BASHER_ROOT:-"${XDG_DATA_HOME:-$HOME/.local/share}/neobasher"}"
  export BASHER_PREFIX="${BASHER_PREFIX:-"$BASHER_ROOT/cellar"}"
  export BASHER_PACKAGES_PATH="${BASHER_PACKAGES_PATH:-"$BASHER_PREFIX/packages"}"
  export BASHER_INSTALL_BIN="${BASHER_INSTALL_BIN:-"$BASHER_PREFIX/bin"}"
  export BASHER_INSTALL_MAN="${BASHER_INSTALL_MAN:-"$BASHER_PREFIX/man"}"

  for f in "$PROGRAM_LIB_DIR"/{commands,util}/?*.sh; do
    source "$f"
  done

  case "$1" in
  complete)
    shift
    basher-complete "$@"
    exit
    ;;
  echo)
    shift
    # TODO: move to file
    eval "echo \$$1"
    exit
    ;;
  help)
    shift
    basher-help "$@"
    exit
    ;;
  init)
    shift
    basher-init "$@"
    exit
    ;;
  install)
    basher-install "$@"
    exit
    ;;
  link)
    shift
    basher-link "$@"
    exit
    ;;
  list)
    shift
    basher-list "$@"
    exit
    ;;
  oudated)
    shift
    basher-outdated "$@"
    exit
    ;;
  package-path)
    shift
    basher-package-path "$@"
    exit
    ;;
  uninstall)
    shift
    basher-uninstall "$@"
    exit
    ;;
  upgrade)
    shift
    basher-upgrade "$@"
    exit
    ;;
  *)
    echo "basher: no command given" >&2
    basher-help
    ;;
  esac
}

main "$@"
