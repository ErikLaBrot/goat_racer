#!/usr/bin/env bash
# Shared helpers for GOAT Isaac image management scripts.
#
# Purpose:
#   Load the repo-owned Isaac ROS config and compute the local and remote image
#   references used by the GOAT image build, tag, and push helpers.
#
# Inputs:
#   Optional GOAT_IMAGE_* environment variables.
#
# Outputs:
#   Exports shell variables for GOAT image naming and validates required tools.
#
# Usage:
#   source ./scripts/dev/_goat_image_common.sh
#
# Notes:
#   Intended to be sourced by sibling scripts under scripts/dev.
set -euo pipefail

goat_image_repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
goat_image_config_file="$goat_image_repo_root/.isaac_ros_common-config"
goat_image_layers_script="$goat_image_repo_root/ros_ws/src/isaac_ros/isaac_ros_common/scripts/build_image_layers.sh"

if [[ ! -f "$goat_image_layers_script" ]]; then
  echo "Isaac ROS build_image_layers.sh was not found at $goat_image_layers_script." >&2
  echo "Run ./scripts/dev/sync_repos.sh first." >&2
  return 1
fi

if [[ -f "$goat_image_config_file" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$goat_image_config_file"
  set +a
fi

GOAT_IMAGE_ARCH="${GOAT_IMAGE_ARCH:-aarch64}"
GOAT_IMAGE_KEY="${GOAT_IMAGE_KEY:-ros2_humble.realsense.goat}"
GOAT_IMAGE_NAME="${GOAT_IMAGE_NAME:-isaac_ros_dev-${GOAT_IMAGE_ARCH}-goat_racer}"
GOAT_IMAGE_REPOSITORY="${GOAT_IMAGE_REPOSITORY:-$GOAT_IMAGE_NAME}"
GOAT_IMAGE_TAG="${GOAT_IMAGE_TAG:-latest}"

goat_image_key_with_arch="${GOAT_IMAGE_ARCH}.${GOAT_IMAGE_KEY}"
goat_remote_image_ref="${GOAT_IMAGE_REPOSITORY}:${GOAT_IMAGE_TAG}"
if [[ -n "${GOAT_IMAGE_REGISTRY:-}" ]]; then
  goat_remote_image_ref="${GOAT_IMAGE_REGISTRY}/${goat_remote_image_ref}"
fi
