# shellcheck shell=bash

plumbing.remove-dependencies() {
	local package="$1"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	local -a deps=()

	local basalt_toml_file="$BASALT_PACKAGES_PATH/$package/basalt.toml"
	local package_sh_file="$BASALT_PACKAGES_PATH/$package/package.sh"

	if [ -f "$basalt_toml_file" ]; then
		if util.get_toml_array "$basalt_toml_file" 'dependencies'; then
			deps=("${REPLIES[@]}")
		fi
	elif [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'DEPS'; then
			IFS=':' read -ra deps <<< "$REPLY"
		fi
	fi

	if (( ${#deps[@]} > 0 )); then
		log.info "Removing dependencies for '$package'"
	fi

	for dep in "${deps[@]}"; do
		util.extract_data_from_input "$dep"
		local site="$REPLY2"
		local pkg="$REPLY3"

		log.info "Removing '$site/$pkg'"
		rm -rf "${BASALT_PACKAGES_PATH:?}/$site/$pkg"
	done
}