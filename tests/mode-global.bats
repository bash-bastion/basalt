#!/usr/bin/env bats

load 'util/init.sh'

@test "print operating in local dir if not in global mode" {
	touch 'basalt.toml'

	run basalt list
	assert_success
	assert_output -p "Operating in context of local basalt.toml"
}

# We only test two of all commands
@test "error when not passing --global to add, list, and upgrade" {
	local str="No 'basalt.toml' file found"

	run basalt add foo
	assert_failure
	assert_line -p "$str"

	run basalt list
	assert_failure
	assert_line -p "$str"

	run basalt upgrade
	assert_failure
	assert_line -p "$str"
}

@test "do not error with basalt.toml when not passing --global to list" {
	touch 'basalt.toml'

	run basalt list
	assert_success
}

@test "do not error when not passing --global to list, complete, and init" {
	touch 'basalt.toml'

	run basalt global list
	assert_success
	assert_output ""

	run basalt complete package-path
	assert_success

	run basalt init bash
	assert_success
	assert_line -p "export PATH"
	assert_line -p '. "$BASALT_REPO_SOURCE/'
}
