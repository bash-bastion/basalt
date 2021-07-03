# shellcheck shell=bash

basher-_unlink-completions() {
  source "$bin_path/basher-_util"
  util.test_mock
  source "$bin_path/subcmds/help.sh"

  package="$1"

  if [ ! -e "$BASHER_PACKAGES_PATH/$package/package.sh" ]; then
    exit
  fi

  source "$BASHER_PACKAGES_PATH/$package/package.sh" # TODO: make this secure?
  IFS=: read -a bash_completions <<< "$BASH_COMPLETIONS"
  IFS=: read -a zsh_completions <<< "$ZSH_COMPLETIONS"

  for completion in "${bash_completions[@]}"
  do
    rm -f "$BASHER_PREFIX/completions/bash/${completion##*/}"
  done

  for completion in "${zsh_completions[@]}"
  do
    target="$BASHER_PACKAGES_PATH/$package/$completion"
    if grep -q "#compdef" "$target"; then
      rm -f "$BASHER_PREFIX/completions/zsh/compsys/${completion##*/}"
    else
      rm -f "$BASHER_PREFIX/completions/zsh/compctl/${completion##*/}"
    fi
  done
}
