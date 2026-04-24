#!/usr/bin/env bash
# Launch the GOAT Visual SLAM demo inside the Isaac ROS container.
#
# Purpose:
#   Source the built GOAT workspace in the Isaac ROS container and start the
#   default GOAT D435 Visual SLAM launch path.
#
# Inputs:
#   Optional extra `ros2 launch` arguments forwarded to
#   `goat_ros_launch/sensors.launch.py`.
#
# Outputs:
#   Starts the supported GOAT Visual SLAM demo.
#
# Usage:
#   ./scripts/ops/run_vslam_demo.sh
#   ./scripts/ops/run_vslam_demo.sh sensor_launch_arguments:="enable_imu_fusion:=true"
#
# Notes:
#   Run `./scripts/dev/build.sh` first so `ros_ws/install/setup.bash` exists.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dev_script="$repo_root/ros_ws/src/isaac_ros_common/scripts/run_dev.sh"
workspace_setup="$repo_root/ros_ws/install/setup.bash"

if [[ ! -f "$run_dev_script" ]]; then
  echo "Isaac ROS run_dev.sh was not found at $run_dev_script." >&2
  echo "Run ./scripts/dev/bootstrap.sh first." >&2
  exit 1
fi

if [[ ! -f "$workspace_setup" ]]; then
  echo "Workspace setup file not found at $workspace_setup." >&2
  echo "Run ./scripts/dev/build.sh first." >&2
  exit 1
fi

export TERM="${TERM:-xterm}"

exec "$run_dev_script" -d "$repo_root" -- -lc '
set -e

workspace_dir="/workspaces/isaac_ros-dev/ros_ws"
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
' bash "$@"
