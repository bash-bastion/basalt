# shellcheck shell=bash

task.init() {
	hookah refresh
}

task.test() {
	bats tests
}

task.docs() {
	shdoc < './pkg/src/public/bash-core.sh' > './docs/api.md'
}
