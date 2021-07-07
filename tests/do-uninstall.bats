#!/usr/bin/env bats

load 'util/init.sh'

@test "fails if package is not installed" {
	run do-uninstall user/lol

	assert_failure
	assert_output -e "Package 'user/lol' is not installed"
}

@test "removes package directory" {
	local package="username/package"

	create_package 'username/package'
	test_util.fake_clone 'username/package'
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-uninstall 'username/package'

	assert_success
	[ ! -d "$BPM_PACKAGES_PATH/username/package" ]
}

@test "removes package directory (if it happens to be a file)" {
	mkdir -p "$BPM_PACKAGES_PATH/theta"
	touch "$BPM_PACKAGES_PATH/theta/tango"

	run do-uninstall 'theta/tango'

	assert_success
	[ ! -e "$BPM_PACKAGES_PATH/username/package" ]
}

@test "removes binaries" {
	local package="username/package"

	create_package 'username/package'
	create_exec 'username/package' exec1
	test_util.fake_clone 'username/package'
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-uninstall 'username/package'

	assert_success
	[ ! -e "$BPM_INSTALL_BIN/exec1" ]
}

@test "does not remove other package directories and binaries" {
	create_package 'username/package1'
	create_package 'username/package2'
	create_exec 'username/package1' exec1
	create_exec 'username/package2' exec2
	do-link "$BPM_ORIGIN_DIR/username/package1"
	do-link "$BPM_ORIGIN_DIR/username/package2"

	run do-uninstall 'bpm-local/package1'

	assert_success
	[ ! -d "$BPM_PACKAGES_PATH/bpm-local/package1" ]
	[ ! -e "$BPM_INSTALL_BIN/exec1" ]
	[ -d "$BPM_PACKAGES_PATH/bpm-local/package2" ]
	[ -e "$BPM_INSTALL_BIN/exec2" ]
}
