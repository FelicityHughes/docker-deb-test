#!/usr/bin/env bash

################################################################################
# This script removes the Docker container and image(s) created by the
# ./UnpackDeb.sh script.
################################################################################


# Include error handling functionality.
. ./ErrorHandling.sh

################################################################################
# Removes all images created from local docker-compose.yml file.  The target
# service is taken to be the first service defined in the file.
################################################################################
remove_docker_images() {
  local -r DOCKER_COMPOSE_FILE="${WORKING_DIR}/docker-compose.yml"
  local -r SERVICE="$("yq" "r" "${DOCKER_COMPOSE_FILE}" "services" \
                      | "sed" "-n" '1 s/^\([^:][^:]*\):$/\1/p')"
  local -r IMAGE="$("yq" "r" "${DOCKER_COMPOSE_FILE}" \
                    "services.${SERVICE}.image")"

  local base_image="$("yq" "r" "${DOCKER_COMPOSE_FILE}" \
                      "services.${SERVICE}.build.args" | "sed" "-n" \
                      's/^.*BASE_IMAGE=\([^:][^:]*\):[^ ][^ ]*$/\1/p')"

  if [[ "${base_image}" == "" ]]; then
    base_image="$("grep" "ARG BASE_IMAGE=" "${BUILD_DIR}/Dockerfile" \
                  | "sed" 's/^[^=][^=]*=\([^:][^:]*\):..*$/\1/')"
  fi

  docker rmi $(docker images -a | grep "${IMAGE}" | awk '{print $3}')
  docker rmi $(docker images -a | grep "${base_image}" | awk '{print $3}')
}


################################################################################

remove_docker_containers "${TRUE}"
remove_docker_images

exit ${SUCCESS}