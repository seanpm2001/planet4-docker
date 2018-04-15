#!/usr/bin/env bats
set -e

load env

# Build Dockerfile variables from template file
# ENVVARS=(
#   '${APP_HOSTNAME}' \
#   '${BATS_PROJECT_ID}' \
#   '${IMAGE_NAMESPACE}' \
#   '${COMPOSER}' \
#   '${IMAGE_TAG}' \
#   '${WP_TITLE}' \
# )

# ENVVARS_STRING="$(printf "%s:" "${ENVVARS[@]}")"
# ENVVARS_STRING="${ENVVARS_STRING%:}"

envsubst < "${BATS_DIRECTORY:-${BATS_TEST_DIRNAME}/..}/Dockerfile.in" > "${BATS_DIRECTORY:-${BATS_TEST_DIRNAME}/..}/Dockerfile"

function setup {
  begin_output
}

function teardown {
  store_output
}

@test "shutdown existing containers" {
  docker-compose -f "${compose_file}" down -v
}

@test "pull new container versions" {
  docker-compose -f "${compose_file}" pull
}

@test "container starts" {
  # Wait up to 10 minutes for the build to complete!
  run start_docker_compose "${BATS_TEST_DIRNAME}/../docker-compose.yml" http://localhost:80 p4-sample-application_openresty_1 10
  [[ "$status" -eq 0 ]]
}

@test "print openresty environment" {
  run print_docker_compose_env openresty
  [[ $status -eq 0 ]]
}

@test "print php-fpm environment" {
  run print_docker_compose_env php-fpm
  [[ $status -eq 0 ]]
}

@test "responds on port 80 with status 200" {
  run curl_check_status_code 200 http://localhost:80 p4-sample-application_openresty_1 600
  [[ $status -eq 0 ]]
  [[ $output -eq "200" ]]
}

@test "response contains string 'greenpeace'" {
  run curl_check_response_regex "greenpeace" http://localhost:80 p4-sample-application_openresty_1 5
  [[ $status -eq 0 ]]
}

@test "response does not contain string 'FNORDPTANGWIBBLE'" {
  run curl_check_response_regex "FNORDPTANGWIBBLE" http://localhost:80 p4-sample-application_openresty_1 1
  [[ $status -ne 0 ]]
}

@test "container restarts with modified content" {
  skip "todo"
}

@test "can overwrite existing files" {
  skip "todo"
}
