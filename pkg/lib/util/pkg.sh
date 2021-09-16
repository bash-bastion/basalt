# shellcheck shell=bash

pkg.install_package() {
	local project_dir="$1"

	# TODO: save the state and have rollback feature

	if [ ! -f "$project_dir/basalt.toml" ]; then
		return
	fi

	if util.get_toml_array "$project_dir/basalt.toml" 'dependencies'; then
		local pkg=
		for pkg in "${REPLIES[@]}"; do
			util.extract_data_from_input "$pkg"
			local repo_uri="$REPLY1"
			local site="$REPLY2"
			local package="$REPLY3"
			local version="$REPLY4"
			local tarball_uri="$REPLY5"

			# Download, extract
			pkg-phase.download_tarball "$repo_uri" "$tarball_uri" "$site" "$package" "$version"
			pkg-phase.extract_tarball "$site" "$package" "$version"

			# Install transitive dependencies
			pkg.install_package "$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"

			# Only after all the dependencies are installed do we transmogrify the package
			pkg-phase.global-integration "$site" "$package" "$version"

			# Only if all the previous modifications to the global package store has been successfull do we symlink
			# to it from the local project directory
			pkg-phase.local-integration "$project_dir" "$project_dir" 'yes'
		done
		unset pkg
	fi
}

pkg.symlink_package() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/packages"
	local site="$2"
	local package="$3"
	local version="$4"

	local target="$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"
	local link_name="$install_dir/$site/$package@$version"

	if [ ${DEBUG+x} ]; then
		print.debug "Symlinking" "target    $target"
		print.debug "Symlinking" "link_name $link_name"
	fi

	mkdir -p "${link_name%/*}"
	if ! ln -sfT "$target" "$link_name"; then
		print.die "Could not symlink directory '${target##*/}' for package $site/$package@$version"
	fi
}

pkg.symlink_bin() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"
	local site="$2"
	local package="$3"
	local version="$4"

	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"
	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_array "$package_dir/basalt.toml" 'binDirs'; then
			mkdir -p "$install_dir/bin"
			for dir in "${REPLIES[@]}"; do
				if [ -f "$package_dir/$dir" ]; then
					# TODO: move this check somewhere else (subcommand check) (but still do -d)
					print.warn "Warning" "Package $site/$package@$version has a file ($dir) specified in 'binDirs'"
				else
					for target in "$package_dir/$dir"/*; do
						local link_name="$install_dir/bin/${target##*/}"

						# TODO: this replaces existing symlinks. In verify mode, can check if there are no duplicate binary names

						if [ ${DEBUG+x} ]; then
							print.debug "Symlinking" "target    $target"
							print.debug "Symlinking" "link_name $link_name"
						fi

						if ! ln -sfT "$target" "$link_name"; then
							print.die "Could not symlink file '${target##*/}' for package $site/$package@$version"
						fi
					done
				fi
			done
		fi
	fi
}
