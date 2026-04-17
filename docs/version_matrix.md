# Version Matrix

This matrix records the current intended Stage 1 baseline for the
project-owned Isaac ROS development environment. Unknown values are marked
explicitly so they can be pinned later without guessing.

| Item | Current Baseline |
| --- | --- |
| Host platform | Jetson-first workflow, amd64 follow-on lane |
| Container Ubuntu userspace | Ubuntu 22.04 / Jammy |
| ROS distro | ROS 2 Humble |
| Isaac ROS release family | `release-3.2` source manifests |
| Isaac ROS apt lane | `release-3` / `release-3.0` |
| JetPack / L4T lane | JetPack 6.x / L4T r36.x |
| CUDA / TensorRT lane | Inherited from the selected base image and Isaac ROS lane; exact project pin TBD |
| Default Jetson base image | `arm64v8/ros:humble-ros-base` with the Isaac ROS apt lane enabled |
| Placeholder amd64 base image | `ros:humble-ros-base-jammy` with the Isaac ROS apt lane enabled |
