#!/usr/bin/env bats

load 'util/init.sh'

@test "links each file on the BINS config on package.sh to the install bin" {
	create_package username/package
	create_package_exec username/package exec1
	create_package_exec username/package exec2.sh
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/username/package/package_bin/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2.sh)" = "$BPM_PACKAGES_PATH/username/package/package_bin/exec2.sh" ]
}

@test "links each file inside bin folder to install bin" {
	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/username/package/bin/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2.sh)" = "$BPM_PACKAGES_PATH/username/package/bin/exec2.sh" ]
}

@test "links each exec file in package root to install bin" {
	create_package username/package
	create_root_exec username/package exec3
	create_root_exec username/package exec4.sh
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec3)" = "$BPM_PACKAGES_PATH/username/package/exec3" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec4.sh)" = "$BPM_PACKAGES_PATH/username/package/exec4.sh" ]
}

@test "doesn't link root bins if there is a bin folder" {
	create_package username/package
	create_exec username/package exec1
	create_root_exec username/package exec2
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/username/package/bin/exec1" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
}

@test "doesn't link root bins or files in bin folder if there is a BINS config on package.sh" {
	create_package username/package
	create_exec username/package exec1
	create_root_exec username/package exec2
	create_package_exec username/package exec3
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec3)" = "$BPM_PACKAGES_PATH/username/package/package_bin/exec3" ]
}

@test "does not fail if there are no binaries" {
	create_package username/package
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
}

@test "remove extension if REMOVE_EXTENSION is true" {
	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package true
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/username/package/bin/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2)" = "$BPM_PACKAGES_PATH/username/package/bin/exec2.sh" ]
}

@test "does not remove extension if REMOVE_EXTENSION is false" {
	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package false
	test_util.mock_command _clone
	basher-plumbing-clone false site username package

	run basher-plumbing-link-bins username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/username/package/bin/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2.sh)" = "$BPM_PACKAGES_PATH/username/package/bin/exec2.sh" ]
}

@test "does not symlink package itself as bin when linked with basher link" {
	mkdir package
	# implicit call to basher-plumbing-link-bins
	run basher-link package username/package
	assert_success
	assert [ ! -e "$BPM_PREFIX/bin/package" ]
}
