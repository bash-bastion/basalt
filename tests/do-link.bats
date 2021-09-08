#!/usr/bin/env bats

load 'util/init.sh'

@test "fails with an invalid path" {
	run bpm global link invalid

	assert_failure
	assert_output -p "Directory 'invalid' not found"
}

@test "fails with a file" {
	touch 'file1'

	run bpm global link 'file1'

	assert_failure
	assert_output -p "Directory 'file1' not found"
}

@test "fails if package already present" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local pkg1='subdir/theta'
	local pkg2='theta'

	mkdir -p "$pkg1"
	git -C "$pkg1" init
	do-link "$pkg1"

	mkdir "$pkg2"
	git -C "$pkg2" init
	run bpm global link "$pkg2"

	assert_failure
	assert_line -n 0 -p "Package 'local/theta' is already present"
}

@test "fails if not a Git repository" {
	mkdir -p "$BPM_ORIGIN_DIR/$pkg"

	run bpm global link "$BPM_ORIGIN_DIR/$pkg"

	assert_failure
	assert_line -n 0 -p "Package must be a Git repository"
}

@test "fails if package already present (as erroneous file)" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	mkdir -p touch "$BPM_PACKAGES_PATH/local"
	touch "$BPM_PACKAGES_PATH/local/theta"

	test_util.create_package 'theta'
	mkdir 'theta'

	run bpm global link "$BPM_ORIGIN_DIR/theta"

	assert_failure
	assert_line -n 0 -p "Package 'local/theta' is already present"
}

@test "links the package to packages under the correct namespace (local)" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local dir='package1'

	test_util.create_package "$dir"

	run bpm global link "$BPM_ORIGIN_DIR/$dir"

	assert_success
	assert [ "$(readlink -f $BPM_PACKAGES_PATH/local/package1)" = "$(readlink -f "$BPM_ORIGIN_DIR/$dir")" ]
}

@test "calls link-bins, link-completions, link-man and deps in order" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local dir='package2'

	test_util.create_package "$dir"

	# On macOS, the temporary folder '/var' is symlinked to '/private/var'
	# Since BATS appears to be using '/var' directly, we have to resolve the
	# symlink so the output matches properly
	local srcDir="$(util.readlink "$BPM_ORIGIN_DIR/$dir")"

	run bpm global link "$srcDir"

	assert_success
	assert_line -n 0 -p "Symlinking '$srcDir'"
	assert_line -n 1 "plumbing.symlink-bins local/$dir"
	assert_line -n 2 "plumbing.symlink-completions local/$dir"
	assert_line -n 3 "plumbing.symlink-mans local/$dir"

}

@test "calls link-bins, link-completions, link-man and deps in order for multiple directories" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local dir1='package2'
	local dir2='package3'

	test_util.create_package "$dir1"
	test_util.create_package "$dir2"

	local srcDir1="$(util.readlink "$BPM_ORIGIN_DIR/$dir1")"
	local srcDir2="$(util.readlink "$BPM_ORIGIN_DIR/$dir2")"

	run bpm global link "$srcDir1" "$srcDir2"

	assert_success
	assert_line -n 0 -p "Symlinking '$srcDir1'"
	assert_line -n 1 "plumbing.symlink-bins local/$dir1"
	assert_line -n 2 "plumbing.symlink-completions local/$dir1"
	assert_line -n 3 "plumbing.symlink-mans local/$dir1"
	assert_line -n 4 -p "Symlinking '$srcDir2'"
	assert_line -n 5 "plumbing.symlink-bins local/$dir2"
	assert_line -n 6 "plumbing.symlink-completions local/$dir2"
	assert_line -n 7 "plumbing.symlink-mans local/$dir2"

}

@test "links the current directory" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local dir='package2'

	test_util.create_package "$dir"

	cd "$BPM_ORIGIN_DIR/$dir"
	run bpm global link .

	assert_success
	assert [ "$(readlink -f "$BPM_PACKAGES_PATH/local/$dir")" = "$(readlink -f "$BPM_ORIGIN_DIR/$dir")" ]
}

@test "links the parent directory" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local dir='package2'

	test_util.create_package "$dir"

	cd "$BPM_ORIGIN_DIR/$dir"
	mkdir -p 'tango'
	cd 'tango'

	run bpm global link ..

	assert_success
	assert [ "$(readlink -f "$BPM_PACKAGES_PATH/local/$dir")" = "$(readlink -f "$BPM_ORIGIN_DIR/$dir")" ]
}

@test "links an arbitrary complex relative path" {
	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	local dir='package2'

	test_util.create_package "parent/$dir"

	cd "$BPM_ORIGIN_DIR/parent"
	run bpm global link "./$dir/.././$dir"

	assert_success
	assert [ "$(readlink -f "$BPM_PACKAGES_PATH/local/$dir")" = "$(readlink -f "$BPM_ORIGIN_DIR/parent/$dir")" ]
}

@test "errors when no packages are given" {
	run bpm global link

	assert_failure
	assert_line -p 'At least one package must be supplied'
}
