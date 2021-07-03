#!/usr/bin/env bash
#
# Summary: Utility functions for all subcommands

util.show_help_if_flag_passed() {
  local subcommand="$1"; shift

  local arg=
  for arg; do
    if [ "$arg" == --help ]; then
      basher-help "$subcommand"
      exit
    fi
  done
}

util.get_basher_subcommands() {
    IFS=: paths=($PATH)

    for path in "${paths[@]}"; do
      for command in "$path/basher-"*; do
        command="${command##*basher-}"
        if [[ ! "$command" == _* ]]; then
          printf "%s\n" "$command"
        fi
      done
    done

    for file in "$BASHER_ROOT/libexec"/subcmds/*; do
      file="${file##*/}"
      local command="${file%.sh}"
      printf "%s\n" "$command"
    done | sort | uniq

}

# TODO: temp
util.mock() {
  eval "$1() { echo \"$1 \$@\"; }"
}

util.test_mock() {
  if [ -n "${MOCK_GIT+x}" ]; then
    util.mock git
  fi

  if [ -n "${MOCK_BASHER_INSTALL+x}" ]; then
    util.mock basher-install
  fi

  if [ -n "${MOCK_BASHER__CLONE+x}" ]; then
    util.mock basher-_clone
  fi

  if [ -n "${MOCK_BASHER__DEPS+x}" ]; then
    util.mock basher-_deps
  fi

  if [ -n "${MOCK_BASHER__LINK_BINS+x}" ]; then
    util.mock basher-_link-bins
  fi

  if [ -n "${MOCK_BASHER__LINK_COMPLETIONS+x}" ]; then
    util.mock basher-_link-completions
  fi

  if [ -n "${MOCK_BASHER__LINK_MAN+x}" ]; then
    util.mock basher-_link-man
  fi

  if [ -n "${MOCK_BASHER__UNLINK_BINS+x}" ]; then
    util.mock basher-_unlink-bins
  fi

  if [ -n "${MOCK_BASHER__UNLINK_COMPLETIONS+x}" ]; then
    util.mock basher-_unlink-completions
  fi

  if [ -n "${MOCK_BASHER__UNLINK_MAN+x}" ]; then
    util.mock baher-_unlink_man
  fi

  if [ -n "${MOCK_GIT_2+x}" ]; then
    git() {
      if [ "$1" = "symbolic-ref" ]; then
        exit 128
      fi
    }
  fi

}
