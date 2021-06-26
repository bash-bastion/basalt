#!/usr/bin/env bash
#
# Summary: Installs a package from github (or a custom site)
#
# Usage: basher install [--ssh] [site]/<package>[@ref]

basher-install() {
  use_ssh="false"

  case $1 in
    --ssh)
      use_ssh="true"
      shift
    ;;
  esac

  if [ "$#" -ne 1 ]; then
    basher-_launch help install
    exit 1
  fi

  if [[ "$1" = */*/* ]]; then
    IFS=/ read -r site user name <<< "$1"
    package="$user/$name"
  else
    package="$1"
    site="github.com"
  fi

  if [ -z "$package" ]; then
    basher-_launch help install
    exit 1
  fi

  IFS=/ read -r user name <<< "$package"

  if [ -z "$user" ]; then
    basher-_launch help install
    exit 1
  fi

  if [ -z "$name" ]; then
    basher-_launch help install
    exit 1
  fi

  if [[ "$package" = */*@* ]]; then
    IFS=@ read -r package ref <<< "$package"
  else
    ref=""
  fi

  if [ -z "$ref" ]; then
    basher-_clone "$use_ssh" "$site" "$package"
  else
    basher-_clone "$use_ssh" "$site" "$package" "$ref"
  fi
  basher-_deps "$package"
  basher-_link-bins "$package"
  basher-_link-man "$package"
  basher-_link-completions "$package"
}
