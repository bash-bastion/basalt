#!/usr/bin/env bats

load 'util/init.sh'

@test "simple upgrade" {
	local site='github.com'
	local pkg='somedir/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BATS_TEST_TMPDIR"

	do-upgrade "$site/$pkg"

	run do-list

	assert_success
	assert_output -e "github.com/$pkg
  Branch: master
  Revision: ([a-z0-9]*)
  State: Up to date"
	assert [ -f "$BPM_PACKAGES_PATH/$site/$pkg/script2.sh" ]
}

@test "simple upgrade fails when specifying full directory" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BATS_TEST_TMPDIR"

	run do-upgrade "$BPM_ORIGIN_DIR/$pkg"

	assert_failure
	assert_line -p "Package '$BPM_ORIGIN_DIR/$pkg' is not installed"
}

@test "simple upgrade properly prints linking and unlinking messages" {
	local site='github.com'
	local pkg='somedir/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	mkdir 'completions' 'bin' 'man' 'man/man1'
	touch 'completions/file.sh' 'bin/file' 'man/man1/file.1'
	git add .
	git commit -m 'Add script'
	cd "$BATS_TEST_TMPDIR"

	do-upgrade "$site/$pkg"

	unset BPM_IS_TEST
	run do-upgrade "$pkg"

	assert_success
	assert_line -p -n 1 "Unsymlinking bin files"
	assert_line -p -n 2 "Unsymlinking completion files"
	assert_line -p -n 3 "Unsymlinking man files"
	assert_line -p -n 4 "Fetching repository updates and merging"
	assert_line -p -n 5 "Symlinking bin files"
	assert_line -p -n 6 "Symlinking completion files"
	assert_line -p -n 7 "Symlinking man files"
}

@test "symlinks stay valid after upgrade" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
		chmod +x 'script.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	cd "$BPM_ORIGIN_DIR/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BATS_TEST_TMPDIR"

	do-upgrade "$site/$pkg"

	assert [ "$(readlink "$BPM_INSTALL_BIN/script.sh")" = "$BPM_PACKAGES_PATH/$site/$pkg/script.sh" ]
}

@test "BPM_INSTALL_DIR reflected when package modifies binDirs key" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "binn" ]' > 'bpm.toml'
		mkdir 'binn'
		touch 'binn/script3.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	[ -f "$BPM_INSTALL_BIN/script3.sh" ]

	cd "$BPM_ORIGIN_DIR/$pkg"
	rm 'bpm.toml'
	git add .
	git commit -m 'Remove bpm.toml'
	cd "$BATS_TEST_TMPDIR"

	do-upgrade "$site/$pkg"

	assert [ ! -f "$BPM_INSTALL_BIN/script3.sh" ]
}

@test "fails if user tries to upgrade a 'link'ed package" {
	local pkg='theta'

	test_util.stub_command plumbing.add-dependencies
	test_util.stub_command plumbing.symlink-bins
	test_util.stub_command plumbing.symlink-completions
	test_util.stub_command plumbing.symlink-mans

	test_util.create_package "$pkg"
	test_util.mock_link "$pkg"

	run 'do-upgrade' "local/$pkg"

	assert_failure
	assert_line -p "Package 'local/$pkg' is locally symlinked and cannot be upgraded through Git"
}

@test "errors when no packages are given" {
	run do-upgrade

	assert_failure
	assert_line -p 'At least one package must be supplied'
}

@test "upgrade bpm works" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command 'git'

	run do-upgrade 'bpm'

	assert_success
	assert_line -e 'git -C /(.*)/bpm/source/pkg/lib/../.. pull'
}

@test "upgrade bpm fails when mixing package names" {
	local site='github.com'
	local pkg='username/package'

	test_util.stub_command 'git'

	run do-upgrade 'bpm' 'pkg/name'

	assert_failure
	assert_line -p 'Packages cannot be upgraded at the same time as bpm'
}

@test "fail if ref is given during upgrade" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	run do-upgrade "$pkg@v0.1.0"

	assert_failure
	assert_line -p "Refs must be omitted when upgrading packages. Remove ref '@v0.1.0'"
}

@test "fail if bpm and '--all' are specified" {
	run do-upgrade bpm --all

	assert_failure
	assert_line -p "Upgrading bpm and using '--all' are mutually exclusive behaviors"
}

@test "fail if bpm is specified in local mode" {
	touch 'bpm.toml'

	BPM_MODE='local' run do-upgrade bpm

	assert_failure
	assert_line -p "Cannot upgrade bpm with a local 'bpm.toml' file"
}

@test "--all errors when a package is specified as argument" {
	touch 'bpm.toml'

	run do-upgrade --all some/pkg

	assert_failure
	assert_line -p "No packages may be supplied when using '--all'"
}

@test "fails if in local mode" {
	local site='github.com'
	local pkg1='user/project'

	touch 'bpm.toml'

	test_util.create_package "$pkg1"

	BPM_MODE='local' run do-upgrade "$pkg1"

	assert_failure
	assert_line -p "Subcommands must use the '--all' flag when a 'bpm.toml' file is present"
}
