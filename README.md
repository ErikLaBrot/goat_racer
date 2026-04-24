# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT robot
workspace. It keeps GOAT-owned ROS packages separate from the vendored
`isaac_ros_common` checkout and uses prebuilt Isaac ROS packages inside the
development container to simplify setup.

## Requirements

- Docker with NVIDIA runtime support on the target host
- `git-lfs`
- `vcs`
- Permission to run Docker commands on the host

## Deployment Workflow

1. Clone the repository.
2. Prepare a fresh checkout or robot:

   ```bash
   ./scripts/dev/bootstrap.sh
   ```

3. Build the GOAT packages:

   ```bash
   ./scripts/dev/build.sh
   ```

4. Launch the default GOAT D435 Visual SLAM demo:

   ```bash
   ./scripts/ops/run_vslam_demo.sh
   ```

Normal iteration uses:

```bash
./scripts/dev/build.sh
./scripts/ops/run_vslam_demo.sh
```

`./scripts/dev/bootstrap.sh` syncs all root manifests, ensures the standard
Isaac ROS config file exists at
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config`, launches the
upstream Isaac development container, installs GOAT dependency packages, and
prepares the workspace artifact directories.

`./scripts/dev/build.sh` calls upstream
`ros_ws/src/isaac_ros_common/scripts/run_dev.sh -d <repo-root>`, builds
`goat_vesc` first, then rebuilds `goat_vesc_ros`, `goat_teleop`, and
`goat_ros_launch` against the shared install space.

`./scripts/ops/run_vslam_demo.sh` is the thin operator-facing launch path. It
starts the Isaac container, sources the built workspace, and launches
`goat_ros_launch/sensors.launch.py`.

## Layout

- `ros_ws/` is the main ROS workspace root.
- `ros_ws/src/goat_ros` is reserved for GOAT ROS packages.
- `ros_ws/src/isaac_ros_common` is the vendored upstream Isaac ROS tooling
  checkout used by `run_dev.sh`.
- `external/` is reserved for non-ROS project dependencies.
- `.devcontainer/` remains a secondary workflow and is not the source of truth
  for the supported Jetson deployment path.

## Additional Docs

- [Devcontainer workflow](/home/goat/goat/goat_racer/docs/devcontainer_workflow.md)
- [Version matrix](/home/goat/goat/goat_racer/docs/version_matrix.md)
- [Isaac ROS Visual SLAM notes](/home/goat/goat/goat_racer/docs/isaac_ros_visual_slam.md)
