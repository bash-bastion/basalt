#!/usr/bin/env bats

load 'util/init.sh'

@test "links each man page to install-man under correct subdirectory" {
	create_package username/package
	create_man username/package exec.1
	create_man username/package exec.2
	test_util.mock_command _clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-man username/package
	echo "$output"
	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/username/package/man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/username/package/man/exec.2" ]
}