# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

load 'vendor/bats-core/load'
load 'vendor/bats-assert/load'
load 'util/test_util.sh'

export LANG="C"
export LANGUAGE="C"
export LC_ALL="C"
export XDG_DATA_HOME=

# Test-specific
export BPM_TEST_DIR="$BATS_TMPDIR/bpm"
export BPM_ORIGIN_DIR="$BPM_TEST_DIR/origin"
export BPM_MODE_TEST=
export BPM_MODE='global' # normal default is 'local'

# Stub common variables
export PROGRAM_LIB_DIR="$BPM_ROOT/source/pkg/lib"
test_util.get_bpm_root
export BPM_ROOT="$REPLY"
export BPM_PREFIX="$BPM_TEST_DIR/cellar"
export BPM_PACKAGES_PATH="$BPM_PREFIX/packages"
export BPM_INSTALL_BIN="$BPM_PREFIX/bin"
export BPM_INSTALL_MAN="$BPM_PREFIX/man"
export BPM_INSTALL_COMPLETIONS="$BPM_PREFIX/completions"

export PATH="$BPM_ROOT/source/pkg/bin:$PATH"
for f in "$BPM_ROOT"/source/pkg/lib/{commands,util}/?*.sh; do
	source "$f"
done

setup() {
	mkdir -p "$BPM_TEST_DIR" "$BATS_TEST_TMPDIR" "$BPM_ORIGIN_DIR"
	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	rm -rf "$BPM_TEST_DIR"
}
