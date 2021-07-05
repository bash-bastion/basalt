# shellcheck shell=bash

# @file util.sh
# @brief Utility functions for all subcommands

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

util.show_help() {
  cat <<"EOF"
Usage:
  neobasher [--help|--version] <command> [args...]

Subcommands:
  init <shell>
    Configure the shell environment for Basher

  install [--ssh] [site]/<package>[@ref]
    Installs a package from GitHub (or a custom site)

  uninstall <package>
    Uninstalls a package

  link [--no-deps] <directory> <package>
    Installs a local directory as a basher package

  list
    List installed packages

  outdated
    Displays a list of outdated packages

  package-path <package>
    Outputs the path for a package

  upgrade <package>
    Upgrades a package

  complete <command>
    Perform the completion for a particular subcommand. Used by the completion scripts

  echo <variable>
    Echo a particular internal variable. Used by the testing suite

Examples:
  neobasher install eankeen/neobasher
EOF
}
