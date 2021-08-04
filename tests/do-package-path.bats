#!/usr/bin/env bats

load 'util/init.sh'

@test "prints the package path" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_add "$pkg"

	run do-package-path "$pkg"

	assert_success
	assert_output "$BPM_PACKAGES_PATH/$site/$pkg"
}

@test "prints the package path while specifying site" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_add "$pkg"

	run do-package-path "$site/$pkg"

	assert_success
	assert_output "$BPM_PACKAGES_PATH/$site/$pkg"
}

@test "prints the package path while specifying URL" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_add "$pkg"

	run do-package-path "https://$site/$pkg"

	assert_success
	assert_output "$BPM_PACKAGES_PATH/$site/$pkg"
}

@test "fails if the package cannot be found" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_add "$pkg"

	run do-package-path "other/package"

	assert_failure
	assert_output -p "Package 'github.com/other/package' is not installed"
}
