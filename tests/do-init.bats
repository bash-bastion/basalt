#!/usr/bin/env bats

load './util/init.sh'

@test "exports BPM_ROOT" {
	test_util.reset_variables

	eval "$(BPM_ROOT=/lol bpm init bash)"

	test_util.is_exported BPM_ROOT
	[ "$BPM_ROOT" = "/lol" ]
}

@test "exports BPM_PREFIX" {
	test_util.reset_variables

	eval "$(BPM_PREFIX=/lol bpm init bash)"

	test_util.is_exported BPM_PREFIX
	[ "$BPM_PREFIX" = "/lol" ]
}

@test "exports BPM_PACKAGES_PATH" {
	test_util.reset_variables

	eval "$(BPM_PACKAGES_PATH=/lol bpm init bash)"

	test_util.is_exported BPM_PACKAGES_PATH
	[ "$BPM_PACKAGES_PATH" = "/lol" ]
}

@test "errors if shell is not available" {
	test_util.reset_variables

	run bpm-init fakesh
	assert_failure
	assert_line -e "Shell 'fakesh' is not a valid shell"
}

@test "bash completion works" {
	test_util.reset_variables

	! command -v _bpm

	eval "$(bpm init bash)"

	command -v _bpm
}

@test "is fish compatible" {
	test_util.reset_variables

	if ! command -v fish &>/dev/null; then
		skip "Command 'fish' not in PATH"
	fi

	HOME= XDG_DATA_HOME= XDG_CONFIG_HOME= run fish -Pc '. (bpm init fish | psub)'
}

@test "is sh-compatible" {
	test_util.reset_variables

	if ! command -v sh &>/dev/null; then
		skip "Command 'sh' not in PATH"
	fi

	run sh -ec 'eval "$(bpm init - sh)"'
	assert_success
}
