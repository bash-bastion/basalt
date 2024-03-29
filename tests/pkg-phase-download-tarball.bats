# shellcheck shell=bash

load './util/init.sh'

@test "Succeeds for valid repository" {
	local package_id="github.com/hyperupcall/bash-object@v0.6.3"
	pkgutil.get_package_info "https://$package_id"
	local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

	pkgutil.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	run pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version" "$package_id"

	assert_success
	assert_line -p "Downloaded: $package_id"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}

@test "Succeeds with caching" {
	local package_id="github.com/hyperupcall/bash-object@v0.6.3"
	pkgutil.get_package_info "https://$package_id"
	local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

	pkgutil.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	run pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version" "$package_id"

	assert_success
	assert_line -p "Downloaded: $package_id"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"

	run pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version" "$package_id"
	assert_line -p "Downloaded: $package_id (cached)"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"

	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}

# Note that by the time we get to 'pkgutil.get_package_info', we expect the version (REPLY5)
# to properly be calculated in the code via checking the version with -z, and calling
# `pkgutil.get_latest_package_version`
@test "Succeeds with local file" {
	test_util.create_fake_remote 'user/repo' 'v0.0.1'; dir="$REPLY"
	pkgutil.get_package_info "file://$dir"
	local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

	pkgutil.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	run pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "v0.0.1" "$package_id"

	assert_success
	assert_line -p "Downloaded: local/fake_remote_user_repo"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/local/fake_remote_user_repo.tar.gz"
}

@test "Fails for invalid repository" {
	local package_id="github.com/hyperupcall/bash-object-nonexist@v0.6.3"
	pkgutil.get_package_info "https://$package_id"
	local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

	pkgutil.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	run pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version" "$package_id"

	assert_failure
	assert_line -p "Could not clone repository for $package_id"
	assert_not_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}

@test "Fails for invalid repository version" {
	skip

	local package_id="github.com/hyperupcall/bash-object@v0.0.0"
	pkgutil.get_package_info "https://$package_id"
	local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

	pkgutil.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	run pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version" "$package_id"

	assert_failure
	assert_line -p "Could not download archive or extract archive from temporary Git repository of $package_id"
	assert_not_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}
