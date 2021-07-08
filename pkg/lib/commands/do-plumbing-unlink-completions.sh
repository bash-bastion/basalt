# shellcheck shell=bash

do-plumbing-unlink-completions() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	log.info "Unlinking completion files for '$package'"

	local -a bash_completions=() zsh_completions=()

	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"
	if [ -f "$packageShFile" ]; then
		if util.extract_shell_variable "$packageShFile" 'BASH_COMPLETIONS'; then
			IFS=':' read -ra bash_completions <<< "$REPLY"
		fi

		if til.extract_shell_variable "$packageShFile" 'ZSH_COMPLETIONS'; then
			IFS=':' read -ra zsh_completions <<< "$REPLY"
		fi
	fi

	for completion in "${bash_completions[@]}"; do
		rm -f "$BPM_INSTALL_COMPLETIONS/bash/${completion##*/}"
	done

	for completion in "${zsh_completions[@]}"; do
		local target="$BPM_PACKAGES_PATH/$package/$completion"

		if grep -sq "#compdef" "$target"; then
			rm -f "$BPM_INSTALL_COMPLETIONS/zsh/compsys/${completion##*/}"
		else
			rm -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/${completion##*/}"
		fi
	done
}
