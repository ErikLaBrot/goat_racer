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
source "$repo_root/scripts/_lib/isaac_container.sh"

container_script="$repo_root/scripts/dev/_build_in_container.sh"
container_script_in_workspace="$GOAT_CONTAINER_WORKSPACE/scripts/dev/_build_in_container.sh"
goat_ros_dir="$repo_root/ros_ws/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

if [[ ! -f "$container_script" ]]; then
  echo "Internal build helper not found at $container_script." >&2
  exit 1
fi

if goat_is_inside_isaac_container; then
  exec "$container_script" "$@"
fi

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir." >&2
  echo "Run ./scripts/dev/bootstrap.sh first." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir." >&2
  echo "Run ./scripts/dev/bootstrap.sh first." >&2
  exit 1
fi

export TERM="${TERM:-xterm}"
goat_exec_in_isaac_container "$container_script_in_workspace" "$@"
