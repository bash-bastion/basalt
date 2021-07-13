#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no man pages" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
}

@test "adds man pages determined from bpm.toml (man-style)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'manDirs = [ "a_dir" ]' > 'bpm.toml'
		mkdir -p 'a_dir/1man'
		touch 'a_dir/1man/exec.1'

		mkdir -p 'a_dir/5man'
		touch 'a_dir/5man/exec_cfg.5'
	}; test_util.finish_pkg
	test_util.fake_clone "$site/$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$site/$pkg/a_dir/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/exec_cfg.5")" = "$BPM_PACKAGES_PATH/$site/$pkg/a_dir/5man/exec_cfg.5" ]
}

@test "adds man pages determined from bpm.toml (manN-style)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'manDirs = [ "a_dir/1man", "a_dir/5man" ]' > 'bpm.toml'
		mkdir -p a_dir/{1,5}man
		touch 'a_dir/1man/exec.1'

		mkdir -p 'a_dir/5man'
		touch 'a_dir/5man/exec_cfg.5'
	}; test_util.finish_pkg
	test_util.fake_clone "$site/$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$site/$pkg/a_dir/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/exec_cfg.5")" = "$BPM_PACKAGES_PATH/$site/$pkg/a_dir/5man/exec_cfg.5" ]
}

@test "adds man page determined from heuristics (man directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'man'
		touch 'man/exec.1'
		touch 'man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$site/$pkg/man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$site/$pkg/man/exec.2" ]
}

@test "adds man page determined from heuristics (man/manN directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir -p man/{1,2}man
		touch 'man/1man/exec.1'
		touch 'man/2man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$site/$pkg/man/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$site/$pkg/man/2man/exec.2" ]
}

@test "adds man page determined from heuristics (manN directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir {1,2}man
		touch '1man/exec.1'
		touch '2man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$site/$pkg/1man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$site/$pkg/2man/exec.2" ]
}

@test "adds man page determined from heuristics (root directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec.1'
		touch 'exec.2'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$site/$pkg/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/$site/$pkg/exec.2" ]
}

@test "do not add man pages determined heuristics when manDirs is specified in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'manDirs = [ ]' > 'bpm.toml'
		touch 'exec.1'
		mkdir '2man'
		touch '2man/exec.2'
	}; test_util.finish_pkg
	test_util.fake_clone "$site/$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_MAN/man1/exec.1" ]
	assert [ ! -e "$BPM_INSTALL_MAN/man5/2man/exec.2" ]
}

@test "fails link man when specifying file in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'manDirs = ["dir"]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.fake_clone "$site/$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_line -p "Directory 'dir' with executable files not found. Skipping"
}

@test "warns link man when specifying non-existent directory in bpm.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'manDirs = ["dir"]' > 'bpm.toml'
	}; test_util.finish_pkg
	test_util.fake_clone "$site/$pkg"

	run do-plumbing-link-man "$site/$pkg"

	assert_line -p "Directory 'dir' with executable files not found. Skipping"
}
