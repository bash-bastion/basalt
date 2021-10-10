# shellcheck shell=bash

load './util/init.sh'

@test "Succeeds for valid repository" {
	local package_id="github.com/hyperupcall/bash-object@v0.6.3"
	util.get_package_info "https://$package_id"

	run pkg.phase_download_tarball "$REPLY1" "$REPLY2" "$REPLY3" "$REPLY4" "$REPLY5"

	assert_success
	assert_line -p "Downloaded: $package_id"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}

@test "Succeeds with caching" {
	local package_id="github.com/hyperupcall/bash-object@v0.6.3"
	util.get_package_info "https://$package_id"

	run pkg.phase_download_tarball "$REPLY1" "$REPLY2" "$REPLY3" "$REPLY4" "$REPLY5"

	assert_success
	assert_line -p "Downloaded: $package_id"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"

	run pkg.phase_download_tarball "$REPLY1" "$REPLY2" "$REPLY3" "$REPLY4" "$REPLY5"
	assert_line -p "Downloaded: $package_id (cached)"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"

	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}

# Note that by the time we get to 'util.get_package_info', we expect the version (REPLY5)
# to properly be calculated in the code via checking the version with -z, and calling
# `util.get_latest_package_version`
@test "Succeeds with local file" {
	test_util.create_fake_remote 'user/repo' 'v0.0.1'; dir="$REPLY"
	util.get_package_info "file://$dir"

	run pkg.phase_download_tarball "$REPLY1" "$REPLY2" "$REPLY3" "$REPLY4" 'v0.0.1'

	assert_success
	assert_line -p "Downloaded: local/fake_remote_user_repo@v0.0.1"
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/local/fake_remote_user_repo@v0.0.1.tar.gz"
}

@test "Fails for invalid repository" {
	local package_id="github.com/hyperupcall/bash-object-nonexist@v0.6.3"
	util.get_package_info "https://$package_id"

	run pkg.phase_download_tarball "$REPLY1" "$REPLY2" "$REPLY3" "$REPLY4" "$REPLY5"

	assert_failure
	assert_line -p "Could not clone repository for $package_id"
	assert_not_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}

@test "Fails for invalid repository version" {
	skip

	local package_id="github.com/hyperupcall/bash-object@v0.0.0"
	util.get_package_info "https://$package_id"

	run pkg.phase_download_tarball "$REPLY1" "$REPLY2" "$REPLY3" "$REPLY4" "$REPLY5"

	assert_failure
	assert_line -p "Could not download archive or extract archive from temporary Git repository of $package_id"
	assert_not_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
}
