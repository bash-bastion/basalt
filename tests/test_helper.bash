load vendor/bats-core/load
load vendor/bats-assert/load

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

export PATH="$BATS_TEST_DIRNAME/../libexec:$PATH"
export PATH="$BASHER_TMP_BIN:$PATH"

mkdir -p "$BASHER_TMP_BIN"
mkdir -p "$BASHER_TEST_DIR/path"

mkdir -p "$BASHER_ORIGIN_DIR"

mkdir -p "$BASHER_CWD"

export bin_path="$BATS_TEST_DIRNAME/../libexec"
for f in "$bin_path"/{subcmds,plumbing}/?*.sh; do
  source "$f"
done

setup() {
  cd $BASHER_CWD
  for f in "$bin_path"/{subcmds,plumbing}/?*.sh; do
    source "$f"
  done
  source "$bin_path/util/util.sh"
}

teardown() {
  rm -rf "$BASHER_TEST_DIR"
}

load lib/mocks
load lib/package_helpers
load lib/commands
