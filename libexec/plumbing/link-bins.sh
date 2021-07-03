# shellcheck shell=bash

basher-_link-bins() {
  util.test_mock

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
      bins=($(find "$BASHER_PACKAGES_PATH/$package" -maxdepth 1 -mindepth 1 -perm -u+x -type f -or -type l))
      bins=("${bins[@]##*/}")
    fi
  fi

  for bin in "${bins[@]}"
  do
    name="${bin##*/}"
    if ${REMOVE_EXTENSION:-false}; then
      name="${name%%.*}"
    fi
    mkdir -p "$BASHER_INSTALL_BIN"
    # echo ls -al /tmp/basher/prefix/bin >&3
    # echo ln -sf "$BASHER_PACKAGES_PATH/$package/$bin" "$BASHER_INSTALL_BIN/$name" >&3
    ln -sf "$BASHER_PACKAGES_PATH/$package/$bin" "$BASHER_INSTALL_BIN/$name"
    chmod +x "$BASHER_INSTALL_BIN/$name"
  done

}
