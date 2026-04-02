# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT workspace.
It owns shared notes, higher-level docs, Docker-based ROS development
orchestration, and the canonical `.repos` manifest for component checkouts.

## Layout

- `docker/`
  Development container definitions.
- `ros_ws/`
  The higher-level ROS workspace root. This holds the ROS repositories plus
  generated build/install/log artifacts.
- `external/`
  External library checkouts that are consumed by the ROS workspace but are not
  tracked by `goat_racer`.
- `scripts/`
  Helper scripts for ROS build and test flows across sibling repos.
- `notes/`
  Workspace notes and TODOs.
- `goat_racer.repos`
  Component checkout manifest.

## Component Repositories

The current desired checkout layout is:

- `./external/goat_vesc`
- `./ros_ws/goat_ros_drivers`
- `./ros_ws/goat_ros_control`

## ROS Workflow

From the `goat_racer` repo root:

```bash
scripts/ros up
scripts/ros build --packages-select goat_vesc goat_vesc_ros goat_teleop
scripts/ros test --packages-select goat_vesc goat_vesc_ros goat_teleop
```

The helper script builds the sibling repos through `colcon --base-paths` and
stores workspace artifacts under `goat_racer/ros_ws/`.

## `.repos`

`goat_racer.repos` encodes the intended local checkout paths so ROS repos land
inside `ros_ws/` and external libraries land inside `external/`.
