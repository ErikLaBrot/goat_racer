#!/usr/bin/env bash
# Sync nested repositories from the root manifest files.
#
# Purpose:
#   Import missing repositories and pull existing nested checkouts into the
#   workspace paths owned by the root `.repos` manifests.
#
# Inputs:
#   Host-side `vcs`, `git`, and the root `*.repos` manifest files.
#
# Outputs:
#   Creates or updates nested repositories under `external/` and `ros_ws/src/`.
#
# Usage:
#   ./scripts/dev/sync_repos.sh
#
# Notes:
#   Manifest paths are treated as the source of truth for repository placement.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v vcs >/dev/null 2>&1; then
  echo "vcs was not found on the host. Install python3-vcstool and try again." >&2
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
