# shellcheck shell=bash

# When running 'eval "$(basalt-package-init)"', this file is
# cat'd. It can only use functions from 'pkg/src/util/init.sh'

basalt.package-init() {
	if [ -z "$BASALT_GLOBAL_REPO" ]; then
		printf '%s\n' "Error: basalt: Variable '\$BASALT_GLOBAL_REPO' is empty" >&2
		exit 1
	fi

	if [ ! -f "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh" ]; then
		printf '%s\n' "Error: basalt: Failed to find file 'basalt-global.sh' in '\$BASALT_GLOBAL_REPO'" >&2
		exit 1
	fi
	# shellcheck source=../../../pkg/src/public/basalt-global.sh
	source "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh"

	if [ ! -f "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh" ]; then
		printf '%s\n' "Error: basalt: Failed to find file 'basalt-package.sh' in '\$BASALT_GLOBAL_REPO'" >&2
		exit 1
	fi
	# shellcheck source=../../../pkg/src/public/basalt-package.sh
	source "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh"

	if [ -z "${BASALT_PACKAGE_DIR:-}" ]; then
		local __old_cd="$PWD"

		# Do not use "$0", since it won't work in some environments, such as Bats
		local __basalt_file="${BASH_SOURCE[1]}"
		if [ -L "$__basalt_file" ]; then
			local __basalt_target=
			__basalt_target=$(readlink "$__basalt_file")
			if ! cd "${__basalt_target%/*}"; then
				printf '%s\n' "Error: basalt: Could not cd to '${__basalt_target%/*}'" >&2
				exit 1
			fi
		else
			if ! cd "${__basalt_file%/*}"; then
				printf '%s\n' "Error: basalt: Could not cd to '${__basalt_file%/*}'" >&2
				exit 1
			fi
		fi

		init.get_basalt_package_dir
		# Note that this variable should not be exported. It can cause weird things to occur. For example,
		# if a Basalt local package called a command from a global package, things won't work since
		# 'BASALT_PACKAGE_DIR' would already be defined and won't be properly set for the global package
		BASALT_PACKAGE_DIR=$REPLY

		if ! cd "$__old_cd"; then
			printf '%s\n' "Error: basalt: Could not cd back to '$__old_cd'" >&2
			exit 1
		fi
	fi
}

if [ "$BASALT_INTERNAL_NEWINIT" = 'no' ]; then
	# The old-style way of initing with no arguments
	# Expect the developer to call setup functions manually

	# #!/usr/bin/env bash
	#
	# eval "$(basalt-package-init)"
	# basalt.package-init || exit
	# basalt.package-load
	#
	# source "$BASALT_PACKAGE_DIR/pkg/src/bin/woof.sh"
	# main.woof "$@"

	if ! init.assert_bash_version; then
		printf '%s\n' 'Fatal: main.basalt-package-init: Basalt requires at least Bash version 4.3' >&2
		printf '%s\n' 'exit 1'
		exit 1
	fi

	# Since things are done manually, the user calls basalt.package-init, etc. and things work
else
	# The new-style way of initing with arguments
	# Everything is handled automatically

	# #!/usr/bin/env bash
	#
	# eval "$(basalt-package-init 'woof')"
	# __run "$@"

	# TODO: Handle this in a better way
	readlinkf_posix() {
		[ "${1:-}" ] || return 1
		max_symlinks=40
		CDPATH='' # to avoid changing to an unexpected directory

		target=$1
		[ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
		[ -d "${target:-/}" ] && target="$target/"

		cd -P . 2>/dev/null || return 1
		while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
			if [ ! "$target" = "${target%/*}" ]; then
			case $target in
				/*) cd -P "${target%/*}/" 2>/dev/null || break ;;
				*) cd -P "./${target%/*}" 2>/dev/null || break ;;
			esac
			target=${target##*/}
			fi

			if [ ! -L "$target" ]; then
			target="${PWD%/}${target:+/}${target}"
			printf '%s\n' "${target:-/}"
			return 0
			fi

			link=$(ls -dl -- "$target" 2>/dev/null) || break
			target=${link#*" $target -> "}
		done
		return 1
	}

	__run() {
		if [ "${BASALT_INTERNAL_ARGS[0]}" = '--no-assert-version' ]; then
			__flag_assert_version='no'
			__bin_name="${BASALT_INTERNAL_ARGS[1]}"
		else
			__flag_assert_version='yes'
			__bin_name="${BASALT_INTERNAL_ARGS[0]}"
		fi

		if [ -z "$__bin_name" ]; then
			printf '%s\n' 'Fatal: main.basalt-package-init: Passed binary name cannot be empty' >&2
			exit 1
		fi

		__have_min_version='no'
		if init.assert_bash_version; then
			__have_min_version='yes'
		fi

		if [ "$__have_min_version" = 'no' ] && [ "$__flag_assert_version" = 'yes' ]; then
			printf '%s\n' 'Fatal: main.basalt-package-init: Basalt requires at least Bash version 4.3' >&2
			exit 1
		fi
		unset -v __flag_assert_version

		__zero="$(readlinkf_posix "$0")"
		init.get_basalt_package_dir "${__zero%/*}"
		BASALT_PACKAGE_DIR=$REPLY
		unset -v __zero

		__bin_file="$BASALT_PACKAGE_DIR/pkg/src/bin/$__bin_name.sh"
		if [ ! -f "$__bin_file" ]; then
			printf '%s\n' "Fatal: main.basalt-package-init: No file found at: $__bin_file" >&2
			exit 1
		fi
		source "$__bin_file"
		unset -v __bin_file

		if ! declare -f "main.$__bin_name" &>/dev/null; then
			printf '%s\n' "Fatal: main.basalt-package-init: Failed to find declared function: main.$__bin_name" >&2
			exit 1
		fi

		"main.$__bin_name" "$@"
	}
fi
