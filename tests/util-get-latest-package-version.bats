# shellcheck shell=bash

load './util/init.sh'

@test "Works if site is not supported" {
	git() {
		printf '%s\n' 'acc5e0a847e25b59ce2999340fdad51d50a896a5	HEAD'
	}

	# Test warning
	run util.get_latest_package_version 'remote' '_whatever_' 'gitlab.com' '_whatever_'

	assert_success
	assert_line -p "Could not automatically retrieve latest release for '_whatever_' since 'gitlab.com' is not supported. Falling back to retrieving latest commit"

	# Test output
	util.get_latest_package_version 'remote' '_whatever_' 'gitlab.com' '_whatever_'

	assert [ "$REPLY" = 'acc5e0a847e25b59ce2999340fdad51d50a896a5' ]
}

@test "Works if package has a release" {
	curl() {
		printf '%s\n' '{
		  "tag_name": "v0.0.1"
		}'
	}
	util.get_latest_package_version 'remote' '_whatever_' 'github.com' '_whatever_'

	assert [ "$REPLY" = 'v0.0.1' ]
}

@test "Works if package has no release" {
	curl() {
		printf '%s\n' '{
		  "message": "Not Found",
		  "documentation_url": "https://blah"
		}'
	}
	git() {
		printf '%s\n' 'ccc5e0a847e25b59ce2999340fdad51d50a896a5	HEAD'
	}

	util.get_latest_package_version 'remote' '_whatever_' 'github.com' '_whatever_'

	assert [ "$REPLY" = 'ccc5e0a847e25b59ce2999340fdad51d50a896a5' ]
}
