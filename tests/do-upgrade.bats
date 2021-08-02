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
	cd "$BPM_CWD"

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
	cd "$BPM_CWD"

	run do-upgrade "$BPM_ORIGIN_DIR/$pkg"

	assert_failure
	assert_line -p "Package '$BPM_ORIGIN_DIR/$pkg' is not installed"
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
	cd "$BPM_CWD"

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
	cd "$BPM_CWD"

	do-upgrade "$site/$pkg"

	assert [ ! -f "$BPM_INSTALL_BIN/script3.sh" ]
}

@test "fails if user tries to upgrade a 'link'ed package" {
	local pkg='theta'

	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

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
