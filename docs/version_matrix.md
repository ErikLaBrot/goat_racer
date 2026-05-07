# Version Matrix

This matrix records the current intended Stage 1 baseline for the
project-owned Isaac ROS development environment. Unknown values are marked
explicitly so they can be pinned later without guessing.

| Item | Current Baseline |
| --- | --- |
| Host platform | Jetson-first workflow, amd64 follow-on lane |
| Container Ubuntu userspace | Ubuntu 22.04 / Jammy |
| ROS distro | ROS 2 Humble |
| Isaac ROS release family | `release-3.2` `isaac_ros_common` checkout plus prebuilt runtime packages |
| Isaac ROS apt lane | `release-3` / `release-3.0` |
| JetPack / L4T lane | JetPack 6.x / L4T r36.x |
| CUDA / TensorRT lane | Inherited from the selected base image and Isaac ROS lane; exact project pin TBD |
| Default image key | `ros2_humble.realsense.goat` |
| Default Jetson base image | Upstream Isaac ROS RealSense image plus the repo GOAT overlay selected by `run_dev.sh` |
| Upstream Docker args file | Repo-owned `.isaac_ros_dev-dockerargs`, synced into vendored Isaac scripts during bootstrap |
| Placeholder amd64 base image | Same upstream image flow, architecture override not yet the primary lane |
