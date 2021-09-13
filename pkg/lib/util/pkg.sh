# shellcheck shell=bash

pkg.install_package() {
	local project_dir="$1"

	# TODO: save the state and have rollback feature
	if [ -f "$project_dir/basalt.toml" ]; then
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
				pkg.download_package_tarball "$repo_uri" "$tarball_uri" "$site" "$package" "$version"
				pkg.extract_package_tarball "$site" "$package" "$version"

				# Install transitive dependencies
				BASALT_INTERNAL_FLAG_TRANSITIVE= pkg.install_package "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"

				# Only after all the dependencies are installed do we transmogrify the package
				pkg.transmogrify_package "$site" "$package" "$version"

				# Create the local './basalt_packages' directory, and populate its contents accordingly. Note that this
				# function is also used in pkg.transmogrify_package, since transitive dependencies need to have their
				# respective './basalt_packages' directories as well. We do this last because we want all the modifications
				# to the global package store to be successfull before symlinking to files and directories inside it
				# pkg.symlink_package "$project_dir/basalt_packages/packages" "$site" "$package" "$version"
				# pkg.symlink_bin "$project_dir/basalt_packages" "$site" "$package" "$version"
			done

			# for pkg in "${REPLIES[@]}"; do

			# done
			unset pkg
		else
			# TODO
			:
		fi
	fi
}

# @description Downloads packages to the global store as tarballs
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
			if ! git clone --quiet "$repo_uri" "$BASALT_LOCAL_PACKAGE_DIR/scratchspace/$site/$package" 2>/dev/null; then
				print.die 'Error' "Could not clone repository for $site/$package@$version"
			fi

			if ! git -C "$BASALT_LOCAL_PACKAGE_DIR/scratchspace/$site/$package" archive --prefix="prefix/" -o "$download_dest" "$version" 2>/dev/null; then
				rm -rf "$BASALT_LOCAL_PACKAGE_DIR/scratchspace"
				print.die 'Error' "Could not download archive or extract archive from temporary Git repository of $site/$package@$version"
			fi

			rm -rf "$BASALT_LOCAL_PACKAGE_DIR/scratchspace"
			print.info "Downloaded" "$site/$package@$version"
		fi
	fi

	local magic_byte=
	if magic_byte="$(xxd -p -l 2 "$download_dest")"; then
		# Ensure the downloaded file is really a .tar.gz file...
		if [ "$magic_byte" != '1f8b' ]; then
			rm -rf "$download_dest"
			print.die 'Error' "Could not find a release tarball for $site/$package@$version"
		fi
	else
		rm -rf "$download_dest"
		print.die "Error" "Could not get a magic byte of the release tarball for $site/$package@$version"
	fi
}

# @description Extracts the tarballs in the global store to a directory
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

# @description This performs modifications a particular package in the global store
pkg.transmogrify_package() {
	local site="$1"
	local package="$2"
	local version="$3"

	local project_dir="$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"

	# TODO: properly cache transmogrifications

	if [ ${DEBUG+x} ]; then
		print.debug "Transmogrifying" "project_dir $project_dir"
	fi

	declare -ag all_things=()
	pkg.do_global_symlink "$project_dir" 'direct'
	for thing in "${all_things[@]}"; do
		echo "$thing"
	done

	print.info "Transmogrified" "$site/$package@$version"
}

# Create a './basalt_packages' directory for a particular project directory
pkg.do_global_symlink() {
	unset REPLY
	local project_dir="$1"
	local dependency_type="$2" # TODO: explanation because dependency_type is a little confusion

	# TODO: project_dir should be package_dir

	# TODO error message
	if [ ! -d "$project_dir" ]; then
		printf '%s\n' "Error: Should be installed"
		return
	fi

	if [ -f "$project_dir/basalt.toml" ]; then
		if util.get_toml_array "$project_dir/basalt.toml" 'dependencies'; then
			local pkg=
			for pkg in "${REPLIES[@]}"; do
				util.extract_data_from_input "$pkg"
				local repo_uri="$REPLY1"
				local site="$REPLY2"
				local package="$REPLY3"
				local version="$REPLY4"
				local tarball_uri="$REPLY5"

				if [ "$dependency_type" = self ]; then
					pkg.do_global_symlink "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version" 'direct'
				elif [ "$dependency_type" = direct ]; then
					pkg.do_global_symlink "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version" 'transitive'
					all_things+=("$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version:direct")
				elif [ "$dependency_type" = transitive ]; then
					pkg.do_global_symlink "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version" 'transitive'
					all_things+=("$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version:transitive")
				fi
			done
			unset pkg
		fi
	fi
	# if [ "$is_transitive" = yes ]; then
	# 	pkg.symlink_package "$project_dir/basalt_packages/transitive/packages" "$site" "$package" "$version"
	# else
	# 	pkg.symlink_package "$project_dir/basalt_packages/packages" "$site" "$package" "$version"
	# fi

	# if [ -n "$link_from_previous" ]; then
	# 	if [ "$is_transitive" = yes ]; then
	# 		pkg.symlink_package "$link_from_previous/basalt_packages/transitive/packages" "$site" "$package" "$version"
	# 	else
	# 		pkg.symlink_package "$link_from_previous/basalt_packages/packages" "$site" "$package" "$version"
	# 	fi
	# fi

	# if [ -f "$link_from/basalt.toml" ]; then
	# 	if util.get_toml_array "$link_from/basalt.toml" 'dependencies'; then
	# 		local pkg=
	# 		for pkg in "${REPLIES[@]}"; do
	# 			util.extract_data_from_input "$pkg"
	# 			local repo_uri="$REPLY1"
	# 			local site="$REPLY2"
	# 			local package="$REPLY3"
	# 			local version="$REPLY4"
	# 			local tarball_uri="$REPLY5"

	# 			if [ "$is_transitive" = yes ]; then
	# 				pkg.symlink_package "$link_from_previous/basalt_packages/transitive/packages" "$site" "$package" "$version"
	# 				pkg.symlink_bin "$project_dir/basalt_packages/transitive" "$site" "$package" "$version"
	# 			else
	# 				pkg.symlink_package "$link_from_previous/basalt_packages/packages" "$site" "$package" "$version"
	# 				pkg.symlink_bin "$project_dir/basalt_packages" "$site" "$package" "$version"
	# 			fi

	# 			pkg.do_global_symlink "$project_dir" "$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version" "$link_from" 'yes'
	# 		done
	# 	fi
	# fi
}

pkg.symlink_package() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PACKAGE_DIR/packages"
	local site="$2"
	local package="$3"
	local version="$4"

	local target="$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"
	local link_name="$install_dir/$site/$package@$version"

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

pkg.symlink_bin() {
	local install_dir="$1" # e.g. "$BASALT_LOCAL_PACKAGE_DIR"
	local site="$2"
	local package="$3"
	local version="$4"

	local package_dir="$BASALT_GLOBAL_CELLAR/store/packages/$site/$package@$version"
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
							print.die 'Error' "Could not symlink file '${target##*/}' for package $site/$package@$version"
						fi
					done
				fi
			done
		fi
	fi
}
