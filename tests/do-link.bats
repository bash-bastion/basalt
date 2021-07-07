#!/usr/bin/env bats

load 'util/init.sh'

@test "fails with an invalid path" {
	run bpm-link invalid

	assert_failure
	assert_output -p "Directory 'invalid' not found"
}

@test "fails with a file path instead of a directory path" {
	touch file1

	run bpm-link file1

	assert_failure
	assert_output -p "Directory 'file1' not found"
}

@test "fails if package already present" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir -p subdir/theta
	bpm-link subdir/theta

	mkdir theta
	run bpm-link theta

	assert_failure
	assert_line -n 0 -p "Package 'bpm-local/theta' is already present"
}

@test "fails if package already present (as erroneous file)" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir -p touch "$BPM_PACKAGES_PATH/bpm-local"
	touch "$BPM_PACKAGES_PATH/bpm-local/theta"

	mkdir theta
	run bpm-link theta

	assert_failure
	assert_line -n 0 -p "Package 'bpm-local/theta' is already present"
}

@test "links the package to packages under the correct namespace" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package1

	run bpm-link package1

	assert_success
	assert [ "$(test_util.readlink $BPM_PACKAGES_PATH/bpm-local/package1)" = "$(test_util.readlink "$PWD/package1")" ]
}

@test "calls link-bins, link-completions, link-man and deps in order" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package2

	run bpm-link package2

	assert_success
	assert_line -n 0 -p "Linking '/tmp/bpm/cwd/package2'"
	assert_line -n 1 "bpm-plumbing-deps bpm-local/package2"
	assert_line -n 2 "bpm-plumbing-link-bins bpm-local/package2"
	assert_line -n 3 "bpm-plumbing-link-completions bpm-local/package2"
}

@test "respects --no-deps option, in order, with --nodeps" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package2

	run bpm-link --no-deps package2

	assert_success
	assert_line -n 0 -p "Linking '/tmp/bpm/cwd/package2'"
	assert_line -n 1 "bpm-plumbing-link-bins bpm-local/package2"
	assert_line -n 2 "bpm-plumbing-link-completions bpm-local/package2"
}


@test "respects --no-deps option" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package2

	run bpm-link --no-deps package2

	assert_success
	refute_line "bpm-plumbing-deps bpm-local/package2"
}

@test "resolves current directory (dot) path" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package3
	cd package3

	run bpm-link .

	assert_success
	assert [ "$(test_util.readlink "$BPM_PACKAGES_PATH/bpm-local/package3")" = "$(test_util.readlink "$PWD")" ]
}

@test "resolves parent directory (dotdot) path" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package3
	cd package3

	run bpm-link ../package3

	assert_success
	assert [ "$(test_util.readlink "$BPM_PACKAGES_PATH/bpm-local/package3")" = "$(test_util.readlink "$PWD")" ]
}

@test "resolves arbitrary complex relative path" {
	test_util.mock_command bpm-plumbing-deps
	test_util.mock_command bpm-plumbing-link-bins
	test_util.mock_command bpm-plumbing-link-completions

	mkdir package3

	run bpm-link ./package3/.././package3

	assert_success
	assert [ "$(test_util.readlink "$BPM_PACKAGES_PATH/bpm-local/package3")" = "$(test_util.readlink "$PWD/package3")" ]
}
