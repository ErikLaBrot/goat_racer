#!/usr/bin/env bash
# Print a small Jetson host readiness summary.
#
# Purpose:
#   Capture the basic host details that matter for the Stage 1 Jetson-first
#   development flow before deeper bringup automation exists.
#
# Inputs:
#   A Jetson host or another Linux machine where the user wants a quick audit.
#
# Outputs:
#   Prints host OS, Jetson release, Docker availability, and NVIDIA runtime
#   details when present.
#
# Usage:
#   ./scripts/robot/audit_jetson.sh
#
# Notes:
#   This is intentionally lightweight and non-destructive.
set -euo pipefail

echo "Host kernel:"
uname -a
echo

echo "Jetson release:"
if [[ -f /etc/nv_tegra_release ]]; then
  cat /etc/nv_tegra_release
else
  echo "/etc/nv_tegra_release not found."
fi
echo

echo "Docker:"
if command -v docker >/dev/null 2>&1; then
  docker --version
  docker info --format '{{json .Runtimes}}' 2>/dev/null || echo "Unable to read Docker runtimes."
else
  echo "docker not found."
fi
