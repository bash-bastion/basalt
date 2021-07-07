#!/usr/bin/env bats

load 'util/init.sh'

# @description Creates man pages in the root directory
create.man_root() {
	: "${1?"create.man1 Args required"}"

	cd "$BPM_ORIGIN_DIR/$package"

	touch "$1"
	git add .
	git commit -m "Add $1"

	cd "$BPM_CWD"
}

@test "links each man page to install-man under correct subdirectory" {
	create_package username/package
	create_man username/package exec.1
	create_man username/package exec.2
	test_util.mock_command plumbing-clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-man username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/username/package/man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/username/package/man/exec.2" ]
}

@test "links each top-level man page to install-man under correct subdirectory" {
	local package="username/package"

	create_package username/package
	create.man_root 'prog.1'

	test_util.mock_command plumbing-clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-man username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/prog.1")" = "$BPM_PACKAGES_PATH/$package/prog.1" ]
}
