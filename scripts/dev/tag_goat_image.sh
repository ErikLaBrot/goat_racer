#!/usr/bin/env bash
# Tag the local GOAT Isaac image for publication.
#
# Purpose:
#   Apply a registry/repository/tag reference to the locally built GOAT Isaac
#   image without pushing it.
#
# Inputs:
#   Optional GOAT_IMAGE_ARCH, GOAT_IMAGE_KEY, GOAT_IMAGE_NAME,
#   GOAT_IMAGE_REGISTRY, GOAT_IMAGE_REPOSITORY, and GOAT_IMAGE_TAG environment
#   variables.
#
# Outputs:
#   Creates or refreshes a Docker tag for the GOAT Isaac image.
#
# Usage:
#   ./scripts/dev/tag_goat_image.sh
#
# Notes:
#   Defaults to tagging the local image as <repository>:latest when no registry
#   settings are supplied.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$script_dir/_goat_image_common.sh"

if ! docker image inspect "$GOAT_IMAGE_NAME" >/dev/null 2>&1; then
  echo "Local GOAT image not found: $GOAT_IMAGE_NAME" >&2
  echo "Run ./scripts/dev/build_goat_image.sh first." >&2
  exit 1
fi

docker tag "$GOAT_IMAGE_NAME" "$goat_remote_image_ref"
echo "Tagged $GOAT_IMAGE_NAME as $goat_remote_image_ref"
