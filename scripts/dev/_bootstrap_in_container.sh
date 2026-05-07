#!/usr/bin/env bash
# Internal GOAT bootstrap helper for use inside the Isaac ROS container only.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/_lib/isaac_container.sh"

workspace_dir="$repo_root/ros_ws"
goat_ros_dir="$workspace_dir/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

goat_safe_source /opt/ros/humble/setup.bash

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir after bootstrap sync." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir after bootstrap sync." >&2
  exit 1
fi

rosdep update
rosdep install --from-paths "$goat_vesc_dir" "$goat_ros_dir" --ignore-src --rosdistro humble -r -y

mkdir -p "$workspace_dir/build" "$workspace_dir/install" "$workspace_dir/log"
