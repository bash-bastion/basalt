#!/usr/bin/env bats

load './util/init.sh'

@test "exports BPM_ROOT" {
	unset BPM_ROOT
	eval "$(BPM_ROOT=/lol do-init bash)"

	assert_success
	assert [ "$BPM_ROOT" = '/lol' ]
	assert test_util.is_exported 'BPM_ROOT'
}


@test "exports BPM_CELLAR" {
	BPM_CELLAR=/lol run do-init bash

	assert_success
	assert_line -p 'export BPM_CELLAR="/lol"'
}


@test "errors if shell is not available" {
	run do-init fakesh

	assert_failure
	assert_line -p "Shell 'fakesh' is not a valid shell"
}

@test "bash completion works" {
	! command -v _bpm

	eval "$(do-init bash)"

	assert command -v _bpm
}

@test "is fish compatible" {
	if ! command -v fish &>/dev/null; then
		skip "Command 'fish' not in PATH"
	fi

	HOME= XDG_DATA_HOME= XDG_STATE_HOME= XDG_CONFIG_HOME= run fish -Pc '. (bpm init fish | psub)'

	assert_success
}

@test "is sh-compatible" {
	run eval "$(do-init - sh)"
	assert_success
}
