# shellcheck shell=bash

pkg.install_package() {
	local package_dir="$1"

	local basalt_toml_file="$package_dir/basalt.toml"
	if util.get_toml_array "$basalt_toml_file" 'dependencies'; then
		for pkg in "${REPLIES[@]}"; do
			util.extract_data_from_input "$pkg"
			local repo_uri="$REPLY1"
			local site="$REPLY2"
			local package="$REPLY3"
			local version="$REPLY4"
			local tarball_uri="$REPLYz5"

			pkg.download_package_tarball "$repo_uri" "$tarball_uri" "$site" "$package" "$version"
			pkg.extract_package_tarball "$site" "$package" "$version"
			pkg.symlink_extracted_package "$site" "$package" "$version"

			# TODO: DRY files?
			if [ -f "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version/basalt.toml" ]; then
				pkg.do_strict_symlink "$site" "$package" "$version"
				pkg.install_package "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"
			fi
		done
	fi
}

pkg.download_package_tarball() {
	local repo_uri="$1"
	local tarball_uri="$2"
	local site="$3"
	local package="$4"
	local version="$5"

	local download_url="$tarball_uri"
	local download_dest="$BASALT_GLOBAL_CELLAR/store/tarballs/$site/$package@$version.tar.gz"

	if [ ${DEBUG+x} ]; then
		print.debug "Downloading" "download_url  $download_url"
		print.debug "Downloading" "download_dest $download_dest"
	fi

	if [ -e "$download_dest" ]; then
		print.info "Downloaded" "$site/$package@$version (cached)"
	else
		mkdir -p "${download_dest%/*}"
		if curl -fLso "$download_dest" "$download_url"; then
			print.info "Downloaded" "$site/$package@$version"
		else
			# The '$version' could also be a SHA1 ref to a particular revision
			if ! git clone --quiet "$repo_uri" "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/scratchspace/$site/$package" 2>/dev/null; then
				print.die 'Error' "Could not clone repository for $site/$package@$version"
			fi

			if ! git -C "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/scratchspace/$site/$package" archive -o "$download_dest" "$version" 2>/dev/null; then
				rm -rf "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/scratchspace"
				print.die 'Error' "Could not download archive or extract archive from temporary Git repository of $site/$package@$version"
			fi

			rm -rf "$BASALT_LOCAL_PROJECT_DIR/basalt_packages/scratchspace"
			print.info "Downloaded" "$site/$package@$version"
		fi
	fi

	local magic_byte=
	if magic_byte="$(xxd -p -l 2 "$download_dest")"; then
		# Ensure the downloadedd file is really a .tar.gz file...
		if [ "$magic_byte" != '1f8b' ]; then
			rm -rf "$download_dest"
			print.die 'Error' "Could not find a release tarball for $site/$package@$version"
		fi
	else
		rm -rf "$download_dest"
		print.die "Error" "Could not get a magic byte of the release tarball for $site/$package@$version"
	fi
	# TODO: test magic byte and fail is downloaded file is not actually a tar.gz
}

pkg.extract_package_tarball() {
	local site="$1"
	local package="$2"
	local version="$3"

	local tarball_src="$BASALT_GLOBAL_CELLAR/store/tarballs/$site/$package@$version.tar.gz"
	local tarball_dest="$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"

	if [ ${DEBUG+x} ]; then
		print.debug "Extracting" "tarball_src  $tarball_src"
		print.debug "Extracting" "tarball_dest $tarball_dest"
	fi

	if [ -d "$tarball_dest" ]; then
		print.info "Extracted" "$site/$package@$version (cached)"
	else
		mkdir -p "$tarball_dest"
		if ! tar xf "$tarball_src" -C "$tarball_dest" --strip-components 1 2>/dev/null; then
			print.die "Error" "Could not extract package $site/$package@$version"
		else
			print.info "Extracted" "$site/$package@$version"
		fi
	fi

	if [ ! -d "$tarball_dest" ]; then
		print.die 'Error' "Extracted tarball is not a directory at '$tarball_dest'"
	fi
}

pkg.symlink_extracted_package() {
	local site="$1"
	local package="$2"
	local version="$3"

	local target="$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"
	local link_name="$BASALT_LOCAL_PROJECT_DIR/basalt_packages/packages/$site/$package@$version"

	if [ ${DEBUG+x} ]; then
		print.debug "Symlinking" "target    $target"
		print.debug "Symlinking" "link_name $link_name"
	fi

	# TODO: error message
	mkdir -p "${link_name%/*}"
	if ! ln -sfT "$target" "$link_name"; then
		print.die 'Error' "Could not symlink directory '${target##*/}' for package $site/$package@$version"
	fi
}

pkg.do_strict_symlink() {
	local site="$1"
	local package="$2"
	local version="$3"

	local package_dir="$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"
	if util.get_toml_array "$package_dir/basalt.toml" 'binDirs'; then
		for dir in "${REPLIES[@]}"; do
			if [ -f "$package_dir/$dir" ]; then
				# TODO: move this check somewhere else (subcommand check) (but still do -d)
				print.warn "Warning" "Package $site/$package@$version has a file ($dir) specified in 'binDirs'"
			else
				for target in "$package_dir/$dir"/*; do
					local link_name="$BASALT_LOCAL_PROJECT_DIR/basalt_packages/bin/${target##*/}"

					# TODO: this replaces existing symlinks. In verify mode, can check if there are no duplicate binary names

					if [ ${DEBUG+x} ]; then
						print.debug "Symlinking" "target    $target"
						print.debug "Symlinking" "link_name $link_name"
					fi

					if ! ln -sfT "$target" "$link_name"; then
						print.die 'Error' "Could not symlink file '${target##*/}' for package $site/$package@$version"
					fi
				done
			fi
		done
	fi
}
