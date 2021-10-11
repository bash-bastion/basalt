# shellcheck shell=bash

# @file basalt-global.sh
# @brief Contains functions to be used anywhere (shell initialization, Basalt
# packages, etc.)

basalt.load() {
	local __basalt_flag_global='no'
	local __basalt_flag_dry='no'

	for arg; do case "$arg" in
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
		Usage:
		  basalt.load [flags] <package> <file>

		Flags:
		  --global  Use global packages rather than local packages
		  --dry     Only print what would have been sourced
		  --help    Print help

		Example:
		  basalt.load --global 'github.com/rupa/z' 'z.sh'
		  basalt.load --dry 'github.com/hyperupcall/bats-common-utils' 'load.bash'
		  basalt.load 'github.com/bats-core/bats-assert' 'load.bash'
		EOF
		return
		;;
	-*)
		printf '%s\n' "Error: basalt.load: Flag '$arg' not recognized"
		return 1
		;;
	esac done

	local __basalt_pkg_path="${1:-}"
	local __basalt_file="${2:-}"

	if [ -z "$__basalt_pkg_path" ]; then
		printf '%s\n' "Error: basalt.load: Missing package as first parameter"
		return 1
	fi

	local __basalt_is_nullglob=
	if shopt -q nullglob; then
		__basalt_is_nullglob='yes'
	else
		__basalt_is_nullglob='no'
	fi
	shopt -s nullglob

	local -a __basalt_pkg_path_full_array=()
	if [ "$__basalt_flag_global" = 'yes' ]; then
		__basalt_pkg_path_full_array=("$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/$__basalt_pkg_path@"*)
	else
		__basalt_pkg_path_full_array=("$BASALT_PACKAGE_DIR/.basalt/packages/$__basalt_pkg_path@"*)
	fi

	if ((${#__basalt_pkg_path_full_array[@]} > 1)); then
		printf '%s\n' "Error: basalt.load: Multiple versions of the package '$__basalt_pkg_path' exists"
		return 1
	fi

	if [ "$__basalt_is_nullglob" = 'yes' ]; then
		shopt -s nullglob
	else
		shopt -u nullglob
	fi

	local __basalt_pkg_path_full="${__basalt_pkg_path_full_array[0]}"

	if [ -z "$__basalt_pkg_path_full" ] || [ ! -d "$__basalt_pkg_path_full" ]; then
		local __basalt_str='locally'
		if [ "$__basalt_flag_global" = 'yes' ]; then
			__basalt_str="globally"
		fi
		printf '%s\n' "Error: basalt.load: Package '$__basalt_pkg_path' is not installed $__basalt_str"

		return 1
	fi

	if [ ! -f "$__basalt_pkg_path_full/$__basalt_file" ]; then
		printf '%s\n' "Error: basalt.load: File '$__basalt_file' not found in package '$__basalt_pkg_path'"
		return 1
	fi

	if [ "$__basalt_flag_dry" = 'yes' ]; then
		printf '%s\n' "Would have sourced file '$__basalt_pkg_path_full/$__basalt_file'"
	else
		if source "$__basalt_pkg_path_full/$__basalt_file"; then
			:
		else
			return $?
		fi
	fi
}
