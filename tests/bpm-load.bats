#!/usr/bin/env bats

load 'util/init.sh'

@test "works without file argument" {
	local site='github.com'
	local pkg="user/project2"

	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"
	BPM_CELLAR="$BPM_TEST_DIR/cellar"

	test_util.setup_pkg "$pkg"; {
		echo "printf '%s\n' 'it works :)'" > 'load.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	source bpm-load
	run bpm-load --global "$pkg"

	assert_success
	assert_output "it works :)"
}

@test "works with file argument" {
	local site='github.com'
	local pkg="user/project2"

	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"
	BPM_CELLAR="$BPM_TEST_DIR/cellar"

	test_util.setup_pkg "$pkg"; {
		echo "printf '%s\n' 'it works :)'" > 'file.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	source bpm-load
	run bpm-load --global "$pkg" 'file.bash'

	assert_success
	assert_output "it works :)"
}

@test "errors if used incorrectly (soucing with arguments passed)" {
	local site='github.com'
	local pkg="user/project2"

	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"
	BPM_CELLAR="$BPM_TEST_DIR/cellar"

	test_util.setup_pkg "$pkg"; {
		echo "printf '%s\n' 'it works :)'" > 'load.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run source bpm-load --global "$pkg"

	assert_failure
	assert_line -p "Incorrect usage. See documentation"
}

@test "errors if used incorrectly (running function with no arguments passed)" {
	local site='github.com'
	local pkg="user/project2"

	BPM_REPO_SOURCE="$BPM_TEST_REPO_ROOT/../source"
	BPM_CELLAR="$BPM_TEST_DIR/cellar"

	test_util.setup_pkg "$pkg"; {
		echo "printf '%s\n' 'it works :)'" > 'load.bash'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	source bpm-load
	run bpm-load

	assert_failure
	assert_line -p "Error: Must pass in package name as first parameter"
}
