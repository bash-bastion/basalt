# shellcheck shell=bash

pkg.download_package_tarball() {
	local site="$1"
	local package="$2"
	local version="$3"

	local download_url="https://$site/$package/archive/refs/tags/$version.tar.gz" # TODO: make gitlab, etc.
	local download_dest="$BASALT_CELLAR/tarballs/$site/$package@$version.tar.gz"

	if [ ${DEBUG+x} ]; then
		print.debug "Downloading" "download_url  $download_url"
		print.debug "Downloading" "download_dest $download_dest"
	fi

	if [ -e "$download_dest" ]; then
		print.info "Downloaded" "$site/$package@$version (cached)"
	else
		mkdir -p "${download_dest%/*}"
		if ! curl -fLso "$download_dest" "$download_url"; then
			print.error "Error" "Could not download package $site/$package@$version"
		else
			print.info "Downloaded" "$site/$package@$version"
		fi
	fi
}

pkg.extract_package_tarball() {
	local site="$1"
	local package="$2"
	local version="$3"

	local tarball_src="$BASALT_CELLAR/tarballs/$site/$package@$version.tar.gz"
	local tarball_dest="$BASALT_CELLAR/packages/$site/$package@$version"

	if [ ${DEBUG+x} ]; then
		print.debug "Extracting" "tarball_src  $tarball_src"
		print.debug "Extracting" "tarball_dest $tarball_dest"
	fi

	if [ -e "$tarball_dest" ]; then
		print.info "Extracted" "$site/$package@$version (cached)"
	else
		mkdir -p "$tarball_dest"
		if ! tar xf "$tarball_src" -C "$tarball_dest" --strip-components 1 2>/dev/null; then
			print.error "Error" "Could not extract package $site/$package@$version"
		else
			print.info "Extracted" "$site/$package@$version"
		fi
	fi
}

pkg.do_strict_symlink() {
	local site="$1"
	local package="$2"
	local version="$3"

	local package_dir="$BASALT_CELLAR/packages/$site/$package@$version"
	local package_toml="$BASALT_CELLAR/packages/$site/$package@$version/basalt.toml"
	if [ ! -f "$package_toml" ]; then
		print.warn "Warning" "Package $site/$package@$version does not have a basalt.toml"
		return
	fi

	if util.get_toml_array "$package_toml" 'binDirs'; then
		for dir in "${REPLIES[@]}"; do


			util.extract_data_from_input "$pkg"
			local child_uri="$REPLY1"
			local child_site="$REPLY2"
			local child_package="$REPLY3"
			local child_version="$REPLY4"

			if [ -f "$package_dir/$dir" ]; then
				# TODO: move this check somewhere else
				print.warn "Warning" "Package $site/$package@$version has a file ($dir) specified in 'binDirs'"
			else
				for target in "$package_dir/$dir"/*; do
					local link_name="$BASALT_CELLAR/bin/${target##*/}"

					# TODO: this replaces existing symlinks. In verify mode, can check if there are no duplicate binary names

					if [ ${DEBUG+x} ]; then
						print.debug "Symlinking" "target    $target"
						print.debug "Symlinking" "link_name $link_name"
					fi

					ln -sfT "$target" "$link_name"
				done
			fi
		done
	fi
}
