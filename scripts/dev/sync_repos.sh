#!/usr/bin/env bash
# Sync nested repositories from the root manifest files.
#
# Purpose:
#   Import missing repositories and pull existing nested checkouts into the
#   workspace paths owned by the root `.repos` manifests.
#
# Inputs:
#   The root `*.repos` manifest files plus either:
#   - Isaac ROS `run_dev.sh` and container-side `vcstool`, or
#   - host-side `vcs` for the initial bootstrap case.
#
# Outputs:
#   Creates or updates nested repositories under the paths owned by the root
#   manifests and writes the standard Isaac ROS config file.
#
# Usage:
#   ./scripts/dev/sync_repos.sh
#
# Notes:
#   Manifest paths are treated as the source of truth for repository placement.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dev_script="$repo_root/ros_ws/src/isaac_ros_common/scripts/run_dev.sh"
isaac_config_file="$repo_root/ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config"

ensure_standard_isaac_config() {
  local config_dir

  config_dir="$(dirname "$isaac_config_file")"
  if [[ ! -d "$config_dir" ]]; then
    return 0
  fi

  cat > "$isaac_config_file" <<'EOF'
CONFIG_IMAGE_KEY=ros2_humble.realsense
EOF
}

collect_repo_dirs() {
  local repo_path

  repo_dirs=()
  for manifest in "${manifests[@]}"; do
    while IFS= read -r repo_path; do
      [[ -n "$repo_path" ]] || continue
      repo_dirs+=("$repo_root/$repo_path")
    done < <(sed -n 's/^  \([^:][^:]*\):$/\1/p' "$manifest")
  done

  deduped_repo_dirs=()
  for repo_dir in "${repo_dirs[@]}"; do
    skip_dir=0
    for seen_dir in "${deduped_repo_dirs[@]}"; do
      if [[ "$seen_dir" == "$repo_dir" ]]; then
        skip_dir=1
        break
      fi
    done
    if [[ $skip_dir -eq 0 && -d "$repo_dir" ]]; then
      deduped_repo_dirs+=("$repo_dir")
    fi
  done
}

run_host_sync() {
  if ! command -v vcs >/dev/null 2>&1; then
    echo "vcs was not found on the host." >&2
    echo "Install python3-vcstool or sync once the Isaac container path is available." >&2
    exit 1
  fi

  echo "Using host-side vcstool for bootstrap sync..."

  for manifest in "${manifests[@]}"; do
    echo "Importing repositories from ${manifest##*/}..."
    vcs import "$repo_root" < "$manifest"
  done

  if [[ ${#deduped_repo_dirs[@]} -eq 0 ]]; then
    echo "No nested repositories were imported."
    exit 0
  fi

  echo "Pulling manifest-managed repositories..."
  vcs pull "${deduped_repo_dirs[@]}"
}

run_container_sync() {
  local container_script

  container_script=$(cat <<'EOF'
set -e

repo_root="/workspaces/isaac_ros-dev"

if ! command -v vcs >/dev/null 2>&1; then
  echo "vcs was not found inside the Isaac ROS container." >&2
  exit 1
fi

mapfile -t manifests < <(find "$repo_root" -maxdepth 1 -type f -name '*.repos' | sort)
if [[ ${#manifests[@]} -eq 0 ]]; then
  echo "No root-level .repos manifests were found." >&2
  exit 1
fi

repo_dirs=()
for manifest in "${manifests[@]}"; do
  echo "Importing repositories from ${manifest##*/}..."
  vcs import "$repo_root" < "$manifest"

  while IFS= read -r repo_path; do
    [[ -n "$repo_path" ]] || continue
    repo_dirs+=("$repo_root/$repo_path")
  done < <(sed -n 's/^  \([^:][^:]*\):$/\1/p' "$manifest")
done

deduped_repo_dirs=()
for repo_dir in "${repo_dirs[@]}"; do
  skip_dir=0
  for seen_dir in "${deduped_repo_dirs[@]}"; do
    if [[ "$seen_dir" == "$repo_dir" ]]; then
      skip_dir=1
      break
    fi
  done
  if [[ $skip_dir -eq 0 && -d "$repo_dir" ]]; then
    deduped_repo_dirs+=("$repo_dir")
  fi
done

if [[ ${#deduped_repo_dirs[@]} -eq 0 ]]; then
  echo "No nested repositories were imported."
  exit 0
fi

echo "Pulling manifest-managed repositories..."
vcs pull "${deduped_repo_dirs[@]}"
EOF
)

  echo "Using container-side vcstool through Isaac ROS run_dev.sh..."
  "$repo_root/scripts/dev/enter.sh" -lc "$container_script"
}

mapfile -t manifests < <(find "$repo_root" -maxdepth 1 -type f -name '*.repos' | sort)
if [[ ${#manifests[@]} -eq 0 ]]; then
  echo "No root-level .repos manifests were found." >&2
  exit 1
fi

collect_repo_dirs

if [[ -f "$run_dev_script" ]]; then
  ensure_standard_isaac_config
  run_container_sync
else
  run_host_sync
fi

ensure_standard_isaac_config
