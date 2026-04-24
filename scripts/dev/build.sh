#!/usr/bin/env bash
# Build GOAT packages inside the Isaac ROS development container.
#
# Purpose:
#   Rebuild the fast GOAT C++ library first, then rebuild the GOAT ROS
#   workspace packages against the same install space.
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
run_dev_script="$repo_root/ros_ws/src/isaac_ros_common/scripts/run_dev.sh"
goat_ros_dir="$repo_root/ros_ws/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

if [[ ! -f "$run_dev_script" ]]; then
  echo "Isaac ROS run_dev.sh was not found at $run_dev_script." >&2
  echo "Run ./scripts/dev/bootstrap.sh first." >&2
  exit 1
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

exec "$run_dev_script" -d "$repo_root" -- -lc '
set -e

repo_root="/workspaces/isaac_ros-dev"
workspace_dir="$repo_root/ros_ws"
goat_ros_dir="$workspace_dir/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

source /opt/ros/humble/setup.bash

mkdir -p "$workspace_dir/build" "$workspace_dir/install" "$workspace_dir/log"

colcon build \
  --base-paths "$goat_vesc_dir" \
  --build-base "$workspace_dir/build" \
  --install-base "$workspace_dir/install" \
  --log-base "$workspace_dir/log" \
  --symlink-install \
  --packages-select goat_vesc \
  "$@"

workspace_setup="$workspace_dir/install/setup.bash"
if [[ ! -f "$workspace_setup" ]]; then
  echo "Workspace setup file not found at $workspace_setup after building goat_vesc." >&2
  exit 1
fi

source "$workspace_setup"

colcon build \
  --base-paths "$goat_vesc_dir" "$goat_ros_dir" \
  --build-base "$workspace_dir/build" \
  --install-base "$workspace_dir/install" \
  --log-base "$workspace_dir/log" \
  --symlink-install \
  --packages-select goat_vesc_ros goat_teleop goat_ros_launch \
  "$@"
' bash "$@"
