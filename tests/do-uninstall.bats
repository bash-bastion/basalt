#!/usr/bin/env bats

load 'util/init.sh'

@test "fails if package is not installed" {
	run do-uninstall user/lol

	assert_failure
	assert_output -e "Package 'user/lol' is not installed"
}

@test "removes package directory" {
	test_util.mock_command plumbing-clone
	create_package username/package
	do-install username/package

	run do-uninstall username/package

	assert_success
	[ ! -d "$BPM_PACKAGES_PATH/username/package" ]
}

@test "removes package directory (if it happens to be a file)" {
	mkdir -p "$BPM_PACKAGES_PATH/theta"
	touch "$BPM_PACKAGES_PATH/theta/tango"

	run do-uninstall theta/tango

	assert_success
	[ ! -e "$BPM_PACKAGES_PATH/username/package" ]
}

@test "removes binaries" {
	test_util.mock_command plumbing-clone
	create_package username/package
	create_exec username/package exec1
	do-install username/package

	run do-uninstall username/package

	assert_success
	[ ! -e "$BPM_INSTALL_BIN/exec1" ]
}

@test "does not remove other package directories and binaries" {
	test_util.mock_command plumbing-clone
	create_package username/package1
	create_exec username/package1 exec1
	create_package username/package2
	create_exec username/package2 exec2
	do-install username/package1
	do-install username/package2

	run do-uninstall username/package1

	assert_success
	[ -d "$BPM_PACKAGES_PATH/username/package2" ]
	[ -e "$BPM_INSTALL_BIN/exec2" ]
}
