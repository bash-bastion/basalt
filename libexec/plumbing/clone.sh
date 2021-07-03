# shellcheck shell=bash
# Summary: Clones a package from a site, but doesn't install it
#
# Usage: basher _clone <use_ssh> <site> <package> [<ref>]

basher-_clone() {
  if [[ "$#" -ne 3 && "$#" -ne 4 ]]; then
    basher-help _clone
    exit 1
  fi

  local use_ssh="$1"
  local site="$2"
  local package="$3"
  local ref="$4"

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
