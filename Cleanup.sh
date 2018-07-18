#!/usr/bin/env bash

################################################################################
# This script removes the Docker container and image(s) created by the
# ./UnpackDeb.sh script.
################################################################################


# Include error handling functionality.
. ./ErrorHandling.sh

################################################################################
# Removes all images created from local docker-compose.yml file.
################################################################################
remove_docker_images() {
  local -r SERVICE_NAME="deb_test"
  local -r IMAGE="$("yq" "r" "${WORKING_DIR}/docker-compose.yml" \
                      "services.${SERVICE_NAME}.image")"

  local base_image="$("yq" "r" "${WORKING_DIR}/docker-compose.yml" \
                      "services.${SERVICE_NAME}.build.args" | "sed" "-n" \
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