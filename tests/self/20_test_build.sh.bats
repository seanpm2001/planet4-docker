#!/usr/bin/env bash
set -e

load env

function setup {
  begin_output
}

function teardown {
  store_output
}

@test "build.sh exists and is executable" {
  [[ -f "${PROJECT_ROOT_DIR}/build.sh" ]]
  [[ -x "${PROJECT_ROOT_DIR}/build.sh" ]]
}

@test "build.sh prints usage information with -h flag" {
  run ${PROJECT_ROOT_DIR}/build.sh -h
  [[ $output =~ "usage" ]]
}
