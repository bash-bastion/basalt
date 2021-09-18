# shellcheck shell=bash

load './util/init.sh'

setup() {
	curl() {
		local package="$2"; package="${package#https://api.github.com/repos/}"; package="${package%/releases/latest}"
		if [ "$package" = 'user/name1' ]; then
			printf '%s\n' '{ "name": "v0.0.1" }'
		elif [ "$package" = 'user/name2' ]; then
			printf '%s\n' '{ "message": "Not Found", "documentation_url": "" }'
		else
			command curl "$@"
		fi
	}

	git() {
		if [ "$1" = 'ls-remote' ]; then
			if [ "$2" = 'fakeuri1' ]; then
				printf '%s\n' 'ccc5e0a847e25b59ce2999340fdad51d50a896a5 HEAD'
			else
				command git "$@"
			fi
		else
			command git "$@"
		fi
	}
}

@test "works if package has a release" {
	util.get_latest_package_version 'remote' 'empty' 'github.com' 'user/name1'

	assert [ "$REPLY" = 'v0.0.1' ]
}

@test "works if package has no release" {
	util.get_latest_package_version 'remote' 'fakeuri1' 'github.com' 'user/name2'

	assert [ "$REPLY" = 'ccc5e0a847e25b59ce2999340fdad51d50a896a5' ]
}
