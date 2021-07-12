#!/usr/bin/env bats

load 'util/init.sh'

@test "fails with an invalid path" {
	run do-link invalid

	assert_failure
	assert_output -p "Directory 'invalid' not found"
}

@test "fails with a file" {
	touch 'file1'

	run do-link 'file1'

	assert_failure
	assert_output -p "Directory 'file1' not found"
}

@test "fails if package already present" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local pkg1='subdir/theta'
	local pkg2='theta'

	mkdir -p "$pkg1"
	git -C "$pkg1" init
	do-link "$pkg1"

	mkdir "$pkg2"
	git -C "$pkg2" init
	run do-link "$pkg2"

	assert_failure
	assert_line -n 0 -p "Package 'local/theta' is already present"
}

@test "fails if not a Git repository" {
	mkdir -p "$BPM_ORIGIN_DIR/$pkg"

	run do-link "$BPM_ORIGIN_DIR/$pkg"

	assert_failure
	assert_line -n 0 -p "Package must be a Git repository"
}

@test "fails if package already present (as erroneous file)" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	mkdir -p touch "$BPM_PACKAGES_PATH/local"
	touch "$BPM_PACKAGES_PATH/local/theta"

	test_util.create_pkg_dir 'theta'
	mkdir 'theta'

	run do-link "$BPM_ORIGIN_DIR/theta"

	assert_failure
	assert_line -n 0 -p "Package 'local/theta' is already present"
}

@test "links the package to packages under the correct namespace (local)" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package1'

	test_util.create_pkg_dir "$dir"

	run do-link "$BPM_ORIGIN_DIR/$dir"

	assert_success
	assert [ "$(readlink -f $BPM_PACKAGES_PATH/local/package1)" = "$(readlink -f "$BPM_ORIGIN_DIR/$dir")" ]
}

@test "calls link-bins, link-completions, link-man and deps in order" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "$dir"

	run do-link "$(util.readlink "$BPM_ORIGIN_DIR/$dir")"

	assert_success
	assert_line -n 0 -p "Linking '$BPM_ORIGIN_DIR/$dir'"
	assert_line -n 1 "do-plumbing-add-deps local/$dir"
	assert_line -n 2 "do-plumbing-link-bins local/$dir"
	assert_line -n 3 "do-plumbing-link-completions local/$dir"
	assert_line -n 4 "do-plumbing-link-man local/$dir"

}

@test "calls link-bins, link-completions, link-man and deps in order for multiple directories" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir1='package2'
	local dir2='package3'

	test_util.create_pkg_dir "$dir1"
	test_util.create_pkg_dir "$dir2"

	run do-link "$(util.readlink "$BPM_ORIGIN_DIR/$dir1")" "$(test_util.readlink "$BPM_ORIGIN_DIR/$dir2")"

	assert_success
	assert_line -n 0 -p "Linking '$BPM_ORIGIN_DIR/$dir1'"
	assert_line -n 1 "do-plumbing-add-deps local/$dir1"
	assert_line -n 2 "do-plumbing-link-bins local/$dir1"
	assert_line -n 3 "do-plumbing-link-completions local/$dir1"
	assert_line -n 4 "do-plumbing-link-man local/$dir1"
	assert_line -n 5 -p "Linking '$BPM_ORIGIN_DIR/$dir2'"
	assert_line -n 6 "do-plumbing-add-deps local/$dir2"
	assert_line -n 7 "do-plumbing-link-bins local/$dir2"
	assert_line -n 8 "do-plumbing-link-completions local/$dir2"
	assert_line -n 9 "do-plumbing-link-man local/$dir2"

}

@test "respects the --no-deps option in the correct order" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "$dir"

	run do-link --no-deps "$BPM_ORIGIN_DIR/$dir"

	assert_success
	assert_line -n 0 -p "Linking '$BPM_ORIGIN_DIR/$dir'"
	assert_line -n 1 "do-plumbing-link-bins local/$dir"
	assert_line -n 2 "do-plumbing-link-completions local/$dir"
	assert_line -n 3 "do-plumbing-link-man local/$dir"
}


@test "respects the --no-deps option" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "$dir"

	run do-link --no-deps "$BPM_ORIGIN_DIR/$dir"

	assert_success
	refute_line "do-plumbing-add-deps local/package2"
}

@test "respects the --no-deps option (at end)" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "$dir"

	run do-link "$BPM_ORIGIN_DIR/$dir" --no-deps

	assert_success
	refute_line "do-plumbing-add-deps local/package2"
}

@test "links the current directory" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "$dir"

	cd "$BPM_ORIGIN_DIR/$dir"
	run do-link .

	assert_success
	assert [ "$(readlink -f "$BPM_PACKAGES_PATH/local/$dir")" = "$(readlink -f "$BPM_ORIGIN_DIR/$dir")" ]
}

@test "links the parent directory" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "$dir"

	cd "$BPM_ORIGIN_DIR/$dir"
	mkdir -p 'tango'
	cd 'tango'

	run do-link ..

	assert_success
	assert [ "$(readlink -f "$BPM_PACKAGES_PATH/local/$dir")" = "$(readlink -f "$BPM_ORIGIN_DIR/$dir")" ]
}

@test "links an arbitrary complex relative path" {
	test_util.mock_command do-plumbing-add-deps
	test_util.mock_command do-plumbing-link-bins
	test_util.mock_command do-plumbing-link-completions
	test_util.mock_command do-plumbing-link-man

	local dir='package2'

	test_util.create_pkg_dir "parent/$dir"

	cd "$BPM_ORIGIN_DIR/parent"
	run do-link "./$dir/.././$dir"

	assert_success
	assert [ "$(readlink -f "$BPM_PACKAGES_PATH/local/$dir")" = "$(readlink -f "$BPM_ORIGIN_DIR/parent/$dir")" ]
}
