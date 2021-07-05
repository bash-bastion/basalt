#!/usr/bin/env bats

load 'util/init.sh'

@test "links bash completions to prefix/completions" {
	create_package username/package
	create_bash_completions username/package comp.bash
	mock.command _clone
	basher-plumbing-clone false site username/package


	run basher-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink "$NEOBASHER_PREFIX/completions/bash/comp.bash")" = "$NEOBASHER_PACKAGES_PATH/username/package/completions/comp.bash" ]
}

@test "links zsh compsys completions to prefix/completions" {
	create_package username/package
	create_zsh_compsys_completions username/package _exec
	mock.command _clone
	basher-plumbing-clone false site username/package

	run basher-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink $NEOBASHER_PREFIX/completions/zsh/compsys/_exec)" = "$NEOBASHER_PACKAGES_PATH/username/package/completions/_exec" ]
}

@test "links zsh compctl completions to prefix/completions" {
	create_package username/package
	create_zsh_compctl_completions username/package exec
	mock.command _clone
	basher-plumbing-clone false site username/package

	run basher-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink $NEOBASHER_PREFIX/completions/zsh/compctl/exec)" = "$NEOBASHER_PACKAGES_PATH/username/package/completions/exec" ]
}

@test "does not fail if package doesn't have any completions" {
	create_package username/package
	mock.command _clone
	basher-plumbing-clone false site username/package

	run basher-plumbing-link-completions username/package

	assert_success
}
