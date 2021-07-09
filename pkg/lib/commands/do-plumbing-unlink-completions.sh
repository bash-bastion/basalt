# shellcheck shell=bash

do-plumbing-unlink-completions() {
	local package="$1"
	ensure.non_zero 'package' "$package"

	log.info "Unlinking completion files for '$package'"

	local -a bash_completions=() zsh_completions=()

	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"
	if [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'BASH_COMPLETIONS'; then
			IFS=':' read -ra bash_completions <<< "$REPLY"
		fi

		if util.extract_shell_variable "$package_sh_file" 'ZSH_COMPLETIONS'; then
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
