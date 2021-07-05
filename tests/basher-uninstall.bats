#!/usr/bin/env bats

load 'util/init.sh'

@test "fails if package is not installed" {
	run basher-uninstall user/lol
	assert_failure
	assert_output -e "Package 'user/lol' is not installed"
}

@test "removes package directory" {
	mock.command _clone
	create_package username/package
	basher-install username/package

	run basher-uninstall username/package
	assert_success
	[ ! -d "$BASHER_PACKAGES_PATH/username/package" ]
}

@test "removes binaries" {
	mock.command _clone
	create_package username/package
	create_exec username/package exec1
	basher-install username/package

	run basher-uninstall username/package
	assert_success
	[ ! -e "$BASHER_INSTALL_BIN/exec1" ]
}

@test "does not remove other package directories and binaries" {
	mock.command _clone
	create_package username/package1
	create_exec username/package1 exec1
	create_package username/package2
	create_exec username/package2 exec2
	basher-install username/package1
	basher-install username/package2

	run basher-uninstall username/package1
	assert_success
	[ -d "$BASHER_PACKAGES_PATH/username/package2" ]
	[ -e "$BASHER_INSTALL_BIN/exec2" ]
}
