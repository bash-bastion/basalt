#!/usr/bin/env bats

load './util/init.sh'

# TODO: test effect rather than output

@test "exports BPM_ROOT" {
	BPM_ROOT=/lol run basher-init bash
	assert_success
	assert_line -n 0 'export BPM_ROOT="/lol"'
}

@test "exports BPM_PREFIX" {
	BPM_PREFIX=/lol run basher-init bash
	assert_success
	assert_line -n 1 'export BPM_PREFIX="/lol"'
}

@test "exports BPM_PACKAGES_PATH" {
	BPM_PACKAGES_PATH=/lol/packages run basher-init bash
	assert_success
	assert_line -n 2 'export BPM_PACKAGES_PATH="/lol/packages"'
}

@test "doesn't setup include function if it doesn't exist" {
	run basher-init fakesh
	refute_line 'source "$BPM_ROOT/lib/include.fakesh"'
}

@test "does not setup basher completions if not available" {
	run basher-init fakesh
	assert_failure
	assert_line -e "Shell 'fakesh' is not a valid shell"
}

hasShell() {
	command -v "$1" &>/dev/null
}

@test "is sh-compatible" {
	if ! hasShell sh; then
		skip "sh was not found in path."
	fi

	run sh -ec 'eval "$(bpm init - sh)"'
	assert_success
}
