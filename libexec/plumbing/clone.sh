# shellcheck shell=bash

basher-_clone() {
  # Summary: Clones a package from a site, but doesn't install it
  #
  # Usage: basher _clone <use_ssh> <site> <package> [<ref>]

  source "$bin_path/subcmds/help.sh"
  util.test_mock

  if [ "$#" -ne 3 -a "$#" -ne 4 ]; then
    basher-help _clone
    exit 1
  fi

  use_ssh="$1"
  site="$2"
  package="$3"
  ref="$4"

  if [ -z "$use_ssh" ]; then
    basher-help _clone
    exit 1
  fi

  if [ -z "$site" ]; then
    basher-help _clone
    exit 1
  fi

  if [ -z "$package" ]; then
    basher-help _clone
    exit 1
  fi

  if [ -z "$ref" ]; then
    BRANCH_OPTION=""
  else
    BRANCH_OPTION="-b $ref"
  fi

  IFS=/ read -r user name <<< "$package"

  if [ -z "$user" ]; then
    basher-help _clone
    exit 1
  fi

  if [ -z "$name" ]; then
    basher-help _clone
    exit 1
  fi

  if [ -e "$BASHER_PACKAGES_PATH/$package" ]; then
    echo "Package '$package' is already present"
    exit 0
  fi

  if [ "$BASHER_FULL_CLONE" = "true" ]; then
    DEPTH_OPTION=""
  else
    DEPTH_OPTION="--depth=1"
  fi

  if [ "$use_ssh" = "true" ]; then
    URI="git@$site:$package.git"
  else
    URI="https://$site/$package.git"
  fi

  git clone $DEPTH_OPTION $BRANCH_OPTION --recursive "$URI" "$BASHER_PACKAGES_PATH/$package"
}
