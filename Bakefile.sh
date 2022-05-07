# shellcheck shell=bash

task.test() {
	bats ./tests
}

task.update-subtree() {
	git subtree --squash -P tests/vendor/bats-all pull 'https://github.com/hyperupcall/bats-all' "$1"
}
