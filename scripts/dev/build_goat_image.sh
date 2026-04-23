#!/usr/bin/env bash
# Build the GOAT Isaac overlay image locally.
#
# Purpose:
#   Build the layered GOAT Isaac image on top of Isaac ROS RealSense using the
#   repo-owned config and Docker search path.
#
# Inputs:
#   Optional GOAT_IMAGE_ARCH, GOAT_IMAGE_KEY, and GOAT_IMAGE_NAME environment
#   variables.
#
# Outputs:
#   Produces or refreshes the local Docker image used by ./scripts/dev/enter.sh.
#
# Usage:
#   ./scripts/dev/build_goat_image.sh
#
# Notes:
#   Requires ros_ws/src/isaac_ros/isaac_ros_common to be present.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$script_dir/_goat_image_common.sh"

exec "$goat_image_layers_script" \
  --image_key "$goat_image_key_with_arch" \
  --image_name "$GOAT_IMAGE_NAME"
