# shellcheck shell=bash

task.docs() {
	shdoc './pkg/src/public/bash-std.sh' > './docs/reference.md'
}