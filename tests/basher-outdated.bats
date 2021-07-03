#!/usr/bin/env bats

load 'util/init.sh'

@test "displays nothing if there are no packages" {
  run basher-outdated
  assert_success
  assert_output ""
}

@test "displays outdated packages" {
  mock_clone
  create_package username/outdated
  create_package username/uptodate
  basher-install username/outdated
  basher-install username/uptodate
  create_exec username/outdated "second"

  run basher-outdated
  assert_success
  assert_output username/outdated
}
