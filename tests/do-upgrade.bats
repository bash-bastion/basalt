#!/usr/bin/env bats

load 'util/init.sh'

@test "simple upgrade" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	cd "$BPM_ORIGIN_DIR/$site/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BPM_CWD"

	do-upgrade "$site/$pkg"

	run do-list --outdated
	assert_output ""

	assert [ -f "$BPM_PACKAGES_PATH/$site/$pkg/script2.sh" ]
}

@test "simple upgrade (specifying with directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	cd "$BPM_ORIGIN_DIR/$site/$pkg"
	touch 'script2.sh'
	git add .
	git commit -m 'Add script'
	cd "$BPM_CWD"

	do-upgrade "$BPM_ORIGIN_DIR/$site/$pkg"

	run do-list --outdated
	assert_output ""

	assert [ -f "$BPM_PACKAGES_PATH/$site/$pkg/script2.sh" ]
}


@test "symlinks stay valid after upgrade" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'script.sh'
		chmod +x 'script.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	cd "$BPM_ORIGIN_DIR/$site/$pkg"
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
	test_util.fake_install "$pkg"

	[ -f "$BPM_INSTALL_BIN/script3.sh" ]

	cd "$BPM_ORIGIN_DIR/$site/$pkg"
	rm 'bpm.toml'
	git add .
	git commit -m 'Remove bpm.toml'
	cd "$BPM_CWD"

	do-upgrade "$site/$pkg"

	assert [ ! -f "$BPM_INSTALL_BIN/script3.sh" ]
}

@test "errors when no packages are given" {
	run do-upgrade

	assert_failure
	assert_line -p 'You must supply at least one package'
}

@test "upgrade bpm works" {
	local site='github.com'
	local pkg='username/package'

	test_util.mock_command 'git'

	run do-upgrade 'bpm'

	assert_success
	assert_line -e 'git -C /(.*)/tests/../pkg/lib/../.. pull'
}

@test "upgrade bpm fails when mixing package names" {
	local site='github.com'
	local pkg='username/package'

	test_util.mock_command 'git'

	run do-upgrade 'bpm' 'pkg/name'

	assert_failure
	assert_line -p 'You cannot upgarde bpm and its packages at the same time'
}
