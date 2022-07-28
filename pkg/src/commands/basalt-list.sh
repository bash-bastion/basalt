# shellcheck shell=bash

basalt-list() {
	util.init_local

	if (($# != 0)); then
		print.warn "No arguments or flags must be specified"
	fi

	if bash_toml.quick_array_get "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'run.dependencies'; then
		for dependency in "${REPLY[@]}"; do
			pkgutil.get_allinfo "$dependency"
			local _pkg_fqlocation="$REPLY4"
			local _pkg_version="$REPLY8"

			printf '%s\n' "$_pkg_fqlocation${_pkg_version:+@$_pkg_version}"
		done
	fi
}
