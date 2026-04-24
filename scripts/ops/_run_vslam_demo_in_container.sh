#!/usr/bin/env bash
# Internal GOAT VSLAM demo launcher for use inside the Isaac ROS container only.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace_dir="$repo_root/ros_ws"
workspace_setup="$workspace_dir/install/setup.bash"

source /opt/ros/humble/setup.bash

if [[ ! -f "$workspace_setup" ]]; then
  echo "Workspace setup file not found at $workspace_setup." >&2
  echo "Run ./scripts/dev/build.sh first." >&2
  exit 1
fi

source "$workspace_setup"
cd "$workspace_dir"
ros2 launch goat_ros_launch sensors.launch.py "$@"
