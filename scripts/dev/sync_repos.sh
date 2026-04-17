#!/usr/bin/env bash
# Sync nested repositories from the root manifest files.
#
# Purpose:
#   Import missing repositories and pull existing nested checkouts into the
#   workspace paths owned by the root `.repos` manifests.
#
# Inputs:
#   Docker with `docker compose`, the root `*.repos` files, and an optional
#   `GOAT_ENV_FILE` override.
#
# Outputs:
#   Creates or updates nested repositories under `external/` and `ros_ws/src/`.
#
# Usage:
#   ./scripts/dev/sync_repos.sh
#   GOAT_ENV_FILE=docker/env/amd64.env ./scripts/dev/sync_repos.sh
#
# Notes:
#   Manifest paths are treated as the source of truth for repository placement.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_running

container_script=$(cat <<'EOF'
set -euo pipefail

repo_root="/workspace/goat_racer"
mkdir -p "$repo_root/external" "$repo_root/ros_ws/src"

register_safe_directories() {
  git config --global --add safe.directory "$repo_root"

  while IFS= read -r git_dir; do
    git config --global --add safe.directory "$(dirname "$git_dir")"
  done < <(
    find "$repo_root/external" "$repo_root/ros_ws/src" \
      -mindepth 1 -maxdepth 4 -type d -name .git 2>/dev/null | sort
  )
}

register_safe_directories

mapfile -t manifests < <(find "$repo_root" -maxdepth 1 -type f -name '*.repos' | sort)
if [[ ${#manifests[@]} -eq 0 ]]; then
  echo "No root-level .repos manifests were found." >&2
  exit 1
fi

for manifest in "${manifests[@]}"; do
  echo "Importing repositories from ${manifest##*/}..."
  vcs import "$repo_root" < "$manifest"
done

register_safe_directories

roots=()
for candidate in "$repo_root/external" "$repo_root/ros_ws/src"; do
  if find "$candidate" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
    roots+=("$candidate")
  fi
done

if [[ ${#roots[@]} -eq 0 ]]; then
  echo "No nested repositories were imported."
  exit 0
fi

echo "Pulling existing nested repositories..."
vcs pull "${roots[@]}"
EOF
)

run_in_container "$container_script"
