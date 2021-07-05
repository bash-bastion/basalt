#!/usr/bin/env bats

load './util/init.sh'

# TODO: test effect rather than output

@test "exports NEOBASHER_ROOT" {
	NEOBASHER_ROOT=/lol run basher-init bash
	assert_success
	assert_line -n 1 'export NEOBASHER_ROOT=/lol'
}

@test "exports NEOBASHER_PREFIX" {
	NEOBASHER_PREFIX=/lol run basher-init bash
	assert_success
	assert_line -n 2 'export NEOBASHER_PREFIX=/lol'
}

@test "exports NEOBASHER_PACKAGES_PATH" {
	NEOBASHER_PACKAGES_PATH=/lol/packages run basher-init bash
	assert_success
	assert_line -n 3 'export NEOBASHER_PACKAGES_PATH=/lol/packages'
}

@test "doesn't setup include function if it doesn't exist" {
	run basher-init fakesh
	refute_line 'source "$NEOBASHER_ROOT/lib/include.fakesh"'
}

@test "does not setup basher completions if not available" {
	run basher-init fakesh
	assert_success
	refute_line 'source "$NEOBASHER_ROOT/completions/basher.fakesh"'
	refute_line 'source "$NEOBASHER_ROOT/completions/basher.other"'
}

hasShell() {
	command -v "$1" &>/dev/null
}

@test "is sh-compatible" {
	if ! hasShell sh; then
		skip "sh was not found in path."
	fi

	run sh -ec 'eval "$(neobasher init - sh)"'
	assert_success
}
