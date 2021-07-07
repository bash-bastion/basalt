#!/usr/bin/env bats

load 'util/init.sh'

@test "fails if package is not installed" {
	run bpm-uninstall user/lol
	assert_failure
	assert_output -e "Package 'user/lol' is not installed"
}

@test "removes package directory" {
	test_util.mock_command plumbing-clone
	create_package username/package
	bpm-install username/package

	run bpm-uninstall username/package
	assert_success
	[ ! -d "$BPM_PACKAGES_PATH/username/package" ]
}

@test "removes binaries" {
	test_util.mock_command plumbing-clone
	create_package username/package
	create_exec username/package exec1
	bpm-install username/package

	run bpm-uninstall username/package
	assert_success
	[ ! -e "$BPM_INSTALL_BIN/exec1" ]
}

@test "does not remove other package directories and binaries" {
	test_util.mock_command plumbing-clone
	create_package username/package1
	create_exec username/package1 exec1
	create_package username/package2
	create_exec username/package2 exec2
	bpm-install username/package1
	bpm-install username/package2

	run bpm-uninstall username/package1
	assert_success
	[ -d "$BPM_PACKAGES_PATH/username/package2" ]
	[ -e "$BPM_INSTALL_BIN/exec2" ]
}
