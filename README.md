# Cartographer Run

## 项目简介

基于 Google Cartographer 的 ROS2 SLAM 启动包，提供激光雷达建图与定位功能的启动文件和配置。用于机器人在未知环境中实时构建栅格地图。

## 功能特性

**支持：**
- 2D 激光雷达 SLAM 建图
- 实时栅格地图发布
- 可配置的地图分辨率和发布周期
- 支持仿真时间模式


## 快速开始

### 环境准备

- ROS2 Humble
- cartographer_ros 包
- nav2_map_server 包（用于 `map_saver_cli` 保存栅格地图）
- 2D 激光雷达（发布 `/scan` 话题）

### 构建编译

```bash
# 在工作空间根目录
colcon build --packages-select cartographer_run
source install/setup.bash
```

### 运行示例

```bash
ros2 launch cartographer_run cartographer_2d.launch.py
```

### 保存地图

建图完成后，先结束当前轨迹，再保存 Cartographer 状态文件（`.pbstream`）：

```bash
ros2 service call /finish_trajectory cartographer_ros_msgs/srv/FinishTrajectory "{trajectory_id: 0}"
ros2 service call /write_state cartographer_ros_msgs/srv/WriteState "{filename: '${HOME}/map.pbstream', include_unfinished_submaps: true}"
```

如需保存给导航栈使用的 2D 栅格地图（`.pgm` + `.yaml`），可在 `/map` 正常发布后执行：

```bash
ros2 run nav2_map_server map_saver_cli -f ${HOME}/map
```

### 纯定位运行示例

`cartographer_2d_localization_launch.py` 用于加载已保存的 `.pbstream` 地图并进入纯定位模式。启动时必须指定 `load_state_filename`：

```bash
ros2 launch cartographer_run cartographer_2d_localization_launch.py load_state_filename:=${HOME}/map.pbstream
```

如需指定自定义配置文件或调整栅格地图发布参数：

```bash
ros2 launch cartographer_run cartographer_2d_localization_launch.py \
  load_state_filename:=${HOME}/map.pbstream \
  configuration_basename:=lds_2d_localization.lua \
  resolution:=0.05 \
  publish_period_sec:=1.0
```

**启动参数：**

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `use_sim_time` | false | 是否使用仿真时间 |
| `resolution` | 0.05 | 地图分辨率 (m/cell) |
| `publish_period_sec` | 1.0 | 地图发布周期 (秒) |
| `configuration_directory` | config/ | 配置文件目录 |
| `configuration_basename` | lds_2d.lua / lds_2d_localization.lua | 配置文件名；建图默认 `lds_2d.lua`，纯定位默认 `lds_2d_localization.lua` |
| `load_state_filename` | 无 | 纯定位模式加载的 `.pbstream` 地图文件路径，使用 `cartographer_2d_localization_launch.py` 时必填 |

**话题订阅：**

| 话题 | 类型 | 说明 |
|------|------|------|
| `/scan` | sensor_msgs/LaserScan | 2D 激光扫描数据 |

**话题发布：**

| 话题 | 类型 | 说明 |
|------|------|------|
| `/map` | nav_msgs/OccupancyGrid | 栅格地图 |
| `/submap_list` | cartographer_ros_msgs/SubmapList | 子地图列表 |

## 详细使用

详见 [Cartographer ROS 官方文档](https://google-cartographer-ros.readthedocs.io/)

## 常见问题

**Q: 建图漂移严重？**
A: 确保 TF 变换正确，调整 `lds_2d.lua` 中的参数。

**Q: 地图更新慢？**
A: 减小 `publish_period_sec` 参数值。

**Q: 无法启动节点？**
A: 确认 `cartographer_ros` 包已正确安装。

## 版本与发布

| 版本 | 日期 | 说明 |
|------|------|------|
| 0.0.1 | 2026-02 | 初始版本，支持 2D SLAM |

## 贡献方式

欢迎提交 Issue 和 Pull Request。

## License

本组件源码文件头声明为 Apache-2.0，最终以本目录 `LICENSE` 文件为准。
