# shellcheck shell=bash

basher-_unlink-bins() {
  source "$bin_path/basher-_util"
  util.test_mock
  source "$bin_path/subcmds/help.sh"

  package="$1"

  if [ -e "$BASHER_PACKAGES_PATH/$package/package.sh" ]; then
    source "$BASHER_PACKAGES_PATH/$package/package.sh"
    IFS=: read -a bins <<< "$BINS"
  fi

  if [ -z "$bins" ]; then
    if [ -e "$BASHER_PACKAGES_PATH/$package/bin" ]; then
      bins=($BASHER_PACKAGES_PATH/$package/bin/*)
      bins=("${bins[@]##*/}")
      bins=("${bins[@]/#/bin/}")
    else
      bins=($(find "$BASHER_PACKAGES_PATH/$package" -maxdepth 1 -perm -u+x -type f -or -type l))
      bins=("${bins[@]##*/}")
    fi
  fi

  for bin in "${bins[@]}"
  do
    name="${bin##*/}"
    if ${REMOVE_EXTENSION:-false}; then
      name="${name%%.*}"
    fi
    rm -f "$BASHER_INSTALL_BIN/$name"
  done
}
