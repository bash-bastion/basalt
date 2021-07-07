#!/usr/bin/env bats

load 'util/init.sh'

@test "without arguments, prints an error" {
	eval "$(do-init sh)"
	run include
	assert_failure
	assert_output -p "Usage: include <package> <file>"
}

@test "with one argument, prints an error" {
	eval "$(do-init sh)"
	run include user/repo
	assert_failure
	assert_output -p "Usage: include <package> <file>"
}

@test "when package is not installed, prints an error" {
	eval "$(do-init sh)"
	run include user/repo file
	assert_failure
	assert_output -p "Package not installed: user/repo"
}

@test "when file doesn't exist, prints an error" {
	local package='username/repo'

	create_package "$package"
	test_util.fake_install "$package"

	eval "$(do-init sh)"

	run include "$package" non_existent

	assert_failure
	assert_output -p "File '$BPM_PREFIX/packages/$package/non_existent' not found"
}

@test "sources a file into the current shell" {
	local package='username/repo'

	create_package "$package"
	create_file "$package" function.sh "func_name() { echo DONE; }"
	test_util.fake_install "$package"

	eval "$(do-init sh)"
	include "$package" function.sh

	run func_name

	assert_success
	assert_output "DONE"
}
