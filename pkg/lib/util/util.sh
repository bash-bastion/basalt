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

    for file in "$BASHER_ROOT/libexec"/commands/*; do
      file="${file##*/}"
      local command="${file%.sh}"
      printf "%s\n" "$command"
    done | sort | uniq

}
