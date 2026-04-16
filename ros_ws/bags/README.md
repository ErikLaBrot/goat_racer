# ROS Bag Storage

This directory is the default host-persistent storage location for rosbags
recorded through the top-level demo helper.

```bash
./scripts/demo record:=true
```

Inside the ROS container, this directory is mounted at:

```text
/workspace/goat_racer/ros_ws/bags
```

Recorded bag contents are intentionally ignored by Git. Keep only lightweight
notes or manifests under version control.
