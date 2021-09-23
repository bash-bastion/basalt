# shellcheck shell=bash

pkg.install_package() {
	local project_dir="$1"
	shift

	ensure.nonzero 'project_dir'

	# TODO: save the state and have rollback feature

	local pkg=
	for pkg; do
		if ! util.get_package_info "$pkg"; then
			print.die "String '$pkg' does not look like a package"
		fi
		local repo_type="$REPLY1"
		local url="$REPLY2"
		local site="$REPLY3"
		local package="$REPLY4"
		local version="$REPLY5"

		util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
		local package_id="$REPLY"

		# Download, extract
		pkg-phase.download_tarball "$repo_type" "$url" "$site" "$package" "$version"
		pkg-phase.extract_tarball "$package_id"

		# Install transitive dependencies if they exist
		if [ -f "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" ]; then
			if util.get_toml_array "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" 'dependencies'; then
				pkg.install_package "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id" "${REPLIES[@]}"
			fi
		fi

		# Only after all the dependencies are installed do we much with the package
		pkg-phase.global-integration "$package_id"
	done
	unset pkg

	# Only if all the previous modifications to the global package store has been successfull
	# do we symlink to it from the local project directory. This is in a separate loop so we
	# don't run into weird recursion issues with 'pkg.install_package'
	for pkg; do
		if ! util.get_package_info "$pkg"; then
			print-indent.die "String '$pkg' does not look like a package"
		fi
		local repo_type="$REPLY1"
		local url="$REPLY2"
		local site="$REPLY3"
		local package="$REPLY4"
		local version="$REPLY5"

		ensure.dir "$project_dir"
		if [ -f "$project_dir/basalt.toml" ]; then
			if util.get_toml_array "$project_dir/basalt.toml" 'dependencies'; then
				pkg-phase.local-integration "$project_dir" 'yes' "${REPLIES[@]}"
			fi
		fi
	done
	unset pkg
}

pkg.do-global-install() {
	if ! rm -rf "$BASALT_GLOBAL_DATA_DIR/global/basalt_packages"; then
		print-indent.die "Could not remove global 'basalt_packages' directory"
	fi

	local -a dependencies=()
	touch "$BASALT_GLOBAL_DATA_DIR/global/dependencies"
	readarray -t dependencies < "$BASALT_GLOBAL_DATA_DIR/global/dependencies"
	pkg.install_package "$BASALT_GLOBAL_DATA_DIR/global" "${dependencies[@]}"
}

pkg.local_symlink_package() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/packages"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	local target="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
	local link_name="$install_dir/$package_id"

	if [ ${DEBUG+x} ]; then
		print-indent.light-cyan "Symlinking" "$link_name -> $target"
	fi

	mkdir -p "${link_name%/*}"
	if ! ln -sf "$target" "$link_name"; then
		print-indent.die "Could not symlink directory '${target##*/}' for package $package_id"
	fi
}

pkg.local_symlink_bin() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"
	local package_id="$2"

	ensure.nonzero 'install_dir'
	ensure.nonzero 'package_id'

	local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"
	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_array "$package_dir/basalt.toml" 'binDirs'; then
			# This `mkdir` could be placed further down, but at the cost of execution speed
			mkdir -p "$install_dir/bin"
			for dir in "${REPLIES[@]}"; do
				if [ -d "$package_dir/$dir" ]; then
					for target in "$package_dir/$dir"/*; do
						local link_name="$install_dir/bin/${target##*/}"

						if [ ${DEBUG+x} ]; then
							print-indent.light-cyan "Symlinking" "target    $target"
							print-indent.light-cyan "Symlinking" "link_name $link_name"
						fi

						if [ -e "$link_name" ]; then
							print-indent 'Warning' "Executable file '${target##*/} for package $package_id will clobber an identically-named file owned by a different package"
						fi

						if ! ln -sf "$target" "$link_name"; then
							print-indent.die "Could not symlink file '${target##*/}' for package $site/$package@$version"
						fi
					done
				fi
			done
		fi
	fi
}
