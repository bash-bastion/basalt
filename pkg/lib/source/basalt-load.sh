#!/usr/bin/env bash

# @description Source Bash packages to initialize any functions
# that they may want to provide in the global scope
# @exitcode 4 Unexpected internal error
# @exitcode 3 Problem with underlying package structure preventing proper sourcing
# @exitcode 2 Source itself failed
# @exitcode 1 Miscellaneous errors
basalt-load() {
	local __basalt_flag_global='no'
	local __basalt_flag_dry='no'

	for arg; do
		case "$arg" in
			--global|-g)
				__basalt_flag_global='yes'
				shift
				;;
			--dry)
				__basalt_flag_dry='yes'
				shift
				;;
			--help|-h)
				cat <<-"EOF"
				basalt-load

				Usage:
				  basalt-load <flags> <package> [file]

				Flags:
				  --global
				    Use packages installed globally, rather than local packages

				  --dry
				    Only print what would have been sourced

				  --help
				    Print help menu

				Example:
				  basalt-load --global 'github.com/rupa/z' 'z.sh'
				EOF
				return
				;;
			-*)
				printf '%s\n' "basalt-load: Error: Flag '$arg' not recognized"
				return 1
				;;
		esac
	done

	local __basalt_pkg_name="${1:-}"
	local __basalt_file="${2:-}"

	if [ -z "$__basalt_pkg_name" ]; then
		printf '%s\n' "basalt-load: Error: Must pass in package name as first parameter"
		return 1
	fi

	# Functions we use from 'basalt' likely require
	# 'nullglob' and 'extglob' to function properly
	local __basalt_setNullglob= __basalt_setExtglob=
	if shopt -q nullglob; then
		__basalt_setNullglob='yes'
	else
		__basalt_setNullglob='no'
	fi

	if shopt -q extglob; then
		__basalt_setExtglob='yes'
	else
		__basalt_setExtglob='no'
	fi

	shopt -s nullglob extglob

	# Source utility file
	local __basalt_basalt_lib_dir="${BASH_SOURCE[0]%/*}"
	__basalt_basalt_lib_dir="${__basalt_basalt_lib_dir%/*}"
	# shellcheck disable=SC1091
	if ! source "$__basalt_basalt_lib_dir/util/util.sh"; then
		printf '%s\n' "basalt-load: Error: Unexpected error sourcing file '$__basalt_basalt_lib_dir/util/util.sh'"
		__basalt_basalt_load_restore_options
		return 4
	fi

	# Get package information
	if ! util.extract_data_from_input "$__basalt_pkg_name"; then
		printf '%s\n' "basalt-load: Error: Unexpected error calling function 'util.extract_data_from_input' with argument '$__basalt_pkg_name'"
		__basalt_basalt_load_restore_options
		return 4
	fi
	local __basalt_site="$REPLY2"
	local __basalt_package="$REPLY3"
	unset REPLY REPLY1 REPLY2 REPLY3 REPLY4 REPLY5 # Be extra certain of no clobbering

	# Get the basalt root dir (relative to this function's callsite)
	local __basalt_cellar=
	if [ "$__basalt_flag_global" = yes ]; then
		__basalt_cellar="${BASALT_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/cellar"}"
	else
		if ! __basalt_cellar="$(util.get_project_root_dir)/basalt_packages"; then
			printf '%s\n' "basalt-load: Error: Unexpected error calling function 'util.get_project_root_dir' with \$PWD '$PWD'"
			__basalt_basalt_load_restore_options
			return 4
		fi
	fi

	# Ensure package is actually installed
	if [ ! -d "$__basalt_cellar/packages/$__basalt_site/$__basalt_package" ]; then
		printf '%s\n' "basalt-load: Error: Package '$__basalt_site/$__basalt_package' is not installed. Does the '--global' flag apply?"
		__basalt_basalt_load_restore_options
		return 3
	fi

	# Source file, behavior depending on whether it was specifed
	if [ -n "$__basalt_file" ]; then
		local __basalt_full_path="$__basalt_cellar/packages/$__basalt_site/$__basalt_package/$__basalt_file"

		if [ -d "$__basalt_full_path" ]; then
			printf '%s\n' "basalt-load: Error: '$__basalt_full_path' is a directory"
			__basalt_basalt_load_restore_options
			return 3
		elif [ -e "$__basalt_full_path" ]; then
			if [ "$__basalt_flag_dry" = yes ]; then
				printf '%s\n' "basalt-load: Would source file '$__basalt_full_path'"
				__basalt_basalt_load_restore_options
				return
			else
				# Ensure the error can be properly handled at the callsite, and not
				# bail here if errexit is set
				if ! source "$__basalt_full_path"; then
					__basalt_basalt_load_restore_options
					return 2
				fi
			fi
		else
			printf '%s\n' "basalt-load: Error: File '$__basalt_full_path' does not exist"
			__basalt_basalt_load_restore_options
			return 3
		fi
	else
		local __basalt_file= __basalt_file_was_sourced='no'
		# shellcheck disable=SC2041
		for __basalt_file in 'load.bash'; do
			local __basalt_full_path="$__basalt_cellar/packages/$__basalt_site/$__basalt_package/$__basalt_file"

			if [ -f "$__basalt_full_path" ]; then
				__basalt_file_was_sourced='yes'

				if [ "$__basalt_flag_dry" = yes ]; then
					printf '%s\n' "basalt-load: Would source file '$__basalt_full_path'"
					__basalt_basalt_load_restore_options
					return
				else
					# Ensure the error can be properly handled at the callsite, and not
					# bail here if errexit is set
					if ! source "$__basalt_full_path"; then
						__basalt_basalt_load_restore_options
						return 2
					fi
				fi
			fi
		done

		if [ "$__basalt_file_was_sourced" = 'no' ]; then
			printf '%s\n' "basalt-load: Error: Could not automatically find package file to source. Did you mean to pass the file to source as the second argument?"
			__basalt_basalt_load_restore_options
			return 3
		fi
	fi

	__basalt_basalt_load_restore_options
}

# @description Restore the previous options
# @noargs
__basalt_basalt_load_restore_options() {
	if [ "$__basalt_setNullglob" = 'yes' ]; then
		shopt -s nullglob
	else
		shopt -u nullglob
	fi

	if [ "$__basalt_setExtglob" = 'yes' ]; then
		shopt -s extglob
	else
		shopt -u extglob
	fi
}

# @description Internal functions might call 'die', so this prevents 'bash: die: command not found' errors,
# but still allows the error to be exposed at the callsite
die() {
	return 1
}
