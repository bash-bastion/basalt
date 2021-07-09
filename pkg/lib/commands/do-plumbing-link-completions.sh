# shellcheck shell=bash

do-plumbing-link-completions() {
	local package="$1"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	log.info "Linking completion files for '$package'"

	local bpm_toml_file="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"

	# Get completion directories
	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_array "$bpm_toml_file" 'completionDirs'; then
			for dir in "${REPLIES[@]}"; do
				for file in "$BPM_PACKAGES_PATH/$package/$dir"/*; do
					local fileName="${file##*/}"

					if [[ $fileName == *.@(sh|bash) ]]; then
						symlink_bash_completion_file "$file"
					elif [[ $fileName == *.zsh ]]; then
						symlink_zsh_completion_file "$file"
					fi
				done
			done
		else
			fallback_symlink_completions "$package" 'all'
		fi
	elif [ -f "$package_sh_file" ]; then
		local -a bash_completion_files=() zsh_completion_files=()

		if util.extract_shell_variable "$package_sh_file" 'BASH_COMPLETIONS'; then
			IFS=':' read -ra bash_completion_files <<< "$REPLY"

			for file in "${bash_completion_files[@]}"; do
				symlink_bash_completion_file "$BPM_PACKAGES_PATH/$package/$file"
			done
		else
			fallback_symlink_completions "$package" 'bash'
		fi

		if util.extract_shell_variable "$package_sh_file" 'ZSH_COMPLETIONS'; then
			IFS=':' read -ra zsh_completion_files <<< "$REPLY"

			for file in "${zsh_completion_files[@]}"; do
				symlink_zsh_completion_file "$BPM_PACKAGES_PATH/$package/$file"
			done
		else
			fallback_symlink_completions "$package" 'zsh'
		fi
	else
		fallback_symlink_completions "$package" 'all'
	fi
}

fallback_symlink_completions() {
	local package="$1"
	local type="$2"

	for completion_dir in completion completions contrib/completion contrib/completions; do
		for file in "$BPM_PACKAGES_PATH/$package/$completion_dir"/*; do
			local fileName="${file##*/}"

			if [[ $fileName == *.@(sh|bash) ]] && [[ $type == all || $type == bash ]]; then
				symlink_bash_completion_file "$file"
			elif [[ $fileName == *.zsh ]] && [[ $type == all || $type == zsh ]]; then
				symlink_zsh_completion_file "$file"
			fi
		done
	done
}

symlink_bash_completion_file() {
	local file="$1"

	mkdir -p "$BPM_INSTALL_COMPLETIONS/bash"
	ln -sf "$file" "$BPM_INSTALL_COMPLETIONS/bash/${file##*/}"
}

symlink_zsh_completion_file() {
	local file="$1"

	if grep -qs "^#compdef" "$file"; then
		# TODO: run mkdir outside of loop
		mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compsys"
		ln -sf "$file" "$BPM_INSTALL_COMPLETIONS/zsh/compsys/${file##*/}"
	else
		mkdir -p "$BPM_INSTALL_COMPLETIONS/zsh/compctl"
		ln -sf "$file" "$BPM_INSTALL_COMPLETIONS/zsh/compctl/${file##*/}"
	fi
}
