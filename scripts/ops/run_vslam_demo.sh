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
container_script="$repo_root/scripts/ops/_run_vslam_demo_in_container.sh"

is_inside_isaac_container() {
  [[ -f /.dockerenv || "${ISAAC_ROS_WS:-}" == "/workspaces/isaac_ros-dev" ]]
}

resolve_isaac_launcher() {
  local scripts_dir="$repo_root/ros_ws/src/isaac_ros_common/scripts"
  local launcher=""

  if [[ -f "$scripts_dir/run_dev.sh" ]]; then
    launcher="$scripts_dir/run_dev.sh"
  elif [[ -f "$scripts_dir/enter.sh" ]]; then
    launcher="$scripts_dir/enter.sh"
  fi

  if [[ -z "$launcher" ]]; then
    echo "Isaac ROS launcher was not found under $scripts_dir." >&2
    echo "Run ./scripts/dev/bootstrap.sh first." >&2
    exit 1
  fi

  printf '%s\n' "$launcher"
}

if [[ ! -f "$container_script" ]]; then
  echo "Internal VSLAM demo helper not found at $container_script." >&2
  exit 1
fi

if is_inside_isaac_container; then
  exec "$container_script" "$@"
fi

export TERM="${TERM:-xterm}"
launcher="$(resolve_isaac_launcher)"

exec "$launcher" -d "$repo_root" -- /workspaces/isaac_ros-dev/scripts/ops/_run_vslam_demo_in_container.sh "$@"
