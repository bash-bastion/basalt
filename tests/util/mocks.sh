# shellcheck shell=bash

# @description This mocks a command by creating a function for it, which
# prints all the arguments to the command, in addition to the command name
mock.command() {
  case "$1" in
  _clone)
    basher-plumbing-clone() {
      local use_ssh="$1"
      local site="$2"
      local package="$3"

      git clone "$BASHER_ORIGIN_DIR/$package" "$BASHER_PACKAGES_PATH/$package"
    }
    ;;
  *)
    eval "$1() { echo \"$1 \$*\"; }"
    ;;
  esac
}
