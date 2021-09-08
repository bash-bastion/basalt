#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no binaries" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
}

@test "adds bins determined from package.sh" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="binn/exec1:binn/exec2.sh"' > 'package.sh'
		mkdir 'binn'
		touch 'binn/exec1'
		touch 'binn/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec1)" = "$BASALT_PACKAGES_PATH/$site/$pkg/binn/exec1" ]
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec2.sh)" = "$BASALT_PACKAGES_PATH/$site/$pkg/binn/exec2.sh" ]
}


@test "adds bins determined from package.sh (and not with heuristics)" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="ff/exec3"' > 'package.sh'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2'
		mkdir 'ff'
		touch 'ff/exec3'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$(readlink $BASALT_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BASALT_INSTALL_BIN/exec2)" ]
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec3)" = "$BASALT_PACKAGES_PATH/$site/$pkg/ff/exec3" ]
}

@test "adds bins determined from basalt.toml" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "weird_dir" ]' > 'basalt.toml'
		mkdir 'weird_dir'
		touch 'weird_dir/exec1'
		touch 'weird_dir/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/weird_dir/exec1" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec2.sh")" = "$BASALT_PACKAGES_PATH/$site/$pkg/weird_dir/exec2.sh" ]
}

@test "adds bins determined from basalt.toml (and not heuristics)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "weird_dir" ]' > 'basalt.toml'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2'
		mkdir 'weird_dir'
		touch 'weird_dir/exec3'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BASALT_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BASALT_INSTALL_BIN/exec2" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec3")" = "$BASALT_PACKAGES_PATH/$site/$pkg/weird_dir/exec3" ]
}

@test "adds bins determined with heuristics (bin directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec1)" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec2.sh)" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec2.sh" ]
}

@test "adds bins determined with heuristics (bins directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'bins'
		touch 'bins/exec1'
		touch 'bins/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec1)" = "$BASALT_PACKAGES_PATH/$site/$pkg/bins/exec1" ]
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec2.sh)" = "$BASALT_PACKAGES_PATH/$site/$pkg/bins/exec2.sh" ]
}

@test "adds bins determined with heuristics (root directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec1'
		touch 'exec2.sh'
		chmod +x 'exec1' 'exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/exec1" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec2.sh")" = "$BASALT_PACKAGES_PATH/$site/$pkg/exec2.sh" ]
}

@test "does not add bins that are not executable in root directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec1'
		touch 'exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BASALT_INSTALL_BIN/exec3" ]
	assert [ ! -e "$BASALT_INSTALL_BIN/exec4.sh" ]
}

@test "does not add directories in root directory" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'directory1'
		touch 'directory1/.gitkeep'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BASALT_INSTALL_BIN/directory1" ]
}

@test "doesn't link root bins if there is a bin folder" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'exec2'
		chmod +x 'exec2'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ ! -e "$(readlink "$BASALT_INSTALL_BIN/exec2")" ]
}

@test "remove extensions if REMOVE_EXTENSION is true in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION="true"' > 'package.sh'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec2")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec2.sh" ]
}

# Backwards compatiblity
@test "does not remove extensions if REMOVE_EXTENSION is set in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION=' > 'package.sh'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec2.sh")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec2.sh" ]
	assert [ ! -e "$BASALT_INSTALL_BIN/exec2" ]
}

@test "does not remove extensions if REMOVE_EXTENSION is false in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION="false"' > 'package.sh'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec1)" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ "$(readlink $BASALT_INSTALL_BIN/exec2.sh)" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec2.sh" ]
}

@test "remove extensions if binRemoveExtensions is 'yes' in basalt.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'binRemoveExtensions = "yes"' > 'basalt.toml'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec2")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec2.sh" ]
}

@test "do not remove extensions if binRemoveExtensions is 'no' in basalt.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'binRemoveExtensions = "no"' > 'basalt.toml'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_success
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec1")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BASALT_INSTALL_BIN/exec2.sh")" = "$BASALT_PACKAGES_PATH/$site/$pkg/bin/exec2.sh" ]
}

@test "does not symlink package itself as bin when linked with basalt link" {
	local dir='package'
	local dir2='username/package2'

	test_util.create_package "$dir"
	test_util.create_package "$dir2"

	# implicit call to plumbing.symlink-bins
	run basalt global link "$BASALT_ORIGIN_DIR/$dir" "$BASALT_ORIGIN_DIR/$dir2"

	assert_success
	assert [ ! -e "$BASALT_CELLAR/bin/package" ]
	assert [ ! -e "$BASALT_CELLAR/bin/package2" ]
}

@test "fails link bins when specifying directory in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="dir"' > 'package.sh'

		mkdir 'dir'
		touch 'dir/.gitkeep'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_failure
	assert_line -p "Specified directory 'dir' in package.sh; only files are valid"
}

@test "warns link bins when specifying non-existent file in package.sh" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="some_file"' > 'package.sh'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_line -p "Executable file 'some_file' not found. Skipping"
}

@test "fails link bins when specifying file in basalt.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = ["file"]' > 'basalt.toml'
		touch 'file'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_failure
	assert_line -p "Specified file 'file' in basalt.toml; only directories are valid"
}

@test "warns link bins when specifying non-existent directory in basalt.toml" {
	local site='github.com'
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = ["dir"]' > 'basalt.toml'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	run plumbing.symlink-bins "$site/$pkg"

	assert_line -p "Directory 'dir' with executable files not found. Skipping"
}

@test "warns link bins if binary already exists" {
	local site='github.com'
	local pkg1="username/package"
	local pkg2='username/package2'

	test_util.setup_pkg "$pkg1"; {
		touch 'file2.bash'
		chmod +x 'file2.bash'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg1" "$site/$pkg1"

	test_util.setup_pkg "$pkg2"; {
		touch 'file2.bash'
		chmod +x 'file2.bash'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg2" "$site/$pkg2"

	plumbing.symlink-bins "$site/$pkg1"
	run plumbing.symlink-bins "$site/$pkg2"

	assert_line -p "Skipping 'file2.bash' since an existing symlink with the same name already exists"
}
