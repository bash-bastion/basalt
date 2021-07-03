# shellcheck shell=bash

basher-_link-man() {
  util.test_mock

  local package="$1"

  local files=("$BASHER_PACKAGES_PATH/$package"/man/*)
  files=("${files[@]##*/}")

  local regex="\.([1-9])\$"
  for file in "${files[@]}"; do
    if [[ "$file" =~ $regex ]]; then
      n="${BASH_REMATCH[1]}"
      mkdir -p "$BASHER_INSTALL_MAN/man$n"
      ln -sf "$BASHER_PACKAGES_PATH/$package/man/$file" "$BASHER_INSTALL_MAN/man$n/$file"
    fi
  done

}
