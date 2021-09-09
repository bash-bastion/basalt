# shellcheck shell=bash

basalt-load() {
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
	# TODO: help menu
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
	esac done

	local __basalt_pkg_path="${1:-}"
	local __basalt_file="${2:-}"

	if [ -z "$__basalt_pkg_path" ]; then
		printf '%s\n' "basalt-load: Error: Must pass in package path as first parameter"
		return 1
	fi

	if [ "$__basalt_flag_global" = yes ]; then
		# TODO
		:
	else
		__basalt_load_local_project_root_dir=
		if ! __basalt_load_local_project_root_dir="$(
			while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
				cd ..
			done

			if [ "$PWD" = / ]; then
				return 1
			fi

			printf "%s" "$PWD"
		)"; then
			printf '%s\n' "basalt-load: Error: Could not find a basalt.toml file"
			return 1
		fi

		# Assume can only have one version of a particular package for direct dependencies
		__basalt_load_package_exists='no'
		for __basalt_actual_pkg_path in "$__basalt_load_local_project_root_dir/basalt_packages/packages/$__basalt_pkg_path"*; do
			if [ "$__basalt_load_package_exists" = yes ]; then
				printf '%s\n' "basalt-load: Error: Found a direct dependency installed as more than one version"
				return 1
			else
				__basalt_load_package_exists='yes'
			fi

			__basalt_did_source='no'
			if [ -n "$__basalt_file" ]; then
				if [ -f "$__basalt_actual_pkg_path/$__basalt_file" ]; then
					. "$__basalt_actual_pkg_path/$__basalt_file"
					__basalt_did_source='yes'
				else
					printf '%s\n' "basalt-load: Error: File '$__basalt_file' not found for package '$__basalt_pkg_path'"
					return 1
				fi
			elif [ -f "$__basalt_actual_pkg_path/load.bash" ]; then
				. "$__basalt_actual_pkg_path/load.bash"
				__basalt_did_source='yes'
			elif [ -f "$__basalt_actual_pkg_path/load.sh" ]; then
				. "$__basalt_actual_pkg_path/load.sh"
				__basalt_did_source='yes'
			fi

			if [ "$__basalt_did_source" = no ]; then
				printf '%s\n' "basalt-load: Error: Nothing was sourced when calling 'basalt-load $*'"
				return
			fi
		done
		unset __basalt_actual_pkg_path

		unset __basalt_flag_global __basalt_flag_dry __basalt_pkg_path __basalt_file __basalt_load_local_project_root_dir __basalt_did_source
	fi
}
