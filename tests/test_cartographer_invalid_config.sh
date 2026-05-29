#!/usr/bin/env bash
#
# Copyright (C) 2026 SpacemiT (Hangzhou) Technology Co. Ltd.
# SPDX-License-Identifier: Apache-2.0
#

set -euo pipefail

module_dir="${SROBOTIS_ROOT:-$(pwd)}/middleware/ros2/slam/cartographer_run"
artifact_dir="${SROBOTIS_TEST_ARTIFACT_DIR:-${module_dir}/test-artifacts/cartographer-invalid-config}"
log_dir="${artifact_dir}/logs"
log_file="${log_dir}/cartographer_invalid_config.log"
launch_log_file="${log_dir}/cartographer_invalid_config.launch.log"
ros_log_dir="${artifact_dir}/ros_logs"
missing_config="missing_ci_config.lua"
missing_config_pattern="(${missing_config}.*(No such file|not found|cannot open|Unable to read)|((No such file|not found|cannot open|Unable to read).*${missing_config})|configuration_file_resolver.*${missing_config})"

mkdir -p "${log_dir}" "${ros_log_dir}"
: >"${log_file}"
: >"${launch_log_file}"

trap 'set +e
if [[ -n "${launch_pid:-}" ]]; then
  kill -- "-${launch_pid}" >/dev/null 2>&1 || kill "${launch_pid}" >/dev/null 2>&1 || true
  wait "${launch_pid}" >/dev/null 2>&1 || true
fi' EXIT

log() {
  echo "[cartographer-invalid-config] $*" | tee -a "${log_file}"
}

run_logged() {
  log "\$ $*"
  "$@" >>"${log_file}" 2>&1
}

apt_package_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

install_apt_packages() {
  local -a missing_packages=()
  local package

  for package in "$@"; do
    if ! apt_package_installed "${package}"; then
      missing_packages+=("${package}")
    fi
  done

  if [[ ${#missing_packages[@]} -eq 0 ]]; then
    return
  fi

  log "Installing apt packages: ${missing_packages[*]}"
  export DEBIAN_FRONTEND=noninteractive
  run_logged apt-get update
  run_logged apt-get install -y "${missing_packages[@]}"
}

source_ros_setup() {
  set +u
  if [[ -f "${SROBOTIS_OUTPUT_STAGING:-}/setup.bash" ]]; then
    # shellcheck disable=SC1091
    source "${SROBOTIS_OUTPUT_STAGING}/setup.bash"
  elif [[ -f "${SROBOTIS_ROOT:-$(pwd)}/install/setup.bash" ]]; then
    # shellcheck disable=SC1091
    source "${SROBOTIS_ROOT:-$(pwd)}/install/setup.bash"
  elif [[ -f "/opt/ros/humble/setup.bash" ]]; then
    # shellcheck disable=SC1091
    source "/opt/ros/humble/setup.bash"
  fi
  set -u
}

install_apt_packages ros-humble-ros-base ros-humble-cartographer-ros

source_ros_setup

export ROS_LOG_DIR="${ros_log_dir}"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-43}"
export PYTHONUNBUFFERED=1

if ! command -v ros2 >/dev/null 2>&1; then
  log "ERROR: ros2 command not found"
  exit 1
fi

log "Verifying launch fails for missing configuration_basename=${missing_config}"
setsid ros2 launch cartographer_run cartographer_2d.launch.py \
  configuration_directory:="${module_dir}/config" \
  configuration_basename:="${missing_config}" \
  >>"${launch_log_file}" 2>&1 &
launch_pid=$!

deadline=$((SECONDS + 20))
while [[ ${SECONDS} -lt ${deadline} ]]; do
  if grep -Eqi "${missing_config_pattern}" "${launch_log_file}"; then
    cat "${launch_log_file}" >>"${log_file}"
    log "Observed expected missing configuration error."
    log "CARTOGRAPHER INVALID CONFIG TEST PASSED."
    exit 0
  fi

  if ! kill -0 "${launch_pid}" >/dev/null 2>&1; then
    if wait "${launch_pid}"; then
      log "ERROR: launch unexpectedly succeeded for missing configuration"
      tee -a "${log_file}" <"${launch_log_file}" >&2
      exit 1
    fi

    cat "${launch_log_file}" >>"${log_file}"
    if grep -Eqi "${missing_config_pattern}" "${launch_log_file}"; then
      log "Observed expected missing configuration error."
      log "CARTOGRAPHER INVALID CONFIG TEST PASSED."
      exit 0
    fi
    break
  fi

  sleep 0.5
done

log "ERROR: did not observe the expected missing configuration error within 20s"
tee -a "${log_file}" <"${launch_log_file}" >&2
exit 1
