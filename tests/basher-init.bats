#!/usr/bin/env bats

load './util/init.sh'

# TODO: test effect rather than output

@test "exports BASHER_ROOT" {
	BASHER_ROOT=/lol run basher-init bash
	assert_success
	assert_line -n 1 'export BASHER_ROOT=/lol'
}

@test "exports BASHER_PREFIX" {
	BASHER_PREFIX=/lol run basher-init bash
	assert_success
	assert_line -n 2 'export BASHER_PREFIX=/lol'
}

@test "exports BASHER_PACKAGES_PATH" {
	BASHER_PACKAGES_PATH=/lol/packages run basher-init bash
	assert_success
	assert_line -n 3 'export BASHER_PACKAGES_PATH=/lol/packages'
}

@test "doesn't setup include function if it doesn't exist" {
	run basher-init fakesh
	refute_line 'source "$BASHER_ROOT/lib/include.fakesh"'
}

@test "does not setup basher completions if not available" {
	run basher-init fakesh
	assert_success
	refute_line 'source "$BASHER_ROOT/completions/basher.fakesh"'
	refute_line 'source "$BASHER_ROOT/completions/basher.other"'
}

hasShell() {
	which "$1" >>/dev/null 2>&1
}

@test "is sh-compatible" {
	if ! hasShell sh; then
		skip "sh was not found in path."
	fi

	run sh -ec 'eval "$(neobasher init - sh)"'
	assert_success
}
