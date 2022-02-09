# shellcheck shell=bash

task.test() {
	bats ./tests
}

task.update-subtree() {
	git subtree --squash -P tests/vendor/bats-assert update 'https://github.com/hyperupcall/bats-assert'
}
