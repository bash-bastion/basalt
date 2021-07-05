# shellcheck shell=bash

basher-plumbing-unlink-completions() {
	local package="$1"

	ensure.nonZero 'package' "$package"

	if [ ! -f "$BPM_PACKAGES_PATH/$package/package.sh" ]; then
		return
	fi

	local bash_completions zsh_completions
	util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'BASH_COMPLETIONS'
		IFS=':' read -ra bash_completions <<< "$REPLY"

	util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'ZSH_COMPLETIONS'
		IFS=':' read -ra zsh_completions <<< "$REPLY"

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
