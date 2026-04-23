#!/usr/bin/env bash
# Print the supported fresh-Jetson GOAT deployment flow.
#
# Purpose:
#   Summarize the expected host baseline and the non-mutating command sequence
#   for the GOAT Isaac overlay workflow on a newly provisioned Jetson.
#
# Inputs:
#   None.
#
# Outputs:
#   Prints the current supported deployment checklist and relevant docs.
#
# Usage:
#   ./scripts/robot/bootstrap_jetson.sh
#
# Notes:
#   This script does not make host changes.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

cat <<EOF
Supported GOAT Jetson deployment flow

Expected host baseline:
1. Jetson host with Docker and NVIDIA container runtime support.
2. git-lfs and vcs installed on the host.
3. D435 connected before launching the container.

Recommended verification:
- ./scripts/robot/audit_jetson.sh

Fresh checkout workflow:
1. git clone <goat_racer_repo>
2. cd goat_racer
3. ./scripts/dev/sync_repos.sh
4. ./scripts/dev/enter.sh
5. ./scripts/dev/build_ws.sh
6. ./scripts/ops/run_vslam.sh

Optional maintenance commands:
- ./scripts/dev/build_goat_image.sh
- ./scripts/dev/tag_goat_image.sh
- ./scripts/dev/push_goat_image.sh
- ./scripts/dev/rosdep_install.sh  # fallback when GOAT dependencies change

Primary docs:
- $repo_root/README.md
- $repo_root/docs/isaac_ros_visual_slam.md
EOF
