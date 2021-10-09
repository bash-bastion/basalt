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

	mkdir -p "${link_name%/*}"
	if ! ln -sf "$target" "$link_name"; then
		bprint.die "Could not symlink directory '${target##*/}' for package $package_id"
	fi
}

symlink.bin_strict() {
	unset REPLY; REPLY='no'
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/.basalt"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_array "$package_dir/basalt.toml" 'binDirs'; then
			REPLY='yes'

			if ((${#REPLIES[@]} > 0)); then
				mkdir -p "$install_dir/bin"
			fi

			local dir=
			for dir in "${REPLIES[@]}"; do
				if [ -d "$package_dir/$dir" ]; then
					local file=
					for file in "$package_dir/$dir"/*; do
						symlink.bin_util_create_symlink "$install_dir" "$file"
					done; unset file
				else
					bprint.warn "Package '$package_id' improperly listed '$dir' as a directory in 'binDirs'"
				fi
			done; unset dir
		fi
	fi
}

symlink.bin_lenient() {
	local install_dir="$1"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	symlink.bin_strict "$install_dir" "$package_id"
	if [ "$REPLY" = 'yes' ]; then
		return
	fi

	# USE HEURISTICS
	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	if [ -d "$package_dir/bin" ]; then
		mkdir -p "$install_dir/bin" # TODO: do this only once
		local file=
		for file in "$package_dir"/bin/*; do
			if [ -f "$file" ]; then
				symlink.bin_util_create_symlink "$install_dir" "$file"
			fi
		done; unset file
	elif [ -d "$package_dir/bins" ]; then
		mkdir -p "$install_dir/bin" # TODO: do this only once
		local file=
		for file in "$package_dir"/bins/*; do
			if [ -f "$file" ]; then
				symlink.bin_util_create_symlink "$install_dir" "$file"
			fi
		done; unset file
	else
		mkdir -p "$install_dir/bin" # TODO: do this only once
		local file=
		for file in "$package_dir"/*; do
			if [ -f "$file" ] && [ -x "$file" ]; then
				symlink.bin_util_create_symlink "$install_dir" "$file"
			fi
		done; unset file
	fi
}

# @description Symlink the bin file to the correct location or
# remove the symlink
# @arg $1 The full path of the executable
# @arg $2 Whether to remove extensions
symlink.bin_util_create_symlink() {
	local install_dir="$1"
	local full_bin_file="$2"

	local bin_name="${full_bin_file##*/}"
	if [ -L "$install_dir/bin/$bin_name" ]; then
		log.error "Skipping '$bin_name' since an existing symlink with the same name already exists"
	else
		ln -sf "$full_bin_file" "$install_dir/bin/$bin_name"
		chmod +x "$install_dir/bin/$bin_name"
	fi
}
