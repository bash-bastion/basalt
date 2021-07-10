#!/usr/bin/env bats

load 'util/init.sh'

@test "prints the package path" {
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.fake_install "$pkg"

	run bpm-package-path "$pkg"

	assert_success "$BPM_PACKAGES_PATH/$pkg"
}
