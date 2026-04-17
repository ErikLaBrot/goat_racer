# Isaac ROS Visual SLAM on GOAT

## Purpose

This is the Stage 2A baseline bringup guide for Isaac ROS Visual SLAM. The goal
is to use Isaac ROS tooling directly, keep the workspace readable, and document
one clean upstream example path plus one clean GOAT wrapper path.

## Requirements

- Jetson Orin Nano on JetPack 6.2 or another Isaac ROS 3.2-capable host
- Docker access on the host
- `git-lfs`
- `vcs`
- D435 connected before launching the container

## Prepare The Workspace

From the repo root:

```bash
./scripts/dev/sync_repos.sh
./scripts/dev/rosdep_install.sh
./scripts/dev/build_ws.sh
```

Enter the Isaac ROS dev container when you want an interactive shell:

```bash
./scripts/dev/enter.sh
```

`./scripts/dev/enter.sh` sources the repo-owned
[.isaac_ros_common-config](/home/goat/goat/goat_racer/.isaac_ros_common-config)
and then calls upstream `isaac_ros_common/scripts/run_dev.sh -d /path/to/repo`.

## Launch Target 1: Upstream Isaac ROS Example

Inside the container:

```bash
source /opt/ros/humble/setup.bash
source /workspaces/isaac_ros-dev/ros_ws/install/setup.bash
ros2 launch isaac_ros_visual_slam isaac_ros_visual_slam_realsense.launch.py
```

This is the supported Isaac ROS RealSense example path and should be the first
baseline check when you want to confirm the Isaac side is healthy.

## Launch Target 2: GOAT Sensor Wrapper

Inside the container:

```bash
source /opt/ros/humble/setup.bash
source /workspaces/isaac_ros-dev/ros_ws/install/setup.bash
ros2 launch goat_ros_launch sensors.launch.py
```

Or from the host:

```bash
./scripts/ops/run_vslam.sh
```

The GOAT wrapper uses the package-installed default config at
`goat_ros_launch/config/sensors.yaml` and keeps CLI override support:

```bash
ros2 launch goat_ros_launch sensors.launch.py \
  config_file:=/path/to/alternate_sensors.yaml
```

If you pass a bad config path, `sensors.launch.py` should fail clearly before it
tries to include the wrapped launch file.

## What To Check

- The D435 appears inside the Isaac ROS container.
- `/visual_slam/tracking/odometry` publishes once the camera is moving.
- The upstream example starts without repo-specific wrapper logic.
- The GOAT wrapper starts with no extra launch arguments.

Quick spot checks:

```bash
ros2 topic list | grep visual_slam
ros2 topic echo /visual_slam/tracking/odometry --once
```

## Limits

- This stage does not make teleop, VESC, robot-level bringup, rosbag helpers,
  or VIO part of the primary success path.
- The GOAT D435 wrapper keeps zeroed default static transforms for bench
  testing; replace them with measured transforms before robot evaluation.
