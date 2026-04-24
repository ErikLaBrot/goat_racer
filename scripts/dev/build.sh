#!/usr/bin/env bash
# Build GOAT packages in the supported Isaac ROS workflow.
#
# Purpose:
#   Dispatch to the container-local GOAT build helper. From the host this
#   launches or reuses the Isaac ROS container; from inside the container it
#   builds directly without re-running host Docker checks.
#
# Inputs:
#   Optional extra `colcon build` arguments forwarded to both build phases.
#
# Outputs:
#   Updates `ros_ws/build`, `ros_ws/install`, and `ros_ws/log` with the latest
#   GOAT package artifacts.
#
# Usage:
#   ./scripts/dev/build.sh
#   ./scripts/dev/build.sh --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo
#
# Notes:
#   Run `./scripts/dev/bootstrap.sh` first on a fresh checkout or robot.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
container_script="$repo_root/scripts/dev/_build_in_container.sh"

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
  echo "Internal build helper not found at $container_script." >&2
  exit 1
fi

if is_inside_isaac_container; then
  exec "$container_script" "$@"
fi

export TERM="${TERM:-xterm}"
launcher="$(resolve_isaac_launcher)"

exec "$launcher" -d "$repo_root" -- /workspaces/isaac_ros-dev/scripts/dev/_build_in_container.sh "$@"
