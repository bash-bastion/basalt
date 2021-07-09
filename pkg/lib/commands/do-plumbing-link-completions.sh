# shellcheck shell=bash

do-plumbing-link-completions() {
	local package="$1"
	ensure.nonZero 'package' "$package"
	ensure.packageExists "$package"

	log.info "Linking completion files for '$package'"

	local -a bash_completion_files=() zsh_completion_files=()

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"

	# Get completion directories
	if [ -f "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'completionDirs'; then
			local -a newCompletions=()

			for dir in "${REPLIES[@]}"; do
				newCompletions+=("$BPM_PACKAGES_PATH/$package/$dir"/*)
				newCompletions=("${newCompletions[@]/#"$BPM_PACKAGES_PATH/$package/"}")
			done

			bash_completion_files+=("${newCompletions[@]}")
			zsh_completion_files+=("${newCompletions[@]}")
		else
			auto-collect-completion_files "$package"
			REPLIES1=("${REPLIES1[@]/#/"$BPM_PACKAGES_PATH/$package/"}")
			REPLIES2=("${REPLIES2[@]/#/"$BPM_PACKAGES_PATH/$package/"}")

			bash_completion_files+=("${REPLIES1[@]}")
			zsh_completion_files+=("${REPLIES2[@]}")
		fi
	elif [ -f "$packageShFile" ]; then
		if util.extract_shell_variable "$packageShFile" 'BASH_COMPLETIONS'; then
			IFS=':' read -ra bash_completion_files <<< "$REPLY"
		else
			auto-collect-completion_files "$package"
			bash_completion_files+=("${REPLIES1[@]}")
		fi

		if util.extract_shell_variable "$packageShFile" 'ZSH_COMPLETIONS'; then
			IFS=':' read -ra zsh_completion_files <<< "$REPLY"
		else
			auto-collect-completion_files "$package"
			zsh_completion_files+=("${REPLIES2[@]}")
		fi
	else
		auto-collect-completion_files "$package"
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

auto-collect-completion_files() {
	declare -ga REPLIES=()

	local package="$1"

	local -a bash_completion_files=() zsh_completion_files=()

	for completionDir in completion completions contrib/completion contrib/completions; do
		local completionDir="$BPM_PACKAGES_PATH/$package/$completionDir"

		# TODO: optimize
		for target in "$completionDir"/?*.{sh,bash}; do
			bash_completion_files+=("$target")
		done

		for target in "$completionDir"/?*.zsh; do
			zsh_completion_files+=("$target")
		done
	done

	REPLIES1=("${bash_completion_files[@]}")
	REPLIES2=("${zsh_completion_files[@]}")
}
