#!/usr/bin/env bash

################################################################################
# This script is a library of common error-related functions for use by other
# scripts.
################################################################################


# Define booleans.
readonly FALSE=0
readonly TRUE=1

# File and command info.
readonly LOG_DATE_FORMAT='+%Y-%m-%d %H:%M:%S'
readonly WORKING_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
readonly BUILD_DIR="${WORKING_DIR}/build"

# Exit states.
readonly SUCCESS=0
readonly UNDEFINED_ERROR=1
readonly SCRIPT_INTERRUPTED=99


################################################################################
# Checks the supplied return value from a previously executed command and if it
# is non-zero, exits the script with the given value after logging an error
# message (if supplied).
#
# @param RETURN_VAL    The value returned by the previously executed command.
# @param ERROR_EXIT    The value with which to exit if RETURN_VAL was non-zero.
# @param ERROR_MESSAGE The error message to log if an exit is required.
################################################################################
exit_if_error() {
  local -r RETURN_VAL="${1}"
  local -r ERROR_EXIT="${2}"
  local -r ERROR_MESSAGE="${3}"

  if ((RETURN_VAL != SUCCESS)); then
    exit_with_error "${ERROR_EXIT}" "${ERROR_MESSAGE}"
  fi
}


################################################################################
# Exits with the given value after logging an error message (if supplied).
#
# @param ERROR_EXIT    The value with which to exit if RETURN_VAL was non-zero.
# @param ERROR_MESSAGE The error message to log if an exit is required.
################################################################################
exit_with_error() {
  local -r ERROR_EXIT="${1}"
  local -r ERROR_MESSAGE="${2}"

  if [[ "${ERROR_MESSAGE}" != "" ]]; then
    write_log "${ERROR_MESSAGE}"
  fi

  exit ${ERROR_EXIT}
}


################################################################################
# Shuts down all containers built from local docker-compose.yml file, optionally
# tearing down their volumes as well.
#
# @param ABANDON_VOLUME If true, indicates volumes should be removed.
################################################################################
remove_docker_containers() {
  local -r ABANDON_VOLUME="${1}"
  local -r FIRST_SERVICE="$("yq" "r" "${WORKING_DIR}/docker-compose.yml" \
                            "services" | "sed" "-n" "1 s/:$//p")"
  local -r SERVICE_ID="$("docker-compose" "ps" "-q" "${FIRST_SERVICE}")"

  if [[ "${SERVICE_ID}" != "" ]]; then
    if ((ABANDON_VOLUME == TRUE)); then
      docker-compose down -v
    else
      docker-compose down
    fi
  fi
}


################################################################################
# Sets up a trap to execute the nominated function for passed signals.
#
# @param trap_function The function to execute when a signal is trapped by the
#                      script.
################################################################################
trap_with_signal() {
  local -r trap_function="${1}"

  shift
  for trapped_signal; do
    trap "${trap_function} ${trapped_signal}" "${trapped_signal}"
  done
}


################################################################################
# Writes log messages (for the script) with a date prefix to a known place.  For
# now, stderr will do.
#
# @param LOG_MESSAGE The message to write.
################################################################################
write_log() {
  LOG_MESSAGE="${1}"

  echo "$("date" "${LOG_DATE_FORMAT}") - ${LOG_MESSAGE}" 1>&2;
}


