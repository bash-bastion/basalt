# shellcheck shell=bash

task.test() {
	for repo in bats-assert bats-file bats-support; do
		bake.info "REPO: ${repo^^}"
		cd "$repo"
		bats test || :
		cd "$BAKE_ROOT"
	done
}

task.update() {
	for repo in bats-assert bats-file bats-support; do
		git subtree -P "$repo" pull "https://github.com/hyperupcall/$repo" HEAD
	done
}
