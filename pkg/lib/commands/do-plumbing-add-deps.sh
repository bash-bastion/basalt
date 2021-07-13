# shellcheck shell=bash

# @summary: Globally installs package runtime dependencies.
# It installs the package dependencies, specified with the
# DEPS= variable on package.sh.
# Usage: bpm _deps <package>
# Example: DEPS=username/repo1:otheruser/repo2

do-plumbing-add-deps() {
	local id="$1"
	ensure.non_zero 'id' "$id"
	ensure.package_exists "$id"

	local -a deps=()

	local bpm_toml_file="$BPM_PACKAGES_PATH/$id/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$id/package.sh"

	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
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
		do-add "$dep"
	done
}
