# shellcheck shell=bash

# This function is only usable by those who executed 'basalt-package-init'

basalt.package-load() {
	local __basalt_shopt_nullglob=

	if [ -z "${BASALT_PACKAGE_PATH:-}" ]; then
		printf '%s\n' "Error: basalt.package-load: Variable 'BASALT_PACKAGE_PATH' is empty"
		return 1
	fi

	if shopt -q nullglob; then
		__basalt_shopt_nullglob='yes'
	else
		__basalt_shopt_nullglob='no'
	fi
	shopt -s nullglob

	local __basalt_site= __basalt_repository_owner=  __basalt_package=
	for __basalt_site in "$BASALT_PACKAGE_PATH"/basalt_packages/packages/*; do
		for __basalt_repository_owner in "$__basalt_site"/*; do
			for __basalt_package in "$__basalt_repository_owner"/*; do
				if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
					shopt -s nullglob
				else
					shopt -u nullglob
				fi

				basalt.load "$__basalt_package"

				shopt -s nullglob
			done
		done
	done
	unset __basalt_site

	if [ -f "$BASALT_PACKAGE_PATH/load.bash" ]; then
		# Load package (WET)
		unset basalt_load

		source "$BASALT_PACKAGE_PATH/load.bash"

		if declare -f basalt_load &>/dev/null; then
			basalt_load
			unset basalt_load
		fi
	fi

	if [ "$__basalt_shopt_nullglob" = 'yes' ]; then
		shopt -s nullglob
	else
		shopt -u nullglob
	fi
}
