#!/usr/bin/env bash
set -e

ros_setup="/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
workspace_setup="/workspace/goat_racer/ros_ws/install/setup.bash"

if [[ -f "$ros_setup" ]]; then
  # shellcheck disable=SC1090
  source "$ros_setup"
fi

if [[ -f "$workspace_setup" ]]; then
  # shellcheck disable=SC1090
  source "$workspace_setup"
fi

if [[ $# -eq 0 ]]; then
  set -- bash
fi

exec "$@"
