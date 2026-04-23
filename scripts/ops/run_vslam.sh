#!/usr/bin/env bash
# Launch the GOAT Visual SLAM sensor wrapper inside the Isaac ROS container.
#
# Purpose:
#   Provide the primary operator-facing GOAT Visual SLAM demo path after the
#   workspace has been built.
#
# Inputs:
#   Optional extra `ros2 launch` arguments forwarded to
#   `goat_ros_launch/sensors.launch.py`.
#
# Outputs:
#   Starts the default GOAT D435 stereo-only Visual SLAM launch path in the
#   Isaac ROS dev container.
#
# Usage:
#   ./scripts/ops/run_vslam.sh
#   ./scripts/ops/run_vslam.sh sensor_launch_arguments:="enable_imu_fusion:=true"
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

exec "$repo_root/scripts/dev/enter.sh" -lc '
set -e

workspace_dir="/workspaces/isaac_ros-dev/ros_ws"
workspace_setup="$workspace_dir/install/setup.bash"

source /opt/ros/humble/setup.bash

if [[ ! -f "$workspace_setup" ]]; then
  echo "Workspace setup file not found at $workspace_setup." >&2
  echo "Run ./scripts/dev/build_ws.sh first." >&2
  exit 1
fi

source "$workspace_setup"
cd "$workspace_dir"
ros2 launch goat_ros_launch sensors.launch.py "$@"
' bash "$@"
