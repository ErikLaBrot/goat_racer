#!/usr/bin/env bash
# Install ROS package dependencies from the workspace source tree.
#
# Purpose:
#   Refresh rosdep metadata inside the Isaac ROS dev container and install the
#   dependency packages required by the GOAT source trees.
#
# Inputs:
#   A synced workspace source tree and a host that can launch the Isaac ROS
#   dev container.
#
# Outputs:
#   Installs missing system dependencies and prebuilt Isaac ROS runtime
#   packages inside the development container.
#
# Usage:
#   ./scripts/dev/rosdep_install.sh
#
# Notes:
#   Scopes rosdep to GOAT-owned sources so Isaac ROS packages are consumed as
#   Debian packages rather than built from source.
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

rosdep update
rosdep install --from-paths "$goat_vesc_dir" "$goat_ros_dir" --ignore-src --rosdistro humble -r -y
'
