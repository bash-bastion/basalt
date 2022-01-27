# shellcheck shell=bash

task.update-subtree() {
	git subtree --squash -P tests/vendor/bats-assert update 'https://github.com/hyperupcall/bats-assert'
}
