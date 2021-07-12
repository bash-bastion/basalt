#!/usr/bin/env bats

load 'util/init.sh'

@test "prints the package path" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.fake_add "$pkg"

	run bpm-package-path "$pkg"

	assert_success
	assert_output "$BPM_PACKAGES_PATH/$site/$pkg"
}

@test "prints the package path while specifying site" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.fake_add "$pkg"

	run bpm-package-path "$site/$pkg"

	assert_success
	assert_output "$BPM_PACKAGES_PATH/$site/$pkg"
}

@test "prints the package path while specifying URL" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.fake_add "$pkg"

	run bpm-package-path "https://$site/$pkg"

	assert_success
	assert_output "$BPM_PACKAGES_PATH/$site/$pkg"
}

@test "fails if the package cannot be found" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.fake_add "$pkg"

	run bpm-package-path "other/package"

	assert_failure
	assert_output -p "Package 'github.com/other/package' not found"
}
