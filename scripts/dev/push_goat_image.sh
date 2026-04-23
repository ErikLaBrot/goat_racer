#!/usr/bin/env bash
# Push the GOAT Isaac image to a remote registry.
#
# Purpose:
#   Tag the locally built GOAT Isaac image with the requested remote reference
#   and push it to a registry.
#
# Inputs:
#   Optional GOAT_IMAGE_ARCH, GOAT_IMAGE_KEY, GOAT_IMAGE_NAME,
#   GOAT_IMAGE_REGISTRY, GOAT_IMAGE_REPOSITORY, and GOAT_IMAGE_TAG environment
#   variables.
#
# Outputs:
#   Pushes the tagged GOAT Isaac image to the configured Docker registry.
#
# Usage:
#   GOAT_IMAGE_REGISTRY=ghcr.io/example ./scripts/dev/push_goat_image.sh
#
# Notes:
#   Requires GOAT_IMAGE_REGISTRY to be set for remote publication.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$script_dir/_goat_image_common.sh"

if [[ -z "${GOAT_IMAGE_REGISTRY:-}" ]]; then
  echo "GOAT_IMAGE_REGISTRY must be set before pushing the GOAT image." >&2
  exit 1
fi

"$script_dir/tag_goat_image.sh"
docker push "$goat_remote_image_ref"
