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
#   Defaults to the minimum Stage 2A package set for Visual SLAM bringup.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

exec "$repo_root/scripts/dev/enter.sh" -lc '
set -e

workspace_dir="/workspaces/isaac_ros-dev/ros_ws"

source /opt/ros/humble/setup.bash

if ! find "$workspace_dir/src" -name package.xml -print -quit | grep -q .; then
  echo "No ROS packages found under $workspace_dir/src. Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

cd "$workspace_dir"
colcon build --symlink-install --packages-up-to isaac_ros_visual_slam goat_ros_launch "$@"
' bash "$@"
