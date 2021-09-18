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
			util.get_package_info "$pkg"
			local repo_type="$REPLY1"
			local url="$REPLY2"
			local site="$REPLY3"
			local package="$REPLY4"
			local version="$REPLY5"

			# TODO
			# util.assert_package_valid "$repo_type" "$site" "$package" "$version"

			util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
			local package_id="$REPLY"

			echo pkg "$pkg" package_id "$package_id"

			# Download, extract
			pkg-phase.download_tarball "$repo_type" "$url" "$site" "$package" "$version"
			pkg-phase.extract_tarball "$package_id"

			# Install transitive dependencies
			pkg.install_package "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

			# Only after all the dependencies are installed do we transmogrify the package
			pkg-phase.global-integration "$package_id"

			# Only if all the previous modifications to the global package store has been successfull do we symlink
			# to it from the local project directory
			# pkg-phase.local-integration "$project_dir" "$project_dir" 'yes'
		done
		unset pkg
	fi

	# TODO: fix later
	if util.get_toml_array "$project_dir/basalt.toml" 'dependencies'; then
		local pkg=
		for pkg in "${REPLIES[@]}"; do
			util.get_package_info "$pkg"
			local repo_type="$REPLY1"
			local url="$REPLY2"
			local site="$REPLY3"
			local package="$REPLY4"
			local version="$REPLY5"

			# Only if all the previous modifications to the global package store has been successfull do we symlink
			# to it from the local project directory
			pkg-phase.local-integration "$project_dir" "$project_dir" 'yes'
		done
		unset pkg
	fi
}

pkg.symlink_package() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/packages"
	local package_id="$2"

	local target="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	local link_name="$install_dir/$package_id"

	if [ ${DEBUG+x} ]; then
		print.debug "Symlinking" "$link_name -> $target"
	fi

	mkdir -p "${link_name%/*}"
	if ! ln -sfT "$target" "$link_name"; then
		print.die "Could not symlink directory '${target##*/}' for package $package_id"
	fi
}

pkg.symlink_bin() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"
	local package_id="$2"

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
