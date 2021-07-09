# shellcheck shell=bash

do-plumbing-link-completions() {
	local package="$1"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	log.info "Linking completion files for '$package'"

	local -a bash_completion_files=() zsh_completion_files=()

	local bpm_toml_file="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"

	# Get completion directories
	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_array "$bpm_toml_file" 'completionDirs'; then
			local -a newCompletions=()

			for dir in "${REPLIES[@]}"; do
				newCompletions+=("$BPM_PACKAGES_PATH/$package/$dir"/*)
				newCompletions=("${newCompletions[@]/#"$BPM_PACKAGES_PATH/$package/"}")
			done

			bash_completion_files+=("${newCompletions[@]}")
			zsh_completion_files+=("${newCompletions[@]}")
		else
			auto_collect_completion_files "$package"
			REPLIES1=("${REPLIES1[@]/#/"$BPM_PACKAGES_PATH/$package/"}")
			REPLIES2=("${REPLIES2[@]/#/"$BPM_PACKAGES_PATH/$package/"}")

			bash_completion_files+=("${REPLIES1[@]}")
			zsh_completion_files+=("${REPLIES2[@]}")
		fi
	elif [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'BASH_COMPLETIONS'; then
			IFS=':' read -ra bash_completion_files <<< "$REPLY"
		else
			auto_collect_completion_files "$package"
			bash_completion_files+=("${REPLIES1[@]}")
		fi

		if util.extract_shell_variable "$package_sh_file" 'ZSH_COMPLETIONS'; then
			IFS=':' read -ra zsh_completion_files <<< "$REPLY"
		else
			auto_collect_completion_files "$package"
			zsh_completion_files+=("${REPLIES2[@]}")
		fi
	else
		auto_collect_completion_files "$package"
		REPLIES1=("${REPLIES1[@]/#/"$BPM_PACKAGES_PATH/$package/"}")
		REPLIES2=("${REPLIES2[@]/#/"$BPM_PACKAGES_PATH/$package/"}")
		bash_completion_files+=("${REPLIES1[@]}")
		zsh_completion_files+=("${REPLIES2[@]}")
	fi

	# Do linking of completion files
	for completion in "${bash_completion_files[@]}"; do
		completion="${completion/#"$BPM_PACKAGES_PATH/$package/"}"

		mkdir -p "$BPM_INSTALL_COMPLETIONS/bash"
		ln -sf "$BPM_PACKAGES_PATH/$package/$completion" "$BPM_INSTALL_COMPLETIONS/bash/${completion##*/}"
	done

	for completion in "${zsh_completion_files[@]}"; do
		completion="${completion/#"$BPM_PACKAGES_PATH/$package/"}"

		local target="$BPM_PACKAGES_PATH/$package/$completion"

		if grep -qs "^#compdef" "$target"; then
			mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compsys"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compsys/${completion##*/}"
		else
			mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compctl"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compctl/${completion##*/}"
		fi
	done
}

auto_collect_completion_files() {
	declare -ga REPLIES=()

	local package="$1"

	local -a bash_completion_files=() zsh_completion_files=()

	for completion_dir in completion completions contrib/completion contrib/completions; do
		local completion_dir="$BPM_PACKAGES_PATH/$package/$completion_dir"

		# TODO: optimize
		for target in "$completion_dir"/?*.{sh,bash}; do
			bash_completion_files+=("$target")
		done

		for target in "$completion_dir"/?*.zsh; do
			zsh_completion_files+=("$target")
		done
	done

	REPLIES1=("${bash_completion_files[@]}")
	REPLIES2=("${zsh_completion_files[@]}")
}
