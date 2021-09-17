# shellcheck shell=bash

# @description Downloads package tarballs from the internet to the global store. If a git revision is specified, it
# will extract that revision after cloning the repository and using git-archive
pkg-phase.download_tarball() {
	local repo_uri="$1"
	local tarball_uri="$2"
	local site="$3"
	local package="$4"
	local version="$5"

	local download_url="$tarball_uri"
	local download_dest="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$site/$package@$version.tar.gz"

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
			rm -rf  "$BASALT_GLOBAL_DATA_DIR/scratch"

			# The '$version' could also be a SHA1 ref to a particular revision
			if ! git clone --quiet "$repo_uri" "$BASALT_GLOBAL_DATA_DIR/scratch/$site/$package" 2>/dev/null; then
				print.die "Could not clone repository for $site/$package@$version"
			fi

			if ! git -C "$BASALT_GLOBAL_DATA_DIR/scratch/$site/$package" archive --prefix="prefix/" -o "$download_dest" "$version" 2>/dev/null; then
				rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
				print.die "Could not download archive or extract archive from temporary Git repository of $site/$package@$version"
			fi

			rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
			print.info "Downloaded" "$site/$package@$version"
		fi
	fi

	local magic_byte=
	if magic_byte="$(xxd -p -l 2 "$download_dest")"; then
		# Ensure the downloaded file is really a .tar.gz file...
		if [ "$magic_byte" != '1f8b' ]; then
			rm -rf "$download_dest"
			print.die "Could not find a release tarball for $site/$package@$version"
		fi
	else
		rm -rf "$download_dest"
		print.die "Error" "Could not get a magic byte of the release tarball for $site/$package@$version"
	fi
}

# @description Extracts the tarballs in the global store to a directory
pkg-phase.extract_tarball() {
	local site="$1"
	local package="$2"
	local version="$3"

	local tarball_src="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$site/$package@$version.tar.gz"
	local tarball_dest="$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"

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
		print.die "Extracted tarball is not a directory at '$tarball_dest'"
	fi
}

# @description This performs modifications a particular package in the global store
pkg-phase.global-integration() {
	local site="$1"
	local package="$2"
	local version="$3"

	local project_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"

	# TODO: properly cache transmogrifications
	if [ ${DEBUG+x} ]; then
		print.debug "Transforming" "project_dir $project_dir"
	fi

	pkg-phase.local-integration "$project_dir" "$project_dir" 'yes'

	print.info "Transformed" "$site/$package@$version"
}

# Create a './basalt_packages' directory for a particular project directory
pkg-phase.local-integration() {
	unset REPLY
	local original_package_dir="$1"
	local package_dir="$2"
	local is_direct="$3" # Whether the "$package_dir" dependency is a direct or transitive dependency of "$original_package_dir"

	if [ ! -d "$package_dir" ]; then
		# TODO: make internal
		print_simple.die "A directory at '$package_dir' was expected to exist"
		return
	fi

	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_array "$package_dir/basalt.toml" 'dependencies'; then
			local pkg=
			for pkg in "${REPLIES[@]}"; do
				util.get_package_info "$pkg"
				local repo_uri="$REPLY1"
				local site="$REPLY2"
				local package="$REPLY3"
				local version="$REPLY4"
				# util.assert_package_valid "$site" "$package" "$version"

				if [ "$is_direct" = yes ]; then
					pkg.symlink_package "$original_package_dir/basalt_packages/packages" "$site" "$package" "$version"
					# pkg.symlink_bin "$package_dir/basalt_packages/transitive" "$site" "$package" "$version"
				else
					pkg.symlink_package "$original_package_dir/basalt_packages/transitive/packages" "$site" "$package" "$version"
					# pkg.symlink_bin "$package_dir/basalt_packages/transitive" "$site" "$package" "$version"
				fi

				pkg-phase.local-integration "$original_package_dir" "$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version" 'no'
			done
			unset pkg
		fi
	fi
}

# TODO: REMOVE
# Create a './basalt_packages' directory for a particular project directory
pkg-phase.local-integration-2() {
	unset REPLY
	local original_package_dir="$1"
	local package_dir="$2"
	local is_direct="$3" # Whether the "$package_dir" dependency is a direct or transitive dependency of "$original_package_dir"

	if [ -f "$BASALT_GLOBAL_DATA_DIR/global_package_list" ]; then
		while IFS=':' read -r site package version; do

		# if util.get_toml_array "$package_dir/basalt.toml" 'dependencies'; then
			local pkg="$site/$package/$version"
				util.assert_package_valid "$pkg"
			# for pkg in "${REPLIES[@]}"; do
				util.get_package_info "$pkg"
				local repo_uri="$REPLY1"
				local site="$REPLY2"
				local package="$REPLY3"
				local version="$REPLY4"

				if [ "$is_direct" = yes ]; then
					pkg.symlink_package "$original_package_dir/basalt_packages/packages" "$site" "$package" "$version"
					# pkg.symlink_bin "$package_dir/basalt_packages/transitive" "$site" "$package" "$version"
				else
					pkg.symlink_package "$original_package_dir/basalt_packages/transitive/packages" "$site" "$package" "$version"
					# pkg.symlink_bin "$package_dir/basalt_packages/transitive" "$site" "$package" "$version"
				fi

				pkg-phase.local-integration "$original_package_dir" "$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version" 'no'
			# done
			unset pkg
		# fi
		done
	else
		echo "some error 44d"
		exit 1
	fi
}
