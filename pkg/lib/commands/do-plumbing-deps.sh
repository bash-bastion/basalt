# shellcheck shell=bash

# @summary: Globally installs package runtime dependencies.
# It installs the package dependencies, specified with the
# DEPS= variable on package.sh.
# Usage: bpm _deps <package>
# Example: DEPS=username/repo1:otheruser/repo2

do-plumbing-deps() {
	local package="$1"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	local -a deps=()

	local bpm_toml_file="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"

	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
			deps=("${REPLIES[@]}")
		fi
	elif [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'DEPS'; then
			IFS=':' read -ra deps <<< "$REPLY"
		fi
	fi

	log.info "Installing dependencies for '$package'"
	for dep in "${deps[@]}"; do
		do-install "$dep"
	done
}
