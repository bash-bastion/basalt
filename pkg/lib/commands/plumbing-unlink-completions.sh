# shellcheck shell=bash

basher-plumbing-unlink-completions() {
	local package="$1"

	ensure.nonZero 'package' "$package"

	if [ ! -f "$BPM_PACKAGES_PATH/$package/package.sh" ]; then
		return
	fi

	source "$BPM_PACKAGES_PATH/$package/package.sh" # TODO: make this secure?
	IFS=: read -ra bash_completions <<< "$BASH_COMPLETIONS"
	IFS=: read -ra zsh_completions <<< "$ZSH_COMPLETIONS"

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
