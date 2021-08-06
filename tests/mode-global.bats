#!/usr/bin/env bats

load 'util/init.sh'

@test "print operating in local dir if not in global mode" {
	touch 'bpm.toml'

	BPM_MODE='local' run do-list
	assert_success
	assert_output -p "Operating in context of local bpm.toml"
}

# We only test two of all commands
@test "error when not passing --global to add, list, and upgrade" {
	local str="No 'bpm.toml' file found"

	run bpm add foo
	assert_failure
	assert_line -p "$str"

	run bpm list
	assert_failure
	assert_line -p "$str"

	run bpm upgrade
	assert_failure
	assert_line -p "$str"
}

@test "do not error with bpm.toml when not passing --global to list" {
	touch 'bpm.toml'

	run bpm list
	assert_success
}

@test "do not error when not passing --global to list, complete, and init" {
	touch 'bpm.toml'

	run do-list
	assert_success
	assert_output ""

	run bpm complete package-path
	assert_success

	run bpm init bash
	assert_success
	assert_line -p "export PATH"
	assert_line -p '. "$BPM_REPO_SOURCE/'
}
