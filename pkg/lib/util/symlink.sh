# shellcheck shell=bash

# @file symlink.sh
# @brief Functions that aid in symlinking a local project to global packages

symlink.package() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/.basalt/packages"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	local target="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	local link_name="$install_dir/$package_id"

	if [ ${DEBUG+x} ]; then
		print.indent-light-cyan "Symlinking" "$link_name -> $target"
	fi

	mkdir -p "${link_name%/*}"
	if ! ln -sf "$target" "$link_name"; then
		print.indent-die "Could not symlink directory '${target##*/}' for package $package_id"
	fi
}

symlink.bin_strict() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/.basalt"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"
	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_array "$package_dir/basalt.toml" 'binDirs'; then
			if ((${#REPLIES[@]} > 0)); then
				mkdir -p "$install_dir/bin"
			fi

			for dir in "${REPLIES[@]}"; do
				if [ -d "$package_dir/$dir" ]; then
					for target in "$package_dir/$dir"/*; do
						local link_name="$install_dir/bin/${target##*/}"

						if [ ${DEBUG+x} ]; then
							print.indent-light-cyan "Symlinking" "target    $target"
							print.indent-light-cyan "Symlinking" "link_name $link_name"
						fi

						if [ -e "$link_name" ]; then
							print-indent 'Warning' "Executable file '${target##*/} for package $package_id will clobber an identically-named file owned by a different package"
						fi

						if ! ln -sf "$target" "$link_name"; then
							print.indent-die "Could not symlink file '${target##*/}' for package $site/$package@$version"
						fi
					done
				fi
			done
		fi
	fi
}

symlink.bin_lenient() {
	local install_dir="$1"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	local -a bins=()
	local remove_extensions='no'
	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_string "$package_dir/basalt.toml" 'binRemoveExtensions'; then
			if [ "$REPLY" = 'yes' ]; then
				remove_extensions='yes'
			fi
		fi

		# TODO: cleanup?
		if util.get_toml_array "$package_dir/basalt.toml" 'binDirs'; then
			local dir=
			for dir in "${REPLIES[@]}"; do
				if [ -d "$package_dir/$dir" ]; then
					for file in "$package_dir/$dir"/*; do
						symlink.bin_lenient_util_create_symlink "$install_dir" "$file" "$remove_extensions"
					done
				fi
			done
			unset dir

			return
		fi

		symlink.bin_lenient_util_heuristics "$install_dir" "$package_id" "$remove_extensions"
	elif [ -f "$package_dir/package.sh" ]; then
		if util.extract_shell_variable "$package_dir/package.sh" 'REMOVE_EXTENSION'; then
			remove_extensions="$REPLY"
		fi

		if util.extract_shell_variable "$package_dir/package.sh" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"

			local file=
			for file in "${bins[@]}"; do
				if [ -d "$package_dir/$file" ]; then
					die "Specified directory '$file' in package.sh; only files are valid"
				elif [ ! -f "$package_dir/$file" ]; then
					log.warn "Executable file '$file' not found. Skipping"
				else
					symlink.bin_lenient_util_create_symlink "$install_dir" "$package_dir/$file" "$remove_extensions"
				fi
			done
			unset file
		else
			symlink.bin_lenient_util_heuristics "$install_dir" "$package_id" "$remove_extensions"
		fi
	else
		symlink.bin_lenient_util_heuristics "$install_dir" "$package_id" "$remove_extensions"
	fi
}

# @description Use heuristics to locate and symlink the bin files. This is ran when
# the user does not supply any bin files/dirs with any config
# @arg $1 package
# @arg $2 Whether to remove extensions
symlink.bin_lenient_util_heuristics() {
	local install_dir="$1"
	local package_id="$2"
	local remove_extensions="$3"

	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	if [ -d "$package_dir/bin" ]; then
		for file in "$package_dir"/bin/*; do
			symlink.bin_lenient_util_create_symlink "$install_dir" "$file" "$remove_extensions"
		done
	elif [ -d "$package_dir/bins" ]; then
		for file in "$package_dir"/bins/*; do
			symlink.bin_lenient_util_create_symlink "$install_dir" "$file" "$remove_extensions"
		done
	else
		for file in "$package_dir"/*; do
			if [ -f "$file" ] && [ -x "$file" ]; then
				symlink.bin_lenient_util_create_symlink "$install_dir" "$file" "$remove_extensions"
			fi
		done
	fi
}

# @description Symlink the bin file to the correct location or
# remove the symlink
# @arg $1 The full path of the executable
# @arg $2 Whether to remove extensions
symlink.bin_lenient_util_create_symlink() {
	local install_dir="$1"
	local full_bin_file="$2"
	local remove_extensions="$3"

	local bin_name="${full_bin_file##*/}"

	if [[ "${remove_extensions:-no}" == @(yes|true) ]]; then
		bin_name="${bin_name%%.*}"
	fi

	mkdir -p "$install_dir/bin" # TODO: do this only once
	if [ -L "$install_dir/bin/$bin_name" ]; then
		log.error "Skipping '$bin_name' since an existing symlink with the same name already exists"
	else
		ln -sf "$full_bin_file" "$install_dir/bin/$bin_name"
		chmod +x "$install_dir/bin/$bin_name"
	fi
}
