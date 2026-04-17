#!/usr/bin/env bash
# Describe the intended Jetson bootstrap flow for Stage 1.
#
# Purpose:
#   Reserve the Jetson bootstrap entrypoint while the repo layout and container
#   workflow are being established.
#
# Inputs:
#   None.
#
# Outputs:
#   Prints the current manual bootstrap checklist.
#
# Usage:
#   ./scripts/robot/bootstrap_jetson.sh
#
# Notes:
#   This script does not make host changes yet.
set -euo pipefail

cat <<'EOF'
Stage 1 does not automate Jetson bootstrap yet.

Recommended manual baseline:
1. Install Docker Engine and the docker compose plugin.
2. Ensure Jetson NVIDIA container runtime support is available on the host.
3. Run ./scripts/robot/audit_jetson.sh to capture the current host state.
4. Start the project dev container with ./scripts/dev/enter.sh.
EOF
