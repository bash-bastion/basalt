#!/usr/bin/env bats

load 'util/init.sh'

@test "unlinks bash completions from prefix/completions" {
	create_package username/package
	create_bash_completions username/package comp.bash
	test_util.mock_command _clone
	basher-install username/package

	run basher-plumbing-unlink-completions username/package
	assert_success
	assert [ ! -e "$($BPM_PREFIX/completions/bash/comp.bash)" ]
}

@test "unlinks zsh compsys completions from prefix/completions" {
	create_package username/package
	create_zsh_compsys_completions username/package _exec
	test_util.mock_command _clone
	basher-install username/package

	run basher-plumbing-unlink-completions username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_PREFIX/completions/zsh/compsys/_exec)" ]
}

@test "unlinks zsh compctl completions from prefix/completions" {
	create_package username/package
	create_zsh_compctl_completions username/package exec
	test_util.mock_command _clone
	basher-install username/package

	run basher-plumbing-unlink-completions username/package
	assert_success
	assert [ ! -e "$(readlink $BPM_PREFIX/completions/zsh/compctl/exec)" ]
}
