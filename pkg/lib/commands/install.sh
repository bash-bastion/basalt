# shellcheck shell=bash

basher-install() {
	local use_ssh="false"

	case "$1" in
		--ssh)
			use_ssh="true"
			shift
		;;
	esac

	if [ "$#" -ne 1 ]; then
		die "Must supply repository"
	fi

	if [[ "$1" = */*/* ]]; then
		IFS=/ read -r site user name <<< "$1"
		package="$user/$name"
	else
		package="$1"
		site="github.com"
	fi

	if [ -z "$package" ]; then
		die "Package must be nonZero"
	fi

	IFS=/ read -r user name <<< "$package"

	if [ -z "$user" ]; then
		die "User must be nonZero"
	fi

	if [ -z "$name" ]; then
		die "Name must be nonZero"
	fi

	if [[ "$package" = */*@* ]]; then
		IFS=@ read -r package ref <<< "$package"
	else
		ref=""
	fi

	if [ -z "$ref" ]; then
		basher-plumbing-clone "$use_ssh" "$site" "$package"
	else
		basher-plumbing-clone "$use_ssh" "$site" "$package" "$ref"
	fi

	basher-plumbing-deps "$package"
	basher-plumbing-link-bins "$package"
	basher-plumbing-link-completions "$package"
	basher-plumbing-link-completions "$package"
}
