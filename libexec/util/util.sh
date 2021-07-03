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

    {
      for path in "${paths[@]}"; do
        for command in "$path/basher-"*; do
          command="${command##*basher-}"
          if [[ ! "$command" == _* ]]; then
            printf "%s\n" "$command"
          fi
        done
      done

      for file in "$bin_path"/subcmds/*; do
        file="${file##*/}"
        local command="${file%.sh}"
        printf "%s\n" "$command"
      done
    } | sort | uniq

}

# TODO: temp
util.mock() {
  eval "$1() { echo \"$1 \$@\"; }"
}

util.test_mock() {
  if [[ -v MOCK_GIT ]]; then
    util.mock git
  fi

  if [[ -v MOCK_BASHER_INSTALL ]]; then
    util.mock basher-install
  fi

  if [[ -v MOCK_BASHER__CLONE ]]; then
    util.mock basher-_clone
  fi

  if [[ -v MOCK_BASHER__DEPS ]]; then
    util.mock basher-_deps
  fi

  if [[ -v MOCK_BASHER__LINK_BINS ]]; then
    util.mock basher-_link-bins
  fi

  if [[ -v MOCK_BASHER__LINK_COMPLETIONS ]]; then
    util.mock basher-_link-completions
  fi

  if [[ -v MOCK_BASHER__LINK_MAN ]]; then
    util.mock basher-_link-man
  fi

  if [[ -v MOCK_BASHER__UNLINK_BINS ]]; then
    util.mock basher-_unlink-bins
  fi

  if [[ -v MOCK_BASHER__UNLINK_COMPLETIONS ]]; then
    util.mock basher-_unlink-completions
  fi

  if [[ -v MOCK_BASHER__UNLINK_MAN ]]; then
    util.mock baher-_unlink_man
  fi

  if [[ -v MOCK_CLONE ]]; then
    basher-_clone() {
      use_ssh="$1"
      site="$2"
      package="$3"

      git clone "$BASHER_ORIGIN_DIR/$package" "$BASHER_PACKAGES_PATH/$package"
    }
  fi
}
