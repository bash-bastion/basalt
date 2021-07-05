#!/usr/bin/env bats

load 'util/init.sh'

@test "without arguments prints usage" {
  skip

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
  mock.command basher-plumbing-clone
  mock.command basher-plumbing-deps
  mock.command basher-plumbing-link-bins
  mock.command basher-plumbing-link-completions
  mock.command basher-plumbing-link-completions

  run basher-install username/package
  assert_success "basher-plumbing-clone false github.com username/package
basher-plumbing-deps username/package
basher-plumbing-link-bins username/package
basher-plumbing-link-completions username/package
basher-plumbing-link-completions username/package"
}

@test "with site, overwrites site" {
  mock.command basher-plumbing-clone
  mock.command basher-plumbing-deps
  mock.command basher-plumbing-link-bins
  mock.command basher-plumbing-link-completions
  mock.command basher-plumbing-link-completions

  run basher-install site/username/package

  assert_line "basher-plumbing-clone false site username/package"
}

@test "without site, uses github as default site" {
  mock.command basher-plumbing-clone
  mock.command basher-plumbing-deps
  mock.command basher-plumbing-link-bins
  mock.command basher-plumbing-link-completions
  mock.command basher-plumbing-link-completions

  run basher-install username/package

  assert_line "basher-plumbing-clone false github.com username/package"
}

@test "using ssh protocol" {
  mock.command basher-plumbing-clone
  mock.command basher-plumbing-deps
  mock.command basher-plumbing-link-bins
  mock.command basher-plumbing-link-completions
  mock.command basher-plumbing-link-completions

  run basher-install --ssh username/package

  assert_line "basher-plumbing-clone true github.com username/package"
}

@test "installs with custom version" {
  mock.command basher-plumbing-clone
  mock.command basher-plumbing-deps
  mock.command basher-plumbing-link-bins
  mock.command basher-plumbing-link-completions
  mock.command basher-plumbing-link-completions

  run basher-install username/package@v1.2.3

  assert_line "basher-plumbing-clone false github.com username/package v1.2.3"
}

@test "empty version is ignored" {
  mock.command basher-plumbing-clone
  mock.command basher-plumbing-deps
  mock.command basher-plumbing-link-bins
  mock.command basher-plumbing-link-completions
  mock.command basher-plumbing-link-completions

  run basher-install username/package@

  assert_line "basher-plumbing-clone false github.com username/package"
}

@test "doesn't fail" {
  create_package username/package
  mock.command _clone

  run basher-install username/package
  assert_success
}
