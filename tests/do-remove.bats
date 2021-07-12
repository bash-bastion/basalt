#!/usr/bin/env bats

load 'util/init.sh'

@test "if package is not installed, fails" {
	local site='github.com'
	local pkg='user/repo'
	run do-remove "$pkg"

	assert_failure
	assert_output -e "Package 'github.com/$pkg' is not installed"
}

@test "if package is a file, succeed, properly remove it" {
	local id='github.com/user/repo'

	mkdir -p "$BPM_PACKAGES_PATH/${id%/*}"
	touch "$BPM_PACKAGES_PATH/$id"

	[ -f "$BPM_PACKAGES_PATH/$id" ]

	run do-remove "$id"

	assert_success
	assert [ ! -e "$BPM_ORIGIN_DIR/$id" ]
}

@test "if package is an empty directory, properly remove it" {
	local id='github.com/user/repo'

	mkdir -p "$BPM_PACKAGES_PATH/$id"

	assert [ -d "$BPM_PACKAGES_PATH/$id" ]

	run do-remove "$id"

	assert_success
	assert [ ! -e "$BPM_ORIGIN_DIR/$id" ]
}

@test "properly removes package directory" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'bpm.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -d "$BPM_PACKAGES_PATH/github.com/$pkg" ]

	run do-remove "$pkg"

	assert_success
	assert [ ! -d "$BPM_PACKAGES_PATH/github.com/$pkg" ]
}

@test "fails to remove package directory with wrong site name" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'bpm.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -d "$BPM_PACKAGES_PATH/github.com/$pkg" ]

	run do-remove "gitlab.com/$pkg"

	assert_failure
}

@test "properly removes parent of package directory, if it is empty" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'bpm.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-remove "$pkg"

	assert_success
	assert [ ! -d "$BPM_PACKAGES_PATH/$site/$pkg" ]
	assert [ ! -d "$BPM_PACKAGES_PATH/${pkg%/*}" ]
}

@test "properly removes binaries" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir bin
		touch 'bin/exec1'
		touch 'exec2.sh'
		chmod +x 'exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-remove "$pkg"

	assert_success
	[ ! -e "$BPM_INSTALL_BIN/exec1" ]
	[ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "properly keeps non-uninstalled package directories and binaries" {
	local site='github.com'
	local pkg1='username/pkg1'
	local pkg2='username/pkg2'

	test_util.setup_pkg "$pkg1"; {
		mkdir bin
		touch 'bin/exec1'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg1"

	test_util.setup_pkg "$pkg2"; {
		mkdir bin
		touch 'bin/exec2'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg2"

	assert [ -d "$BPM_PACKAGES_PATH/$site/$pkg1" ]
	assert [ -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ -d "$BPM_PACKAGES_PATH/$site/$pkg2" ]
	assert [ -e "$BPM_INSTALL_BIN/exec2" ]

	run do-remove "$pkg1"

	assert_success
	assert [ ! -d "$BPM_PACKAGES_PATH/$site/$pkg1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ -d "$BPM_PACKAGES_PATH/$site/$pkg2" ]
	assert [ -e "$BPM_INSTALL_BIN/exec2" ]
}
