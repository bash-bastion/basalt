#!/usr/bin/env bats

load './util/init.sh'

@test "fails on no arguments" {
	run pkgutil.get_package_info

	assert_failure
	assert_line -p "Argument 'input' for function 'pkgutil.get_package_info' is empty"
}

@test "parses with full https url" {
	pkgutil.get_package_info 'https://gitlab.com/hyperupcall/proj'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://gitlab.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'gitlab.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = '' ]
}

@test "parses with full https url with .git ending" {
	pkgutil.get_package_info 'https://gitlab.com/hyperupcall/proj'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://gitlab.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'gitlab.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = '' ]
}

@test "parses with full https url and version" {
	pkgutil.get_package_info 'https://gitlab.com/hyperupcall/proj@v0.0.1'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://gitlab.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'gitlab.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = 'v0.0.1' ]
}

@test "parses with full https url with .git ending and version" {
	pkgutil.get_package_info 'https://gitlab.com/hyperupcall/proj@v0.0.1'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://gitlab.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'gitlab.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = 'v0.0.1' ]
}

@test "parses with package and domain" {
	pkgutil.get_package_info 'gitlab.com/hyperupcall/proj'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://gitlab.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'gitlab.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = '' ]
}

@test "parses with package and domain and ref" {
	pkgutil.get_package_info 'gitlab.com/hyperupcall/proj@v0.1.0'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://gitlab.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'gitlab.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = 'v0.1.0' ]
}

@test "parses with package" {
	pkgutil.get_package_info 'hyperupcall/proj'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://github.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'github.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = '' ]
}

@test "parses with package and ref" {
	pkgutil.get_package_info 'hyperupcall/proj@v0.2.0'

	assert [ "$REPLY1" = 'remote' ]
	assert [ "$REPLY2" = 'https://github.com/hyperupcall/proj' ]
	assert [ "$REPLY3" = 'github.com' ]
	assert [ "$REPLY4" = 'hyperupcall/proj' ]
	assert [ "$REPLY5" = 'v0.2.0' ]
}

@test "parses with file:// protocol" {
	pkgutil.get_package_info 'file:///home/directory'

	assert [ "$REPLY1" = 'local' ]
	assert [ "$REPLY2" = 'file:///home/directory' ]
	assert [ "$REPLY3" = '' ]
	assert [ "$REPLY4" = 'directory' ]
	assert [ "$REPLY5" = '' ]
}

@test "parses with file:// protocol and ref" {
	pkgutil.get_package_info 'file:///home/user/directory@v0.2.0'

	assert [ "$REPLY1" = 'local' ]
	assert [ "$REPLY2" = 'file:///home/user/directory' ]
	assert [ "$REPLY3" = '' ]
	assert [ "$REPLY4" = 'directory' ]
	assert [ "$REPLY5" = 'v0.2.0' ]
}

@test "errors if format is not proper" {
	run pkgutil.get_package_info 'UwU'

	assert_failure
}
