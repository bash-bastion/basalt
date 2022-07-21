# shellcheck shell=bash

basalt-list() {
	util.init_local

	if (($# != 0)); then
		print.warn "No arguments or flags must be specified"
	fi

	if bash_toml.quick_array_get "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'run.dependencies'; then
		for dependency in "${REPLY[@]}"; do
			util.get_package_info "$dependency"
			local url="$REPLY2" version="$REPLY5"
			printf '%s\n' "$url@$version"
		done
	fi
}
