# shellcheck shell=bash

# @file log.sh
# @brief Logging functions

# @description Logs an error and exits
# @arg $1 string Message to print
# @example
#   die 'Could not read file'
#   # Error: Could not read file. Exiting
# @exitcode 1 Exits with `1`
# @see log.error
die() {
  if [[ -n $* ]]; then
    log.error "$*. Exiting"
  else
    log.error "Exiting"
  fi

  exit 1
}

# @description Prints information in blue
# @arg $1 string Message to print
log.info() {
  if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
    printf "%s\n" "Info: $*"
  else
    printf "\033[0;34m%s\033[0m\n" "Info: $*"
  fi
}

# @description Prints warning in yellow
# @arg $1 string Message to print
log.warn() {
  if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
    printf "%s\n" "Warn: $*"
  else
    printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
  fi
}

# @description Prints error in red
# @arg $1 string Message to print
log.error() {
  if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
    printf "%s\n" "Error: $*"
  else
    printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
  fi
}
