# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT workspace.
It owns shared notes, higher-level docs, Docker-based ROS development
orchestration, and the canonical `.repos` manifest for component checkouts.

## Layout

- `docker/`
  Development container definitions.
- `scripts/`
  Helper scripts for ROS build and test flows across sibling repos.
- `notes/`
  Workspace notes and TODOs.
- `goat_racer.repos`
  Component checkout manifest.

## Component Repositories

The current sibling repository set is:

- `../goat_vesc`
- `../goat_ros_drivers`
- `../goat_ros_control`

## ROS Workflow

From the `goat_racer` repo root:

```bash
scripts/ros up
scripts/ros build --packages-select goat_vesc goat_vesc_ros goat_teleop
scripts/ros test --packages-select goat_vesc goat_vesc_ros goat_teleop
```

The helper script builds the sibling repos through `colcon --base-paths` and
stores workspace artifacts under `goat_racer/goat_ws/`.

## `.repos`

`goat_racer.repos` currently uses the published GitHub remote for `goat_vesc`
and local file URLs for `goat_ros_drivers` and `goat_ros_control` until those
repositories are hosted remotely.
