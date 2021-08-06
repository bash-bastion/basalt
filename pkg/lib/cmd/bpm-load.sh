#!/usr/bin/env bash

# @description Source Bash packages to initialize any functions
# that they may want to provide in the global scope
# @exitcode 4 Unexpected internal error
# @exitcode 3 Problem with underlying package structure preventing proper sourcing
# @exitcode 2 Source itself failed
# @exitcode 1 Miscellaneous errors
bpm-load() {
	local __bpm_flag_global='no'
	for arg; do
		case "$arg" in
			--global|-g)
				__bpm_flag_global='yes'
				shift
				;;
		esac
	done

	local __bpm_pkg_name="${1:-}"
	local __bpm_file="${2:-}"

	if [ -z "$__bpm_pkg_name" ]; then
		printf '%s\n' "bpm-load: Error: Must pass in package name as first parameter"
		return 1
	fi

	# Functions we use from 'bpm' likely require
	# 'nullglob' and 'extglob' to function properly
	local __bpm_setNullglob= __bpm_setExtglob=
	if shopt -q nullglob; then
		__bpm_setNullglob='yes'
	else
		__bpm_setNullglob='no'
	fi

	if shopt -q extglob; then
		__bpm_setExtglob='yes'
	else
		__bpm_setExtglob='no'
	fi

	shopt -s nullglob extglob

	# Source utility file
	local __bpm_bpm_lib_dir="${BASH_SOURCE[0]%/*}"
	__bpm_bpm_lib_dir="${__bpm_bpm_lib_dir%/*}"
	# shellcheck disable=SC1091
	if ! source "$__bpm_bpm_lib_dir/util/util.sh"; then
		printf '%s\n' "bpm-load: Error: Unexpected error sourcing file '$__bpm_bpm_lib_dir/util/util.sh'"
		__bpm_bpm_load_restore_options
		return 4
	fi

	# Get package information
	if ! util.extract_data_from_input "$__bpm_pkg_name"; then
		printf '%s\n' "bpm-load: Error: Unexpected error calling function 'util.extract_data_from_input' with argument '$__bpm_pkg_name'"
		__bpm_bpm_load_restore_options
		return 4
	fi
	local __bpm_site="$REPLY2"
	local __bpm_package="$REPLY3"
	unset REPLY REPLY1 REPLY2 REPLY3 REPLY4 REPLY5 # Be extra certain of no clobbering

	# Get the bpm root dir (relative to this function's callsite)
	local __bpm_root_dir=
	if [ "$__bpm_flag_global" = yes ]; then
		__bpm_root_dir="${BPM_ROOT:-"${XDG_DATA_HOME:-$HOME/.local/share}/bpm"}/cellar"
	else
		if ! __bpm_root_dir="$(util.get_project_root_dir)/bpm_packages"; then
			printf '%s\n' "bpm-load: Error: Unexpected error calling function 'util.get_project_root_dir' with PWD '$PWD'"
			__bpm_bpm_load_restore_options
			return 4
		fi
	fi

	# Source file, behavior depending on whether it was specifed
	if [ -n "$__bpm_file" ]; then
		local __bpm_full_path="$__bpm_root_dir/packages/$__bpm_site/$__bpm_package/$__bpm_file"

		if [ -d "$__bpm_full_path" ]; then
			printf '%s\n' "bpm-load: Error: '$__bpm_full_path' is a directory"
			__bpm_bpm_load_restore_options
			return 3
		elif [ -e "$__bpm_full_path" ]; then
			# Ensure the error can be properly handled at the callsite, and not
			# bail here if errexit is set
			if ! source "$__bpm_full_path"; then
				return 2
			fi
		else
			printf '%s\n' "bpm-load: Error: '$__bpm_full_path' does not exist"
			__bpm_bpm_load_restore_options
			return 3
		fi
	else
		local __bpm_file= __bpm_file_was_sourced='no'
		# shellcheck disable=SC2041
		for __bpm_file in 'load.bash'; do
			local __bpm_full_path="$__bpm_root_dir/packages/$__bpm_site/$__bpm_package/$__bpm_file"

			if [ -f "$__bpm_full_path" ]; then
				__bpm_file_was_sourced='yes'

				# Ensure the error can be properly handled at the callsite, and not
				# bail here if errexit is set
				if ! source "$__bpm_full_path"; then
					return 2
				fi
			fi
		done

		if [ "$__bpm_file_was_sourced" = 'no' ]; then
			printf '%s\n' "bpm-load: Error: Could not automatically find package file to source"
			__bpm_bpm_load_restore_options
			return 3
		fi
	fi

	__bpm_bpm_load_restore_options
}

# @description Restore the previous options
# @noargs
__bpm_bpm_load_restore_options() {
	if [ "$__bpm_setNullglob" = 'yes' ]; then
		shopt -s nullglob
	else
		shopt -u nullglob
	fi

	if [ "$__bpm_setExtglob" = 'yes' ]; then
		shopt -s extglob
	else
		shopt -u extglob
	fi
}
