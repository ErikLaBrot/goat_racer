#!/usr/bin/env bash
# Run lightweight first-time setup inside the GOAT devcontainer.
#
# Purpose:
#   Refresh rosdep metadata, attempt a workspace dependency install when ROS
#   packages are present, and print a short status summary.
#
# Inputs:
#   A running devcontainer with the repository mounted at
#   `/workspace/goat_racer`.
#
# Outputs:
#   Updates rosdep metadata and may install missing package dependencies.
#
# Usage:
#   /bin/bash .devcontainer/post_create.sh
#
# Notes:
#   Safe to rerun. This script skips workspace dependency installation when the
#   workspace has not been synced yet.
set -euo pipefail

workspace_root="/workspace/goat_racer"
workspace_src="$workspace_root/ros_ws/src"
ros_setup="/opt/ros/${ROS_DISTRO:-humble}/setup.bash"

git config --global --add safe.directory "$workspace_root"

if [[ -f "$ros_setup" ]]; then
  # shellcheck disable=SC1090
  source "$ros_setup"
fi

echo "Refreshing rosdep metadata..."
rosdep update

if find "$workspace_src" -name package.xml -print -quit | grep -q .; then
  echo "Installing workspace dependencies from $workspace_src..."
  rosdep install --from-paths "$workspace_src" --ignore-src --rosdistro "${ROS_DISTRO:-humble}" -r -y
else
  echo "No ROS packages found under $workspace_src yet. Skipping rosdep install."
fi

echo
echo "GOAT devcontainer is ready."
echo "Workspace root: $workspace_root"
echo "ROS distro: ${ROS_DISTRO:-humble}"
