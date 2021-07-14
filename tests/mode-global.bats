#!/usr/bin/env bats

load 'util/init.sh'

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
	assert_output ""
}

@test "do not error when not passing --global to echo, complete, and init" {
	touch 'bpm.toml'

	run bpm echo "PWD"
	assert_success
	assert_output "$PWD"

	run bpm complete package-path
	assert_success
	assert_output ""

	run bpm init bash
	assert_success
	assert_line -p "export PATH"
	assert_line -p '. "$BPM_ROOT/'
}
