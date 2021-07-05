# shellcheck shell=bash

set -o pipefail
shopt -s nullglob extglob

load 'vendor/bats-core/load'
load 'vendor/bats-assert/load'
load 'util/mocks.sh'
load 'util/package_helpers.sh'

export BASHER_TEST_DIR="$BATS_TMPDIR/basher"
export BASHER_ORIGIN_DIR="$BASHER_TEST_DIR/origin"
export BASHER_CWD="$BASHER_TEST_DIR/cwd"
export BASHER_TMP_BIN="$BASHER_TEST_DIR/bin"
export XDG_DATA_HOME=""

export BASHER_ROOT="$BATS_TEST_DIRNAME/.."
export BASHER_PREFIX="$BASHER_TEST_DIR/prefix"
export BASHER_INSTALL_BIN="$BASHER_PREFIX/bin"
export BASHER_INSTALL_MAN="$BASHER_PREFIX/man"
export BASHER_PACKAGES_PATH="$BASHER_PREFIX/packages"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
PATH="$BASHER_ROOT/pkg/bin:$PATH"
PATH="$BASHER_TMP_BIN:$PATH"

mkdir -p "$BASHER_TEST_DIR/path"
mkdir -p "$BASHER_ORIGIN_DIR"
mkdir -p "$BASHER_CWD"
mkdir -p "$BASHER_TMP_BIN"

for f in "$BASHER_ROOT"/pkg/lib/{commands,util}/?*.sh; do
  source "$f"
done

setup() {
  # shellcheck disable=SC2164
  cd "$BASHER_CWD"
}

teardown() {
  rm -rf "$BASHER_TEST_DIR"
}
