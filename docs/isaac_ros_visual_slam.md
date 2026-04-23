# Isaac ROS Visual SLAM on GOAT

## Purpose

This is the supported GOAT bringup guide for Isaac ROS Visual SLAM on a fresh
Jetson. The goal is to keep the normal workflow on `run_dev.sh`, move the heavy
Isaac ROS dependencies into the GOAT image layer, and finish with the GOAT
D435 stereo-only VSLAM demo.

## Requirements

- Jetson Orin Nano on JetPack 6.2 or another Isaac ROS 3.2-capable host
- Docker access on the host
- `git-lfs`
- `vcs`
- D435 connected before launching the container

## Fresh-Jetson Happy Path

From the repo root:

```bash
./scripts/dev/sync_repos.sh
./scripts/dev/enter.sh
./scripts/dev/build_ws.sh
./scripts/ops/run_vslam.sh
```

`./scripts/dev/enter.sh` remains the primary container workflow. It sources the
repo-owned [.isaac_ros_common-config](/home/goat/goat/goat_racer/.isaac_ros_common-config)
and then calls upstream `isaac_ros_common/scripts/run_dev.sh -d /path/to/repo`.
The configured image key is `ros2_humble.realsense.goat`, which resolves the
GOAT Docker layer in `docker/Dockerfile.goat`.

## Default Demo Behavior

- `./scripts/ops/run_vslam.sh` is the normal deployment and demo entrypoint.
- It launches `goat_ros_launch/sensors.launch.py`, which defaults to the GOAT
  D435 Visual SLAM wrapper from `goat_ros_launch/config/sensors.yaml`.
- The default GOAT D435 profile is stereo-only:
  - infrared stereo enabled
  - color disabled
  - depth disabled
  - IMU fusion disabled unless you pass `enable_imu_fusion:=true`
- `./scripts/dev/build_ws.sh` builds GOAT-owned packages only. It does not
  source-build `isaac_ros_visual_slam` in the regular workspace.

CLI overrides still work when needed:

```bash
./scripts/ops/run_vslam.sh sensor_launch_arguments:="enable_imu_fusion:=true"
```

`./scripts/dev/rosdep_install.sh` is kept as a fallback helper for future GOAT
dependency changes, but it is not required for the default flow above.

## Optional Debug Check

If you want to confirm the preinstalled Isaac packages directly inside the
container, run:

```bash
source /opt/ros/humble/setup.bash
source /workspaces/isaac_ros-dev/ros_ws/install/setup.bash
ros2 launch isaac_ros_visual_slam isaac_ros_visual_slam_realsense.launch.py
```

Treat this as an Isaac-side debug check rather than the normal GOAT deployment
path.

## What To Check

- The D435 appears inside the Isaac ROS container.
- `/visual_slam/tracking/odometry` publishes once the camera is moving.
- The GOAT wrapper starts with no extra launch arguments.
- `ros2 pkg prefix isaac_ros_visual_slam` resolves from the installed runtime
  packages in the image rather than a source checkout.

Quick spot checks:

```bash
ros2 topic list | grep visual_slam
ros2 topic echo /visual_slam/tracking/odometry --once
ros2 pkg prefix isaac_ros_visual_slam
ros2 pkg prefix isaac_ros_examples
```

## Limits

- Full robot bringup, teleop, rosbag helpers, and VIO remain available, but the
  primary success path for this stage ends with `./scripts/ops/run_vslam.sh`.
- The GOAT D435 wrapper keeps zeroed default static transforms for bench
  testing; replace them with measured transforms before robot evaluation.
