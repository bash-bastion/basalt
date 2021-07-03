# shellcheck shell=bash

basher-_unlink-man() {
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
      rm -f "$BASHER_INSTALL_MAN/man$n/$file"
    fi
  done
}
