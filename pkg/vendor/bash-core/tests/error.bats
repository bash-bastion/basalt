#!/usr/bin/env bats

load './util/init.sh'

@test "core.err_exists works when set" {
	# Function sets error when it fails
	core.err_set 1 "Failed to eat grass"

	# Callsite notices failure, and checks error
	core.err_exists
}

@test "core.err_exists works when not set 1" {
	! core.err_exists
}

@test "core.err_exists works when not set 2" {
	core.err_clear

	! core.err_exists
}

@test "core.err_set sets variables correctly" {
	core.err_set 2 "value_woof"

	[ "$ERRCODE" = 2 ]
	[ "$ERR" = 'value_woof' ]
}
