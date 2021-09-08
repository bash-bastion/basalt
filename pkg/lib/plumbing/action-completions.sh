# shellcheck shell=bash

plumbing.symlink-completions() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	plumbing.completions_action 'link' "$pkg"
}

plumbing.unsymlink-completions() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	plumbing.completions_action 'unlink' "$pkg"
}

plumbing.completions_action() {
	local action="$1"
	local id="$2"
	ensure.non_zero 'action' "$action"
	ensure.non_zero 'id' "$id"
	ensure.package_exists "$id"

	abstract_completions_did=no

	local basalt_toml_file="$BASALT_PACKAGES_PATH/$id/basalt.toml"
	local package_sh_file="$BASALT_PACKAGES_PATH/$id/package.sh"

	# Get completion directories
	if [ -f "$basalt_toml_file" ]; then
		if util.get_toml_array "$basalt_toml_file" 'completionDirs'; then
			for dir in "${REPLIES[@]}"; do
				local full_dir="$BASALT_PACKAGES_PATH/$id/$dir"
				if [ -f "$full_dir" ]; then
					die "Specified file '$dir' in basalt.toml; only directories are valid"
				elif [ ! -d "$full_dir" ]; then
					log.warn "Directory '$dir' with executable files not found. Skipping"
					continue
				fi

				for file in "$full_dir"/*; do
					local fileName="${file##*/}"

					if [[ $fileName == *.@(sh|bash) ]]; then
						plumbing.completions_action_do_action_bash "$action" "$file"
					elif [[ $fileName == *.zsh ]]; then
						plumbing.completions_action_do_action_zsh "$action" "$file"
					elif [[ $fileName == *.fish ]]; then
						plumbing.completions_action_do_action_fish "$action" "$file"
					fi
				done
			done
		else
			plumbing.completions_action_search_heuristics "$action" "$id" 'all'
		fi
	elif [ -f "$package_sh_file" ]; then
		local -a bash_completion_files=() zsh_completion_files=()

		if util.extract_shell_variable "$package_sh_file" 'BASH_COMPLETIONS'; then
			IFS=':' read -ra bash_completion_files <<< "$REPLY"

			for file in "${bash_completion_files[@]}"; do
				local full_path="$BASALT_PACKAGES_PATH/$id/$file"
				if [ -d "$full_path" ]; then
					die "Specified directory '$file' in package.sh; only files are valid"
				elif [ ! -f "$full_path" ]; then
					log.warn "Completion file '$file' not found. Skipping"
				else
					plumbing.completions_action_do_action_bash "$action" "$full_path"
				fi
			done
		else
			plumbing.completions_action_search_heuristics "$action" "$id" 'bash'
		fi

		if util.extract_shell_variable "$package_sh_file" 'ZSH_COMPLETIONS'; then
			IFS=':' read -ra zsh_completion_files <<< "$REPLY"

			for file in "${zsh_completion_files[@]}"; do
				local full_path="$BASALT_PACKAGES_PATH/$id/$file"
				if [ -d "$full_path" ]; then
					die "Specified directory '$file' in package.sh; only files are valid"
				elif [ ! -f "$full_path" ]; then
					log.warn "Completion file '$file' not found. Skipping"
				else
					plumbing.completions_action_do_action_zsh "$action" "$full_path"
				fi
			done
		else
			plumbing.completions_action_search_heuristics "$action" "$id" 'zsh'
		fi
	else
		plumbing.completions_action_search_heuristics "$action" "$id" 'all'
	fi
}

plumbing.completions_action_search_heuristics() {
	local action="$1"
	local id="$2"
	local type="$3"

	for completion_dir in completion completions contrib/completion contrib/completions; do
		for file in "$BASALT_PACKAGES_PATH/$id/$completion_dir"/*; do
			local fileName="${file##*/}"

			if [[ $fileName == *.@(sh|bash) ]] && [[ $type == all || $type == bash ]]; then
				plumbing.completions_action_do_action_bash "$action" "$file"
			elif [[ $fileName == *.zsh ]] && [[ $type == all || $type == zsh ]]; then
				plumbing.completions_action_do_action_zsh "$action" "$file"
			elif [[ $fileName == *.fish ]] && [[ $type == all || $type == fish ]]; then
				plumbing.completions_action_do_action_fish "$action" "$file"
			fi
		done
	done

	if [[ $type == all || $type == bash ]]; then
		for completion_dir in share/bash-completion/completions etc/bash_completion.d; do
			for file in "$BASALT_PACKAGES_PATH/$id/$completion_dir"/*; do
				local fileName="${file##*/}"

				plumbing.completions_action_do_action_bash "$action" "$file"
			done
		done
	fi

	for file in "$BASALT_PACKAGES_PATH/$id"/{,etc/}*; do
		local fileName="${file##*/}"
		if [[ $fileName == *-completion.* ]]; then
			case "$fileName" in
				*.@(sh|bash)) plumbing.completions_action_do_action_bash "$action" "$file" ;;
				*.zsh) plumbing.completions_action_do_action_zsh "$action" "$file" ;;
				*.fish) plumbing.completions_action_do_action_fish "$action" "$file" ;;
			esac
		fi
