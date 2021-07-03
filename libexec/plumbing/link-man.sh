# shellcheck shell=bash

basher-_link-man() {
  source "$bin_path/basher-_util"
  util.test_mock
  source "$bin_path/subcmds/help.sh"

  package="$1"

  files=($BASHER_PACKAGES_PATH/$package/man/*)
  files=("${files[@]##*/}")

  pattern="\.([1-9])\$"

  for file in "${files[@]}"
  do
    if [[ "$file" =~ $pattern ]]; then
      n="${BASH_REMATCH[1]}"
      mkdir -p "$BASHER_INSTALL_MAN/man$n"
      ln -sf "$BASHER_PACKAGES_PATH/$package/man/$file" "$BASHER_INSTALL_MAN/man$n/$file"
    fi
  done

}
