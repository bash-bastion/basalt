# shellcheck shell=bash

do-plumbing-remove-deps() {
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

	# TODO: bug: this removes dependencies specified with incorrect URLs
	log.info "Removing dependencies for '$package'"
	for dep in "${deps[@]}"; do
		util.construct_clone_url "$repoSpec" "$with_ssh"
		local uri="$REPLY1"
		local site="$REPY2"
		local package="$REPLY3"
		local ref="$REPLY4"

		rm -rf "${BPM_PACKAGES_PATH:?}/$package"
	done
}
