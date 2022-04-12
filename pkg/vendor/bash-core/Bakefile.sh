# shellcheck shell=bash

task.test() {
	bats tests
}

task.docs() {
	shdoc < './pkg/src/public/bash-core.sh' > './docs/api.md'
}
