# shellcheck shell=bash

# @summary: Globally installs package runtime dependencies.
# It installs the package dependencies, specified with the
# DEPS= variable on package.sh.
# Usage: basalt _deps <package>
# Example: DEPS=username/repo1:otheruser/repo2

plumbing.add-dependencies() {
	local id="$1"
	ensure.non_zero 'id' "$id"
	ensure.package_exists "$id"

	local -a deps=()

	local basalt_toml_file="$BASALT_PACKAGES_PATH/$id/basalt.toml"
	local package_sh_file="$BASALT_PACKAGES_PATH/$id/package.sh"

	# Install transitive dependencies
	local subDep="$BASALT_PACKAGES_PATH/$id"
	if [[ ! -d "$subDep" && -n "${BASALT_IS_TEST+x}" ]]; then
		# During some tests, plumbing-* or Git commands may be stubbed,
		# so the package may not actually be cloned
		return
	fi

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
		log.info "Installing dependencies for '$id'"
	fi

	for dep in "${deps[@]}"; do
		local oldWd="$PWD"
		ensure.cd "$subDep"
		util.init_command

		do-actual-add "$dep"

		ensure.cd "$oldWd"
		util.init_command
	done
}
