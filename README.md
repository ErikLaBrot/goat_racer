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

Open a second shell for ROS operations with:

```bash
./scripts/dev/enter.sh
```

`./scripts/dev/bootstrap.sh` is the host-only setup step. It syncs all root
manifests on the host, copies the repo-root Isaac ROS config from
`.isaac_ros_common-config` into
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config` and the
repo-root upstream Docker args from `.isaac_ros_dev-dockerargs` into
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_dev-dockerargs`, then uses the
vendored upstream
`ros_ws/src/isaac_ros_common/scripts/run_dev.sh -d <repo-root>` entrypoint to
pull, build, or reuse the Isaac development container, including the repo-owned
GOAT image overlay that adds Isaac ROS Visual SLAM and basic RViz desktop
debugging tools, then prepare the workspace artifact directories.

`./scripts/dev/build.sh` is container-aware. From the host it uses upstream
`run_dev.sh` to run the internal build helper inside the Isaac container; from
inside the container it runs that helper directly. The build still rebuilds
`goat_vesc` first, then `goat_vesc_ros`, `goat_teleop`, and `goat_ros_launch`
against the shared install space.

`./scripts/ops/run_vslam_demo.sh` is the thin operator-facing launch path. It
is also container-aware: from the host it starts or reuses the Isaac container
through the same upstream `run_dev.sh` entrypoint, and from inside the
container it launches directly. In both cases it sources the built workspace
and launches `goat_ros_launch/sensors.launch.py`.

For manual desktop debugging from inside the container on a local Jetson
session, launch the demo in one terminal, then use `./scripts/dev/enter.sh` in
a second terminal and run `ros2 topic list`, `xeyes`, `glxinfo -B`, or `rviz2`
directly.

## Layout

- `ros_ws/` is the main ROS workspace root.
- `ros_ws/src/goat_ros` is reserved for GOAT ROS packages.
- `ros_ws/src/isaac_ros_common` is the vendored upstream Isaac ROS tooling
  checkout used by `run_dev.sh`.
- `external/` is reserved for non-ROS project dependencies.
- `.devcontainer/` remains a secondary workflow and is not the source of truth
  for the supported Jetson deployment path.

## Additional Docs

- [Devcontainer workflow](docs/devcontainer_workflow.md)
- [Version matrix](docs/version_matrix.md)
- [Isaac ROS Visual SLAM notes](docs/isaac_ros_visual_slam.md)
