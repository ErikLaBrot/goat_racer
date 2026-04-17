# Isaac ROS Visual SLAM on GOAT

## Purpose

This guide covers the current GOAT bringup path for Isaac ROS Visual SLAM on
Jetson Orin Nano with a RealSense D435 first in stereo-only mode, then with the
ESC IMU fused into Visual SLAM.

## Requirements

- Jetson Orin Nano on JetPack 6.2
- ROS 2 Humble
- D435 connected before starting the Isaac ROS dev container
- ESC IMU available through `goat_vesc_ros`
- Docker access on the host

## Known-Good NVIDIA Dev Lane

Bootstrap the workspace first:

```bash
./scripts/ros bootstrap
```

Configure `isaac_ros_common` for the RealSense-capable image:

```bash
cd ros_ws/src/isaac_ros/isaac_ros_common/scripts
echo CONFIG_IMAGE_KEY=ros2_humble.realsense > .isaac_ros_common-config
```

Launch the NVIDIA dev container from the repo root:

```bash
cd /home/goat/goat/goat_racer/ros_ws/src/isaac_ros/isaac_ros_common
./scripts/run_dev.sh -d /home/goat/goat/goat_racer
```

Inside that container, install the Isaac ROS binary runtime packages needed by
the GOAT launch files:

```bash
apt-get update
apt-get install -y \
  ros-humble-isaac-ros-launch-utils \
  ros-humble-isaac-ros-test \
  ros-humble-isaac-ros-visual-slam \
  ros-humble-realsense2-camera
```

Build the GOAT ROS packages in that environment:

```bash
cd /workspaces/isaac_ros-dev/ros_ws
source /opt/ros/humble/setup.bash
colcon build \
  --base-paths /workspaces/isaac_ros-dev/external /workspaces/isaac_ros-dev/ros_ws/src \
  --packages-select goat_vesc goat_vesc_ros goat_teleop goat_ros_launch \
  --packages-ignore isaac_common isaac_ros_launch_utils isaac_ros_test isaac_ros_visual_slam isaac_ros_visual_slam_interfaces
source /workspaces/isaac_ros-dev/ros_ws/install/setup.bash
```

## Bench Bringup

Start stereo-only Visual SLAM:

```bash
ros2 launch goat_ros_launch goat_d435_visual_slam.launch.py
```

When the camera or IMU transforms are known, pass them explicitly:

```bash
ros2 launch goat_ros_launch goat_d435_visual_slam.launch.py \
  camera_x:=0.10 camera_z:=0.22 \
  imu_x:=0.03 imu_z:=0.06 imu_yaw:=1.57
```

## Visual-Inertial Bringup

Start `goat_vesc_ros` with the Visual SLAM-oriented IMU frame ID and covariance
preset:

```bash
ros2 launch goat_vesc_ros goat_vesc.launch.py \
  config_file:=$(ros2 pkg prefix goat_vesc_ros --share)/config/goat_vesc_isaac_vslam.yaml
```

In a second terminal, start Visual SLAM with IMU fusion enabled:

```bash
ros2 launch goat_ros_launch goat_d435_visual_slam.launch.py \
  enable_imu_fusion:=true
```

## GOAT Robot Bringup

Stereo-only full robot bringup:

```bash
ros2 launch goat_ros_launch robot_d435_visual_slam.launch.py
```

Visual-inertial full robot bringup:

```bash
ros2 launch goat_ros_launch robot_d435_visual_slam_vio.launch.py
```

Forward custom sensor launch arguments through the canonical robot entrypoint:

```bash
ros2 launch goat_ros_launch robot.launch.py \
  sensor_launch_file:=$(ros2 pkg prefix goat_ros_launch --share)/launch/goat_d435_visual_slam.launch.py \
  sensor_launch_arguments:="enable_imu_fusion:=true camera_x:=0.10 camera_z:=0.22 imu_yaw:=1.57" \
  vesc_config_file:=$(ros2 pkg prefix goat_vesc_ros --share)/config/goat_vesc_isaac_vslam.yaml
```

## Validation Checklist

- D435 appears reliably in the Isaac ROS dev container.
- `/stereo/left/*` and `/stereo/right/*` publish rectified IR images and camera info.
- `/visual_slam/tracking/odometry` and TF update while moving the camera.
- `/imu/data_raw` publishes host-stamped `sensor_msgs/msg/Imu`.
- `base_link -> camera_link` and `base_link -> esc_imu_link` resolve in TF.
- VIO runs without frame or timestamp errors after `enable_imu_fusion:=true`.

## Limits

- The D435 remains an in-scope bringup target even though NVIDIA officially
  documents D455 and D435i on the `release-3.2` line.
- The default `camera_*` and `imu_*` transforms are zeroed for bench bringup.
  Replace them with measured or calibrated transforms before robot evaluation.
- `goat_vesc_isaac_vslam.yaml` uses bench-only IMU covariance placeholders.
  Replace them with measured values before production use.
