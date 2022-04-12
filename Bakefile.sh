# shellcheck shell=bash

task.docs() {
	shdoc < './pkg/src/public/bash-term.sh' > './docs/api-term.md'
}