done
}

plumbing.completions_action_do_action_bash() {
	local action="$1"
	local file="$2"

	plumbing.completions_action_do_echo

	local fileName="${file##*/}"
	if [[ $fileName != *.* ]]; then
		fileName="$fileName.bash"
	fi

	case "$action" in
	link)
		if [ -L "$BASALT_INSTALL_COMPLETIONS/bash/$fileName" ]; then
			log.error "Skipping '$fileName' since an existing symlink with the same name already exists"
		else
			mkdir -p "$BASALT_INSTALL_COMPLETIONS/bash"
			ln -sf "$file" "$BASALT_INSTALL_COMPLETIONS/bash/$fileName"
		fi
		;;
	unlink)
		if ! unlink "$BASALT_INSTALL_COMPLETIONS/bash/$fileName"; then
			die "Unlink failed, but was expected to succeed"
		fi
		;;
	esac

}

plumbing.completions_action_do_action_zsh() {
	local action="$1"
	local file="$2"

	plumbing.completions_action_do_echo

	if grep -qs "^#compdef" "$file"; then
		local fileName="${file##*/}"
		if [  "${fileName::1}" != _ ]; then
			fileName="${fileName/#/_}"
		fi

		case "$action" in
		link)
			if [ -L "$BASALT_INSTALL_COMPLETIONS/zsh/compsys/$fileName" ]; then
				log.error "Skipping '$fileName' since an existing symlink with the same name already exists"
			else
				mkdir -p "$BASALT_INSTALL_COMPLETIONS/zsh/compsys"
				ln -sf "$file" "$BASALT_INSTALL_COMPLETIONS/zsh/compsys/$fileName"
			fi
			;;
		unlink)
			if ! unlink "$BASALT_INSTALL_COMPLETIONS/zsh/compsys/$fileName"; then
				die "Unlink failed, but was expected to succeed"
			fi
			;;
		esac
	else
		case "$action" in
		link)
			if [ -L "$BASALT_INSTALL_COMPLETIONS/zsh/compctl/${file##*/}" ]; then
				log.error "Skipping '$fileName' since an existing symlink with the same name already exists"
			else
				mkdir -p "$BASALT_INSTALL_COMPLETIONS/zsh/compctl"
				ln -sf "$file" "$BASALT_INSTALL_COMPLETIONS/zsh/compctl/${file##*/}"
			fi
			;;
		unlink)
			if ! unlink "$BASALT_INSTALL_COMPLETIONS/zsh/compctl/${file##*/}"; then
				die "Unlink failed, but was expected to succeed"
			fi
			;;
		esac
	fi
}

plumbing.completions_action_do_action_fish() {
	local action="$1"
	local file="$2"

	plumbing.completions_action_do_echo

	case "$action" in
	link)
		if [ -L "$BASALT_INSTALL_COMPLETIONS/fish/${file##*/}" ]; then
			log.error "Skipping '$fileName' since an existing symlink with the same name already exists"
		else
			mkdir -p "$BASALT_INSTALL_COMPLETIONS/fish"
			ln -sf "$file" "$BASALT_INSTALL_COMPLETIONS/fish/${file##*/}"
		fi
		;;
	unlink)
		if ! unlink "$BASALT_INSTALL_COMPLETIONS/fish/${file##*/}"; then
			die "Unlink failed, but was expected to succeed"
		fi
		;;
	esac
}

plumbing.completions_action_do_echo() {
	if [ "$abstract_completions_did" = no ]; then
		abstract_completions_did=yes

		case "$action" in
			link) printf '  -> %s\n' "Symlinking completion files" ;;
			unlink) printf '  -> %s\n' "Unsymlinking completion files" ;;
		esac
	fi
}
