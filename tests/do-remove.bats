#!/usr/bin/env bats

load 'util/init.sh'

@test "if package is not installed, fails" {
	local site='github.com'
	local pkg='user/repo'
	run basalt global remove "$pkg"

	assert_failure
	assert_output -e "Package 'github.com/$pkg' is not installed"
}

@test "if package is a file, succeed, properly remove it" {
	local id='github.com/user/repo'

	mkdir -p "$BASALT_PACKAGES_PATH/${id%/*}"
	touch "$BASALT_PACKAGES_PATH/$id"

	[ -f "$BASALT_PACKAGES_PATH/$id" ]

	run basalt global remove "$id"

	assert_success
	assert [ ! -e "$BASALT_ORIGIN_DIR/$id" ]
}

@test "if package is an empty directory, properly remove it" {
	local id='github.com/user/repo'

	mkdir -p "$BASALT_PACKAGES_PATH/$id"

	assert [ -d "$BASALT_PACKAGES_PATH/$id" ]

	run basalt global remove "$id"

	assert_success
	assert [ ! -e "$BASALT_ORIGIN_DIR/$id" ]
}

@test "properly removes package directory" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'basalt.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -d "$BASALT_PACKAGES_PATH/github.com/$pkg" ]

	run basalt global remove "$pkg"

	assert_success
	assert [ ! -d "$BASALT_PACKAGES_PATH/github.com/$pkg" ]
}

@test "properly remove (unlink) locally installed packages" {
	local site='github.com'
	local dir='project3'

	test_util.setup_pkg "$dir"; {
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.mock_link "$dir"

	assert [ -d "$BASALT_PACKAGES_PATH/local/$dir" ]

	run basalt global remove "local/$dir"

	assert_success
	assert [ ! -d "$BASALT_PACKAGES_PATH/local/$dir" ]
}

@test "fails to remove package directory with wrong site name" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'basalt.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -d "$BASALT_PACKAGES_PATH/github.com/$pkg" ]

	run basalt global remove "gitlab.com/$pkg"

	assert_failure
}

@test "properly removes parent of package directory, if it is empty" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'basalt.toml'
		touch 'file.sh'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run basalt global remove "$pkg"

	assert_success
	assert [ ! -d "$BASALT_PACKAGES_PATH/$site/$pkg" ]
	assert [ ! -d "$BASALT_PACKAGES_PATH/${pkg%/*}" ]
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
	test_util.mock_add "$pkg"

	run basalt global remove "$pkg"

	assert_success
	[ ! -e "$BASALT_INSTALL_BIN/exec1" ]
	[ ! -e "$BASALT_INSTALL_BIN/exec2.sh" ]
}

@test "properly keeps non-uninstalled package directories and binaries" {
	local site='github.com'
	local pkg1='username/pkg1'
	local pkg2='username/pkg2'

	test_util.setup_pkg "$pkg1"; {
		mkdir bin
		touch 'bin/exec1'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg1"

	test_util.setup_pkg "$pkg2"; {
		mkdir bin
		touch 'bin/exec2'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg2"

	assert [ -d "$BASALT_PACKAGES_PATH/$site/$pkg1" ]
	assert [ -e "$BASALT_INSTALL_BIN/exec1" ]
	assert [ -d "$BASALT_PACKAGES_PATH/$site/$pkg2" ]
	assert [ -e "$BASALT_INSTALL_BIN/exec2" ]

	run basalt global remove "$pkg1"

	assert_success
	assert [ ! -d "$BASALT_PACKAGES_PATH/$site/$pkg1" ]
	assert [ ! -e "$BASALT_INSTALL_BIN/exec1" ]
	assert [ -d "$BASALT_PACKAGES_PATH/$site/$pkg2" ]
	assert [ -e "$BASALT_INSTALL_BIN/exec2" ]
}

@test "errors when no packages are given" {
	run basalt global remove

	assert_failure
	assert_line -p 'At least one package must be supplied'
}

@test "--all prints warning when no dependencies are specified in basalt.toml" {
	touch 'basalt.toml'

	run basalt global remove --all

	assert_success
	assert_line -p "No dependencies specified in 'dependencies' key"
	refute_line -p "Installing"
}

@test "--all errors when a package is specified as argument" {
	touch 'basalt.toml'

	run basalt global remove --all pkg

	assert_failure
	assert_line -p "No packages may be supplied when using '--all'"
}


@test "fail if ref is given during remove" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	run basalt global remove "$pkg@v0.1.0"

	assert_failure
	assert_line -p "Refs must be omitted when removing packages. Remove ref '@v0.1.0'"
}

@test "--force works" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		# Invalid because 'binDirs' must be an array
		echo 'binDirs = "somebin"' > 'basalt.toml'
	}; test_util.finish_pkg
	test_util.mock_clone "$pkg" "$site/$pkg"

	assert [ -d "$BASALT_PACKAGES_PATH/$site/$pkg" ]

	run basalt global remove --force "$pkg"

	assert_success
	assert_line -p -n 0 "Force removing '$site/$pkg'"
	assert_line -p -n 1 "Info: Pruning packages"

	assert [ ! -d "$BASALT_PACKAGES_PATH/$site/$pkg" ]
}

@test "fail if give --all and --force flags" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	run basalt global remove --all --force

	assert_failure
	assert_line -p "Flags '--all' and '--force' are mutually exclusive"
}

@test "fail if give --force and more than one package" {
	local site='github.com'
	local pkg='username/package'

	test_util.create_package "$pkg"
	test_util.mock_clone "$pkg" "$site/$pkg"

	run basalt global remove --force "$pkg" "$pkg"

	assert_failure
	assert_line -p "Only one package may be specified when --force is passed"
}

@test "fails if in local mode" {
	local site='github.com'
	local pkg1='user/project'

	touch 'basalt.toml'

	test_util.create_package "$pkg1"

	run basalt remove "$pkg1"

	assert_failure
	assert_line -p "Subcommands must use the '--all' flag when a 'basalt.toml' file is present"
}
