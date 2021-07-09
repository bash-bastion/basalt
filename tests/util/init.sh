# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

load 'vendor/bats-core/load'
load 'vendor/bats-assert/load'
load 'util/package_helpers.sh'
load 'util/test_util.sh'

export BPM_TEST_DIR="$BATS_TMPDIR/bpm"
export BPM_CWD="$BPM_TEST_DIR/cwd"
export BPM_ORIGIN_DIR="$BPM_TEST_DIR/origin"

export XDG_DATA_HOME=
export PATH="$BPM_ROOT/pkg/bin:$PATH"

export PROGRAM_LIB_DIR="$BATS_TEST_DIRNAME/../pkg/lib"
export BPM_ROOT="$BATS_TEST_DIRNAME/.."
export BPM_PREFIX="$BPM_TEST_DIR/cellar"
export BPM_PACKAGES_PATH="$BPM_PREFIX/packages"
export BPM_INSTALL_BIN="$BPM_PREFIX/bin"
export BPM_INSTALL_MAN="$BPM_PREFIX/man"
export BPM_INSTALL_COMPLETIONS="$BPM_PREFIX/completions"

for f in "$BPM_ROOT"/pkg/lib/{commands,util}/?*.sh; do
	source "$f"
done

setup() {
	mkdir -p "$BPM_TEST_DIR" "$BPM_CWD" "$BPM_ORIGIN_DIR"
	cd "$BPM_CWD"
}

teardown() {
	rm -rf "$BPM_TEST_DIR"
}
