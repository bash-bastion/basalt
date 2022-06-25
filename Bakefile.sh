# shellcheck shell=bash

task.init() {
	local basalt="$BAKE_ROOT/pkg/bin/basalt"
	for dir in ./tests/vendor/bats-all ./pkg/vendor/bash-{core,std,term}; do
		( cd "$dir" && "$basalt" install )
	done
}

task.test() {
	bats ./tests
}

task.subtree-info() {
	local vendor_dir="${1:-./pkg/vendor/bash-core}"
	bake.info "vendor_dir: $vendor_dir"

	local commit=
	commit=$(git log --pretty=format:'%H' -- "$vendor_dir")
	git show -s --format=%B "$(git log --pretty='%P' -n1 "$commit" | awk '{ print $2 }' )"
}

task.subtree-update() {
	git subtree --squash -P tests/vendor/bats-all pull 'https://github.com/hyperupcall/bats-all' "$1"
}


