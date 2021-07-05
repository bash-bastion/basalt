#!/usr/bin/env bats

load 'util/init.sh'

@test "fails with an invalid path" {
	run basher-link invalid
	assert_failure
	assert_output -e "Directory 'invalid' not found"
}

@test "fails with a file path instead of a directory path" {
	touch file1
	run basher-link file1
	assert_failure
	assert_output -e "Directory 'file1' not found"
}

@test "links the package to packages under the correct namespace" {
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-deps
	mkdir package1
	run basher-link package1
	assert_success
	assert [ "$(test_util.resolve_link $BPM_PACKAGES_PATH/bpm-local/package1)" = "$(test_util.resolve_link "$(pwd)/package1")" ]
}

@test "calls link-bins, link-completions, link-man and deps" {
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-deps
	mkdir package2
	run basher-link package2
	assert_success
	assert_line "basher-plumbing-link-bins bpm-local/package2"
	assert_line "basher-plumbing-link-completions bpm-local/package2"
	assert_line "basher-plumbing-link-completions bpm-local/package2"
	assert_line "basher-plumbing-deps bpm-local/package2"
}

@test "respects --no-deps option" {
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-deps
	mkdir package2
	run basher-link --no-deps package2
	assert_success
	refute_line "basher-plumbing-deps bpm-local/package2"
}

@test "resolves current directory (dot) path" {
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-deps
	mkdir package3
	cd package3
	run basher-link .
	assert_success
	assert [ "$(test_util.resolve_link "$BPM_PACKAGES_PATH/bpm-local/package3")" = "$(test_util.resolve_link "$(pwd)")" ]
}

@test "resolves parent directory (dotdot) path" {
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-deps
	mkdir package3
	cd package3
	run basher-link ../package3
	assert_success
	assert [ "$(test_util.resolve_link "$BPM_PACKAGES_PATH/bpm-local/package3")" = "$(test_util.resolve_link "$(pwd)")" ]
}

@test "resolves arbitrary complex relative path" {
	test_util.mock_command basher-plumbing-link-bins
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-link-completions
	test_util.mock_command basher-plumbing-deps
	mkdir package3
	run basher-link ./package3/.././package3
	assert_success
	assert [ "$(test_util.resolve_link "$BPM_PACKAGES_PATH/bpm-local/package3")" = "$(test_util.resolve_link "$(pwd)/package3")" ]
}
