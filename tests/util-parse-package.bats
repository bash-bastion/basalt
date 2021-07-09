#!/usr/bin/env bats

load 'util/init.sh'


@test "fails on no arguments" {
	run util.parse_package_full

	assert_failure
	assert_line -p "Must supply a repository"
}

# TODO: do more
