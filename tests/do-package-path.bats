#!/usr/bin/env bats

load 'util/init.sh'

@test "prints the package path" {
	create_package username/package
	test_util.fake_clone username/package

	run bpm-package-path username/package

	assert_success "$BPM_PACKAGES_PATH/username/package"
}
