#!/usr/bin/env bash
# Install ROS package dependencies from the workspace source tree.
#
# Purpose:
#   Refresh rosdep metadata inside the Isaac ROS dev container and install the
#   dependency packages required by the ROS workspace source tree.
#
# Inputs:
#   A synced workspace source tree and a host that can launch the Isaac ROS
#   dev container.
#
# Outputs:
#   Installs missing system dependencies inside the development container.
#
# Usage:
#   ./scripts/dev/rosdep_install.sh
#
# Notes:
#   Requires at least one ROS package under `ros_ws/src`.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

exec "$repo_root/scripts/dev/enter.sh" -lc '
set -e

workspace_dir="/workspaces/isaac_ros-dev/ros_ws"
workspace_src="$workspace_dir/src"

source /opt/ros/humble/setup.bash

if ! find "$workspace_src" -name package.xml -print -quit | grep -q .; then
  echo "No ROS packages found under $workspace_src. Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

cd "$workspace_dir"
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro humble -r -y
'
