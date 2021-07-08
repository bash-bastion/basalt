# shellcheck shell=bash

do-plumbing-link-completions() {
	local package="$1"
	ensure.nonZero 'package' "$package"
	ensure.packageExists "$package"

	log.info "Linking completion files for '$package'"

	local -a completions=()
	local -a bash_completions=() zsh_completions=()

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"

	if [ -f "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'completionDirs'; then
			local -a newCompletions=()
			for dir in "${REPLIES[@]}"; do
				newCompletions=("$BPM_PACKAGES_PATH/$package/$dir"/*)
				newCompletions=("${newCompletions[@]##*/}")
				newCompletions=("${newCompletions[@]/#/"$dir"/}")
			done
			completions+=("${newCompletions[@]}")

			# TODO: quick hack
			bash_completions+=("${completions[@]}")
			zsh_completions+=("${completions[@]}")
		fi
	elif [ -f "$packageShFile" ]; then
		util.extract_shell_variable "$packageShFile" 'BASH_COMPLETIONS'
		IFS=':' read -ra bash_completions <<< "$REPLY"

		util.extract_shell_variable "$packageShFile" 'ZSH_COMPLETIONS'
		IFS=':' read -ra zsh_completions <<< "$REPLY"
	fi

	for completion in "${bash_completions[@]}"; do
		mkdir -p "$BPM_INSTALL_COMPLETIONS/bash"
		ln -sf "$BPM_PACKAGES_PATH/$package/$completion" "$BPM_INSTALL_COMPLETIONS/bash/${completion##*/}"
	done

	for completion in "${zsh_completions[@]}"; do
		local target="$BPM_PACKAGES_PATH/$package/$completion"

		if grep -qs "^#compdef" "$target"; then
			mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compsys"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compsys/${completion##*/}"
		else
			mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compctl"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compctl/${completion##*/}"
		fi
	done

	# TODO: Move this inside -f packageshFile
	if [[ "${#bash_completions[@]}" -eq 0 && "${#zsh_completions[@]}" -eq 0 ]]; then
		for completionDir in completion completions contrib/completion contrib/completions; do
		local completionDir="$BPM_PACKAGES_PATH/$package/$completionDir"

		for target in "$completionDir"/?*.{sh,bash}; do
			mkdir -p "$BPM_INSTALL_COMPLETIONS/bash"
			ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/bash/${completion##*/}"
		done

		for target in "$completionDir"/?*.zsh; do
			if grep -qs "^#compdef" "$target"; then
				mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compsys"
				ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compsys/${completion##*/}"
			else
				mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compctl"
				ln -sf "$target" "$BPM_INSTALL_COMPLETIONS/zsh/compctl/${completion##*/}"
			fi
		done
	done
	fi

}
