# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT robot
workspace. It keeps GOAT-owned ROS packages in a thin local overlay on top of
an Isaac ROS RealSense image extended with a small GOAT-specific Docker layer.

## Requirements

- Docker with NVIDIA runtime support on the target host
- `git-lfs`
- `vcs`
- Permission to run Docker commands on the host

## Deployment Workflow

1. Clone the repository.
2. Sync nested repositories:

   ```bash
   ./scripts/dev/sync_repos.sh
   ```

3. Enter the GOAT Isaac development container:

   ```bash
   ./scripts/dev/enter.sh
   ```

4. Build the GOAT overlay packages:

   ```bash
   ./scripts/dev/build_ws.sh
   ```

5. Launch the default GOAT D435 Visual SLAM demo:

   ```bash
   ./scripts/ops/run_vslam.sh
   ```

`./scripts/dev/enter.sh` is the primary way to enter the dev environment. It
sources the repo-owned [.isaac_ros_common-config](/home/goat/goat/goat_racer/.isaac_ros_common-config)
and then execs upstream `isaac_ros_common/scripts/run_dev.sh -d <repo-root>`.
The default image key is `ros2_humble.realsense.goat`, which adds the heavy
Isaac ROS Visual SLAM packages to the GOAT image layer instead of source
building them in the normal workspace.

`./scripts/dev/build_ws.sh` builds GOAT-owned packages only from
`ros_ws/src/goat_ros` and `external/goat_vesc`. The default VSLAM demo is the
GOAT D435 stereo-only path: infrared stereo enabled, color and depth disabled,
and IMU fusion off unless you opt in explicitly.

`./scripts/dev/rosdep_install.sh` remains available as a fallback helper when
GOAT package dependencies change, but it is not part of the normal fresh-Jetson
happy path.

## Image Helpers

Build or publish the GOAT image explicitly when needed:

```bash
./scripts/dev/build_goat_image.sh
./scripts/dev/tag_goat_image.sh
GOAT_IMAGE_REGISTRY=ghcr.io/example ./scripts/dev/push_goat_image.sh
```

These scripts use env-driven naming:

- `GOAT_IMAGE_ARCH` defaults to `aarch64`
- `GOAT_IMAGE_KEY` defaults to `ros2_humble.realsense.goat`
- `GOAT_IMAGE_NAME` defaults to `isaac_ros_dev-${GOAT_IMAGE_ARCH}-goat_racer`
- `GOAT_IMAGE_REGISTRY`, `GOAT_IMAGE_REPOSITORY`, and `GOAT_IMAGE_TAG` are optional

## Layout

- `ros_ws/` is the main ROS workspace root.
- `ros_ws/src/goat_ros` is reserved for GOAT ROS packages.
- `ros_ws/src/isaac_ros` keeps the upstream `isaac_ros_common` source checkout
  used by `run_dev.sh`.
- `external/` is reserved for non-ROS project dependencies.
- `docker/` contains the GOAT image overlay layer used by Isaac ROS image
  resolution.
- `.devcontainer/` remains a secondary workflow and is not the source of truth
  for the supported Jetson deployment path.

## Additional Docs

- [Devcontainer workflow](/home/goat/goat/goat_racer/docs/devcontainer_workflow.md)
- [Version matrix](/home/goat/goat/goat_racer/docs/version_matrix.md)
- [Isaac ROS Visual SLAM notes](/home/goat/goat/goat_racer/docs/isaac_ros_visual_slam.md)
