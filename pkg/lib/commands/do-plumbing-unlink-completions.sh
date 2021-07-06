# shellcheck shell=bash

bpm-plumbing-unlink-completions() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	local -a bash_completions=() zsh_completions=()
	if [ -f "$BPM_PACKAGES_PATH/$package/package.sh" ]; then
		util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'BASH_COMPLETIONS'
			IFS=':' read -ra bash_completions <<< "$REPLY"

		util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'ZSH_COMPLETIONS'
			IFS=':' read -ra zsh_completions <<< "$REPLY"
	fi

	for completion in "${bash_completions[@]}"; do
		rm -f "$BPM_PREFIX/completions/bash/${completion##*/}"
	done

	for completion in "${zsh_completions[@]}"; do
		local target="$BPM_PACKAGES_PATH/$package/$completion"

		if grep -sq "#compdef" "$target"; then
			rm -f "$BPM_PREFIX/completions/zsh/compsys/${completion##*/}"
		else
			rm -f "$BPM_PREFIX/completions/zsh/compctl/${completion##*/}"
		fi
	done
}
