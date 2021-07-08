# shellcheck shell=bash

# @summary: Globally installs package runtime dependencies.
# It installs the package dependencies, specified with the
# DEPS= variable on package.sh.
# Usage: bpm _deps <package>
# Example: DEPS=username/repo1:otheruser/repo2

do-plumbing-deps() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	local -a deps=()

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"

	if [ -f  "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'dependencies'; then
			deps=("${REPLIES[@]}")
		fi
	elif [ -f "$packageShFile" ]; then
		util.extract_shell_variable "$packageShFile" 'DEPS'
		IFS=':' read -ra deps <<< "$REPLY"
	fi

	log.info "Installing dependencies for '$package'"
	for dep in "${deps[@]}"; do
		do-install "$dep"
	done
}
