#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no man pages" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-man "$pkg"

	assert_success
}

@test "adds man pages determined from bpm.toml (man-style)" {
	local package="username/package"

	test_util.setup_pkg "$package"; {
		echo 'manDirs = [ "a_dir" ]' > 'bpm.toml'
		mkdir -p 'a_dir/1man'
		touch 'a_dir/1man/exec.1'

		mkdir -p 'a_dir/5man'
		touch 'a_dir/5man/exec_cfg.5'
	}; test_util.finish_pkg
	test_util.fake_clone "$package"

	run do-plumbing-link-man "$package"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$package/a_dir/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/exec_cfg.5")" = "$BPM_PACKAGES_PATH/$package/a_dir/5man/exec_cfg.5" ]
}

@test "adds man pages determined from bpm.toml (manN-style)" {
	local package="username/package"

	test_util.setup_pkg "$package"; {
		echo 'manDirs = [ "a_dir/1man", "a_dir/5man" ]' > 'bpm.toml'
		mkdir -p a_dir/{1,5}man
		touch 'a_dir/1man/exec.1'

		mkdir -p 'a_dir/5man'
		touch 'a_dir/5man/exec_cfg.5'
	}; test_util.finish_pkg
	test_util.fake_clone "$package"

	run do-plumbing-link-man "$package"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$package/a_dir/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/exec_cfg.5")" = "$BPM_PACKAGES_PATH/$package/a_dir/5man/exec_cfg.5" ]
}

@test "adds man page determined from heuristics (man directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'man'
		touch 'man/exec.1'
		touch 'man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-man "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$pkg/man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$pkg/man/exec.2" ]
}

@test "adds man page determined from heuristics (man/manN directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p man/{1,2}man
		touch 'man/1man/exec.1'
		touch 'man/2man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-man "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$pkg/man/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$pkg/man/2man/exec.2" ]
}

@test "adds man page determined from heuristics (manN directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir {1,2}man
		touch '1man/exec.1'
		touch '2man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-man "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$pkg/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$pkg/2man/exec.2" ]
}

@test "adds man page determined from heuristics (root directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec.1'
		touch 'exec.2'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-man "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$pkg/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$pkg/exec.2" ]
}

@test "do not add man pages determined heuristics when manDirs is specified in bpm.toml" {
	local package="username/package"

	test_util.setup_pkg "$package"; {
		echo 'manDirs = [ ]' > 'bpm.toml'
		touch 'exec.1'
		mkdir '2man'
		touch '2man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_clone "$package"

	run do-plumbing-link-man "$package"

	assert_success
	assert [ ! -e "$BPM_INSTALL_MAN/man1/exec.1" ]
	assert [ ! -e "$BPM_INSTALL_MAN/man5/2man/exec.2" ]
}
