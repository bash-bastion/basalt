#!/usr/bin/env bats

load 'util/init.sh'

@test "removes each binary in BINS config from the install bin" {
	create_package username/package
	create_package_exec username/package exec1
	create_package_exec username/package exec2.sh
	test_util.mock_command plumbing-clone
	bpm-install username/package

	run bpm-plumbing-unlink-bins username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}

@test "removes each binary from the install bin" {
	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	test_util.mock_command plumbing-clone
	bpm-install username/package

	run bpm-plumbing-unlink-bins username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}

@test "removes root binaries from the install bin" {
	create_package username/package
	create_root_exec username/package exec3
	create_root_exec username/package exec4.sh
	test_util.mock_command plumbing-clone
	bpm-install username/package

	run bpm-plumbing-unlink-bins username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec3)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec4.sh)" ]
}

@test "doesn't remove root binaries if there is a bin folder" {
	create_package username/package
	create_root_exec username/package exec3
	test_util.mock_command plumbing-clone
	bpm-install username/package
	mkdir "$BPM_PACKAGES_PATH/username/package/bin"

	run bpm-plumbing-unlink-bins username/package
	assert_success
	assert [ -e "$(readlink $BPM_INSTALL_BIN/exec3)" ]
}

@test "doesn't remote root bins or files in bin folder if there is a BINS config on package.sh" {
	skip

	test_util.mock_command plumbing-clone

	create_package username/package
	create_package_exec username/package exec1
	create_exec username/package exec2
	create_root_exec username/package exec3
	bpm-install username/package


	create_package username/package2
	create_root_exec username/package2 exec2
	bpm-install username/package2

	create_package username/package3
	create_exec username/package3 exec3
	bpm-install username/package3

	run bpm-plumbing-unlink-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
	assert [ -e "$(readlink $BPM_INSTALL_BIN/exec3)" ]
}

@test "does not fail if there are no binaries" {
	create_package username/package
	test_util.mock_command plumbing-clone
	bpm-install username/package

	run bpm-plumbing-unlink-bins username/package

	assert_success
}

@test "removes binary when REMOVE_EXTENSION is true" {
	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package true
	test_util.mock_command plumbing-clone
	bpm-install username/package

	run bpm-plumbing-unlink-bins username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
}

@test "removes binary when REMOVE_EXTENSION is false" {
	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package false
	test_util.mock_command plumbing-clone
	bpm-install username/package

	run bpm-plumbing-unlink-bins username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}
