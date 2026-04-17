#!/usr/bin/env bash
# Remove generated workspace build artifacts from `ros_ws`.
#
# Purpose:
#   Delete the generated `build/`, `install/`, and `log/` directories so the
#   workspace can be rebuilt from a clean state.
#
# Inputs:
#   A local repository checkout.
#
# Outputs:
#   Removes generated workspace directories under `ros_ws/`.
#
# Usage:
#   ./scripts/dev/clean_ws.sh
#
# Notes:
#   This only deletes generated workspace artifacts and leaves source trees
#   untouched.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

rm -rf \
  "$repo_root/ros_ws/build" \
  "$repo_root/ros_ws/install" \
  "$repo_root/ros_ws/log"

echo "Removed ros_ws/build, ros_ws/install, and ros_ws/log."
