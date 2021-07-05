# shellcheck shell=bash

# @summary: Globally installs package runtime dependencies.
# It installs the package dependencies, specified with the
# DEPS= variable on package.sh.
# Usage: basher _deps <package>
# Example: DEPS=username/repo1:otheruser/repo2

basher-plumbing-deps() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	local -a deps=()
	if [ -f "$BPM_PACKAGES_PATH/$package/package.sh" ]; then
		util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'DEPS'
		IFS=':' read -ra deps <<< "$REPLY"
	elif [ -f "$BPM_PACKAGES_PATH/$package/bpm.toml" ]; then
		util.get_toml_array 'deps' "$BPM_PACKAGES_PATH/$package/bpm.toml"
		deps=("${REPLIES[@]}")
	fi

	for dep in "${deps[@]}"; do
		basher-install "$dep"
	done
}
