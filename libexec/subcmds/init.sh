#!/usr/bin/env bash
# Summary: Configure the shell environment for basher
# Usage: eval "$(basher init -)"

basher-init() {
  set -e

  shell="$1"

  if [ -z "$shell" ]; then
    cat <<"EOF"
echo 'Please specify your shell. For example:

# bash, zsh, fish, sh
eval "$(basher init bash)"'
EOF
    exit 1
  fi

  print_fish_commands() {
    echo "set -gx BASHER_SHELL $shell"
    echo "set -gx BASHER_ROOT $BASHER_ROOT"
    echo "set -gx BASHER_PREFIX $BASHER_PREFIX"
    echo "set -gx BASHER_PACKAGES_PATH $BASHER_PACKAGES_PATH"

    echo 'if not contains $BASHER_ROOT/cellar/bin $PATH'
    echo '  set -gx PATH $BASHER_ROOT/cellar/bin $PATH'
    echo 'end'
  }

  print_sh_commands(){
    echo "export BASHER_SHELL=$shell"
    echo "export BASHER_ROOT=$BASHER_ROOT"
    echo "export BASHER_PREFIX=$BASHER_PREFIX"
    echo "export BASHER_PACKAGES_PATH=$BASHER_PACKAGES_PATH"

    echo 'if [ "${PATH#*$BASHER_ROOT/cellar/bin}" = "$PATH" ]; then'
    echo '  export PATH="$BASHER_ROOT/cellar/bin:$PATH"'
    echo 'fi'
  }

  load_bash_package_completions() {
    echo 'for f in $(command ls "$BASHER_ROOT/cellar/completions/bash"); do source "$BASHER_ROOT/cellar/completions/bash/$f"; done'
  }

  load_zsh_package_completions() {
    echo 'fpath=("$BASHER_ROOT/cellar/completions/zsh/compsys" $fpath)'
    echo 'for f in $(command ls "$BASHER_ROOT/cellar/completions/zsh/compctl"); do source "$BASHER_ROOT/cellar/completions/zsh/compctl/$f"; done'
  }

  case "$shell" in
    fish )
      print_fish_commands
      ;;
    * )
      print_sh_commands
      ;;
  esac

  if [ -e "$BASHER_ROOT/lib/include.$shell" ]; then
    echo ". \"\$BASHER_ROOT/lib/include.$shell\""
  fi

  if [ -e "$BASHER_ROOT/completions/basher.$shell" ]; then
    echo ". \"\$BASHER_ROOT/completions/basher.$shell\""
  fi

  case "$shell" in
    bash)
      load_bash_package_completions
      ;;
    zsh)
      load_zsh_package_completions
      ;;
  esac
}
