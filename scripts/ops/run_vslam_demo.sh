#!/usr/bin/env bash
# Launch the GOAT Visual SLAM demo in the supported Isaac ROS workflow.
#
# Purpose:
#   Dispatch to the container-local demo launcher. From the host this launches
#   or reuses the Isaac ROS container; from inside the container it launches
#   directly without re-running host Docker checks.
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
source "$repo_root/scripts/_lib/isaac_container.sh"

container_script="$repo_root/scripts/ops/_run_vslam_demo_in_container.sh"
container_script_in_workspace="$GOAT_CONTAINER_WORKSPACE/scripts/ops/_run_vslam_demo_in_container.sh"
workspace_setup="$repo_root/ros_ws/install/setup.bash"

if [[ ! -f "$container_script" ]]; then
  echo "Internal VSLAM demo helper not found at $container_script." >&2
  exit 1
fi

if goat_is_inside_isaac_container; then
  exec "$container_script" "$@"
fi

if [[ ! -f "$workspace_setup" ]]; then
  echo "Workspace setup file not found at $workspace_setup." >&2
  echo "Run ./scripts/dev/build.sh first." >&2
  exit 1
fi

export TERM="${TERM:-xterm}"
goat_exec_in_isaac_container "$container_script_in_workspace" "$@"
