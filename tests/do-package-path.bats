#!/usr/bin/env bats

load 'util/init.sh'

@test "outputs the package path" {
	test_util.mock_command _clone
	create_package username/package
	bpm-install username/package

	run bpm-package-path username/package
	assert_success "$BPM_PACKAGES_PATH/username/package"
}
