#!/usr/bin/env bats

load 'util/init.sh'

@test "without arguments prints usage" {
  run basher-install
  assert_failure
  assert_line "Usage: basher install [--ssh] [site]/<package>[@ref]"
}

@test "incorrect argument prints usage" {
  run basher-install first_arg
  assert_failure
  assert_line "Usage: basher install [--ssh] [site]/<package>[@ref]"
}

@test "too many arguments prints usage" {
  run basher-install a/b wrong
  assert_failure
  assert_line "Usage: basher install [--ssh] [site]/<package>[@ref]"
}

@test "executes install steps in right order" {
  mock.command basher-_clone
  mock.command basher-_deps
  mock.command basher-_link-bins
  mock.command basher-_link-man
  mock.command basher-_link-completions

  run basher-install username/package
  assert_success "basher-_clone false github.com username/package
basher-_deps username/package
basher-_link-bins username/package
basher-_link-man username/package
basher-_link-completions username/package"
}

@test "with site, overwrites site" {
  mock.command basher-_clone
  mock.command basher-_deps
  mock.command basher-_link-bins
  mock.command basher-_link-man
  mock.command basher-_link-completions

  run basher-install site/username/package

  assert_line "basher-_clone false site username/package"
}

@test "without site, uses github as default site" {
  mock.command basher-_clone
  mock.command basher-_deps
  mock.command basher-_link-bins
  mock.command basher-_link-man
  mock.command basher-_link-completions

  run basher-install username/package

  assert_line "basher-_clone false github.com username/package"
}

@test "using ssh protocol" {
  mock.command basher-_clone
  mock.command basher-_deps
  mock.command basher-_link-bins
  mock.command basher-_link-man
  mock.command basher-_link-completions

  run basher-install --ssh username/package

  assert_line "basher-_clone true github.com username/package"
}

@test "installs with custom version" {
  mock.command basher-_clone
  mock.command basher-_deps
  mock.command basher-_link-bins
  mock.command basher-_link-man
  mock.command basher-_link-completions

  run basher-install username/package@v1.2.3

  assert_line "basher-_clone false github.com username/package v1.2.3"
}

@test "empty version is ignored" {
  mock.command basher-_clone
  mock.command basher-_deps
  mock.command basher-_link-bins
  mock.command basher-_link-man
  mock.command basher-_link-completions

  run basher-install username/package@

  assert_line "basher-_clone false github.com username/package"
}

@test "doesn't fail" {
  create_package username/package
  mock.command _clone

  run basher-install username/package
  assert_success
}
