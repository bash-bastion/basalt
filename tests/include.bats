#!/usr/bin/env bats

load 'util/init.sh'

@test "with no arguments, prints an error" {
	eval "$(do-init sh)"

	run include

	assert_failure
	assert_output -p "Usage: include <package> <file>"
}

@test "with one argument, prints an error" {
	eval "$(do-init sh)"

	run include 'user/repo'

	assert_failure
	assert_output -p "Usage: include <package> <file>"
}

@test "when package is not installed, prints an error" {
	local site='github.com'
	local pkg='user/repo'

	eval "$(do-init sh)"

	run include "$site/$pkg" file

	assert_failure
	assert_output -p "Package '$site/$pkg' not installed"
}

@test "when file doesn't exist, prints an error" {
	local site='github.com'
	local pkg='username/repo'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg

	test_util.fake_add "$pkg"

	eval "$(do-init sh)"

	run include "$site/$pkg" non_existent

	assert_failure
	assert_output -p "File '$BPM_PREFIX/packages/$site/$pkg/non_existent' not found"
}

@test "when file does exist, properly source file" {
	local site='github.com'
	local pkg='username/repo'

	test_util.setup_pkg "$pkg"; {
		echo "func_name() { echo 'done'; }" > 'function.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	eval "$(do-init sh)"
	include "$site/$pkg" 'function.sh'

	run func_name

	assert_success
	assert_output "done"
}
