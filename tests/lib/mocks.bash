mock_command() {
  case "$1" in
    git) export MOCK_GIT=; return ;;
    basher-install) export MOCK_BASHER_INSTALL=; return ;;
    basher-_clone) export MOCK_BASHER__CLONE=; return ;;
    basher-_deps) export MOCK_BASHER__DEPS=; return ;;
    basher-_link-bins) export MOCK_BASHER__LINK_BINS=; return ;;
    basher-_link-completions) export MOCK_BASHER__LINK_COMPLETIONS=; return ;;
    basher-_link-man) export MOCK_BASHER__LINK_MAN=; return ;;
    basher-_unlink-bins) export MOCK_BASHER__UNLINK_BINS=; return ;;
    basher-_unlink-completions) export MOCK_BASHER__UNLINK_COMPLETIONS; return ;;
    basher-_unlink-man) export MOCK_BASHER__UNLINK_MAN; return ;;
  esac
}

mock_clone() {
  basher-_clone() {
    use_ssh="$1"
    site="$2"
    package="$3"

    git clone "$BASHER_ORIGIN_DIR/$package" "$BASHER_PACKAGES_PATH/$package"
  }
}
