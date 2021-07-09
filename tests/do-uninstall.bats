#!/usr/bin/env bats

load 'util/init.sh'

@test "if package is not installed, fails" {
	local pkg='user/repo'

	run do-uninstall "$pkg"

	assert_failure
	assert_output -e "Package '$pkg' is not installed"
}

@test "if package is a file, succeed, properly remove it" {
	local pkg='user/repo'

	mkdir -p "$BPM_PACKAGES_PATH/${pkg%/*}"
	touch "$BPM_PACKAGES_PATH/$pkg"

	[ -f "$BPM_PACKAGES_PATH/$pkg" ]

	run do-uninstall "$pkg"

	assert_success
	assert [ ! -e "$BPM_ORIGIN_DIR/$pkg" ]
}

@test "if package is an empty directory, properly remove it" {
	local pkg='user/repo'

	mkdir -p "$BPM_PACKAGES_PATH/$pkg"

	assert [ -d "$BPM_PACKAGES_PATH/$pkg" ]

	run do-uninstall "$pkg"

	assert_success
	assert [ ! -e "$BPM_ORIGIN_DIR/$pkg" ]
}

@test "properly removes package directory" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		touch 'bpm.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-uninstall "$pkg"

	assert_success
	assert [ ! -d "$BPM_PACKAGES_PATH/$pkg" ]
}

@test "properly removes parent of package directory, if it is empty" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		touch 'bpm.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-uninstall "$pkg"

	assert_success
	assert [ ! -d "$BPM_PACKAGES_PATH/$pkg" ]
	assert [ ! -d "$BPM_PACKAGES_PATH/${pkg%/*}" ]
}

@test "properly removes binaries" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir bin
		touch 'bin/exec1'
		touch 'exec2.sh'
		chmod +x 'exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-uninstall "$pkg"

	assert_success
	[ ! -e "$BPM_INSTALL_BIN/exec1" ]
	[ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "properly keeps non-uninstalled package directories and binaries" {
	local pkg1='username/pkg1'
	local pkg2='username/pkg2'

	test_util.setup_pkg "$pkg1"; {
		mkdir bin
		touch 'bin/exec1'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg1"

	test_util.setup_pkg "$pkg2"; {
		mkdir bin
		touch 'bin/exec2'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg2"

	assert [ -d "$BPM_PACKAGES_PATH/$pkg1" ]
	assert [ -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ -d "$BPM_PACKAGES_PATH/$pkg2" ]
	assert [ -e "$BPM_INSTALL_BIN/exec2" ]

	run do-uninstall "$pkg1"

	assert_success
	assert [ ! -d "$BPM_PACKAGES_PATH/$pkg1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ -d "$BPM_PACKAGES_PATH/$pkg2" ]
	assert [ -e "$BPM_INSTALL_BIN/exec2" ]
}
