#!/usr/bin/env bats

load 'util/init.sh'

@test "removes each man page from the install-man" {
	local package="username/package"

	create_package username/package
	create_man username/package exec.1
	create_man username/package exec.2
	test_util.fake_clone "$package"

	run do-plumbing-unlink-man username/package

	assert_success
	assert [ ! -e "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" ]
	assert [ ! -e "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" ]
}
