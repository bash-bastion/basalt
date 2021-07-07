#!/usr/bin/env bats

load 'util/init.sh'

@test "removes each binary in BINS config from the install bin" {
	local package="username/package"

	create_package username/package
	create_package_exec username/package exec1
	create_package_exec username/package exec2.sh
	test_util.fake_clone "$package"

	run do-plumbing-unlink-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}

@test "removes each binary from the install bin" {
	local package="username/package"

	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	test_util.fake_clone "$package"

	run do-plumbing-unlink-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}

@test "removes root binaries from the install bin" {
	local package="username/package"

	create_package username/package
	create_root_exec username/package exec3
	create_root_exec username/package exec4.sh
	test_util.fake_clone "$package"

	run do-plumbing-unlink-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec3)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec4.sh)" ]
}

@test "does not fail if there are no binaries" {
	local package="username/package"

	create_package username/package
	test_util.fake_clone "$package"

	run do-plumbing-unlink-bins username/package

	assert_success
}

@test "removes binary when REMOVE_EXTENSION is true" {
	local package="username/package"

	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package true
	test_util.fake_clone "$package"

	run do-plumbing-unlink-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
}

@test "removes binary when REMOVE_EXTENSION is false" {
	local package="username/package"

	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package false
	test_util.fake_clone "$package"

	run do-plumbing-unlink-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}
