# shellcheck shell=bash

basher-_unlink-bins() {
  util.test_mock

  local package="$1"

  local bins
  if [ -e "$BASHER_PACKAGES_PATH/$package/package.sh" ]; then
    source "$BASHER_PACKAGES_PATH/$package/package.sh"
    IFS=: read -ra bins <<< "$BINS"
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

  for bin in "${bins[@]}"; do
    local name="${bin##*/}"
    if ${REMOVE_EXTENSION:-false}; then
      name="${name%%.*}"
    fi
    rm -f "$BASHER_INSTALL_BIN/$name"
  done
}
