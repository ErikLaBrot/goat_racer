#!/usr/bin/env bash
# Build the GOAT ROS workspace inside the development container.
#
# Purpose:
#   Run the focused Stage 2A workspace build inside the Isaac ROS dev
#   container.
#
# Inputs:
#   Optional extra `colcon build` arguments.
#
# Outputs:
#   Writes build, install, and log artifacts under `ros_ws/`.
#
# Usage:
#   ./scripts/dev/build_ws.sh
#   ./scripts/dev/build_ws.sh --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo
#
# Notes:
#   Builds the GOAT overlay packages only and does not source-build Isaac ROS
#   Visual SLAM in the regular workspace flow.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

exec "$repo_root/scripts/dev/enter.sh" -lc '
set -e

repo_root="/workspaces/isaac_ros-dev"
workspace_dir="$repo_root/ros_ws"
goat_ros_dir="$workspace_dir/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

source /opt/ros/humble/setup.bash

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir. Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir. Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

mapfile -t goat_packages < <(
  colcon list \
    --base-paths "$goat_vesc_dir" "$goat_ros_dir" \
    --names-only
)

if [[ ${#goat_packages[@]} -eq 0 ]]; then
  echo "No GOAT packages found under $goat_ros_dir or $goat_vesc_dir." >&2
  exit 1
fi

cd "$repo_root"
colcon build \
  --base-paths "$goat_vesc_dir" "$goat_ros_dir" \
  --build-base "$workspace_dir/build" \
  --install-base "$workspace_dir/install" \
  --log-base "$workspace_dir/log" \
  --symlink-install \
  --packages-select "${goat_packages[@]}" \
  "$@"
' bash "$@"
