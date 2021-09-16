# shellcheck shell=bash

do-global-add() {
	util.init_global

	local -a pkgs=()
	for arg; do case "$arg" in
	-*)
		print_simple.die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	touch "$BASALT_GLOBAL_DATA_DIR/global_package_list"

	# TODO: WET
	for pkg in "${pkgs[@]}"; do
		util.extract_data_from_input "$pkg"
		local repo_uri="$REPLY1"
		local site="$REPLY2"
		local package="$REPLY3"
		local version="$REPLY4"
		local tarball_uri="$REPLY5"

		if [ -z "$version" ]; then
			util.get_latest_package_version "$package"
			version="${REPLY%*@}"
		fi

		local project_dir="$BASALT_GLOBAL_DATA_DIR/global_packages"
		mkdir -p "$project_dir"
		# Download, extract
		pkg-phase.download_tarball "$repo_uri" "$tarball_uri" "$site" "$package" "$version"
		pkg-phase.extract_tarball "$site" "$package" "$version"

		# Install transitive dependencies
		pkg.install_package "$BASALT_GLOBAL_DATA_DIR/store/packages/$site/$package@$version"

		# Only after all the dependencies are installed do we transmogrify the package
		pkg-phase.global-integration "$site" "$package" "$version"

		printf '%s\n' "$version:$package:$site" >> "$BASALT_GLOBAL_DATA_DIR/global_package_list"

		# Only if all the previous modifications to the global package store has been successfull do we symlink
		# to it from the local project directory
		pkg-phase.local-integration-2 "$project_dir" "$project_dir" 'yes'

		# TODO
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/stub_project"
		printf '%s\n' "$site/$package@$version" >> "$BASALT_GLOBAL_DATA_DIR/stub_project/list"
		awk -i inplace '!seen[$0]++' "$BASALT_GLOBAL_DATA_DIR/stub_project/list"
	done

}

global-add-package() {
	local site="$1"
	local package="$2"
	local version="$3"

	local lsite= lpackage= lversion=
	while IFS= read -r; do
		while IFS=':' lsite lpackage lversion; do
			if [ "$site" = "$lsite" ] && [ "$package" = "$lpackage" ]; then
				print_simple.die "Global package '$package' is already installed"
			fi
		done
	done < "$BASALT_GLOBAL_DATA_DIR/global_package_list"

	echo "installing package $site $package"
	# pkg.install_package "$BASALT_GLOBAL_DATA_DIR/global_packages"

	util.extract_data_from_input "$site/$package/$version"
	local repo_uri="$REPLY1"
	local site="$REPLY2"
	local package="$REPLY3"
	local version="$REPLY4"
	local tarball_uri="$REPLY5"

}
