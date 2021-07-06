# shellcheck shell=bash

basher-plumbing-link-completions() {
	local package="$1"

	local bash_completions zsh_completions
	if [ -f "$BPM_PACKAGES_PATH/$package/package.sh" ]; then
		util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'BASH_COMPLETIONS'
		IFS=':' read -ra bash_completions <<< "$REPLY"

		util.extract_shell_variable "$BPM_PACKAGES_PATH/$package/package.sh" 'ZSH_COMPLETIONS'
		IFS=':' read -ra zsh_completions <<< "$REPLY"
	fi

	for completion in "${bash_completions[@]}"; do
		mkdir -p "$BPM_PREFIX/completions/bash"
		ln -sf "$BPM_PACKAGES_PATH/$package/$completion" "$BPM_PREFIX/completions/bash/${completion##*/}"
	done

	for completion in "${zsh_completions[@]}"; do
		local target="$BPM_PACKAGES_PATH/$package/$completion"

		if grep -sq "#compdef" "$target"; then
			mkdir -p "$BPM_PREFIX/completions/zsh/compsys"
			ln -sf "$target" "$BPM_PREFIX/completions/zsh/compsys/${completion##*/}"
		else
			mkdir -p "$BPM_PREFIX/completions/zsh/compctl"
			ln -sf "$target" "$BPM_PREFIX/completions/zsh/compctl/${completion##*/}"
		fi
	done
}
