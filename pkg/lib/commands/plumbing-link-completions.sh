# shellcheck shell=bash

basher-plumbing-link-completions() {
	local package="$1"

	if [ ! -e "$NEOBASHER_PACKAGES_PATH/$package/package.sh" ]; then
		exit
	fi

	source "$NEOBASHER_PACKAGES_PATH/$package/package.sh" # TODO: make this secure?
	IFS=: read -ra bash_completions <<< "$BASH_COMPLETIONS"
	IFS=: read -ra zsh_completions <<< "$ZSH_COMPLETIONS"

	for completion in "${bash_completions[@]}"; do
		mkdir -p "$NEOBASHER_PREFIX/completions/bash"
		ln -sf "$NEOBASHER_PACKAGES_PATH/$package/$completion" "$NEOBASHER_PREFIX/completions/bash/${completion##*/}"
	done

	for completion in "${zsh_completions[@]}"; do
		target="$NEOBASHER_PACKAGES_PATH/$package/$completion"
		if grep -q "#compdef" "$target"; then
			mkdir -p "$NEOBASHER_PREFIX/completions/zsh/compsys"
			ln -sf "$target" "$NEOBASHER_PREFIX/completions/zsh/compsys/${completion##*/}"
		else
			mkdir -p "$NEOBASHER_PREFIX/completions/zsh/compctl"
			ln -sf "$target" "$NEOBASHER_PREFIX/completions/zsh/compctl/${completion##*/}"
		fi
	done
}
