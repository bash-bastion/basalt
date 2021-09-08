#!/usr/bin/env bats

load './util/init.sh'

# TODO
# @test "exports BPM_REPO_SOURCE" {
# 	unset BPM_REPO_SOURCE
# 	eval "$(BPM_REPO_SOURCE=/lol bpm global init bash)"

# 	assert_success
# 	assert [ "$BPM_REPO_SOURCE" = '/lol' ]
# 	assert test_util.is_exported 'BPM_REPO_SOURCE'
# }

# @test "exports BPM_CELLAR" {
# 	unset BPM_CELLAR
# 	eval "$(BPM_CELLAR=/lol bpm global init bash)"

# 	assert_success
# 	assert [ "$BPM_CELLAR" = '/lol' ]
# 	assert test_util.is_exported 'BPM_CELLAR'
# }

@test "sources bpm-load for Bash" {
	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"

	eval "$(bpm global init bash)"

	assert_success
	assert [ "$(type -t bpm-load)" = 'function' ]
}


@test "sources bpm-load for Zsh" {
	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"

	eval "$(bpm global init zsh)"

	assert_success
	assert [ "$(type -t bpm-load)" = 'function' ]
}

@test "fails if shell is not available" {
	run bpm global init fakesh

	assert_failure
	assert_line -p "Shell 'fakesh' is not a valid shell"
}

@test "bash completion works" {
	! command -v _bpm

	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"

	eval "$(bpm global init bash)"

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
	run eval "$(bpm global init - sh)"
	assert_success
}
