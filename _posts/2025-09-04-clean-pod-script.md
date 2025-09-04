---
title: "Xcode 项目清理脚本 clean_pod.sh：开发思路与使用指南"
date: 2025-09-04
categories: [iOS, Tools]
tags: [Xcode, CocoaPods, Bundler, Simulator, Shell]
---

## 前言

在日常 iOS 开发中，Xcode 缓存、CocoaPods、Bundler、模拟器数据等经常成为「神秘问题」的根源：构建失败、无法解析头文件、模拟器存储暴涨、设备支持文件占用几十 GB……为此我写了一个一站式脚本 clean_pod.sh，支持命令行和交互两种方式，覆盖常见的清理与重装动作，尽量做到安全、可视、可回退。

源码位置：<mcfile name="clean_pod.sh" path=/clean_pod.sh"></mcfile>

## 设计目标与整体架构

- 双入口：
  - 命令行参数直达：-p/-b 选择清理 Pods 或 Bundler；-r 重新安装依赖；-i/-I 仅安装
  - 无参数进入交互式菜单，包含组合动作与设备/模拟器管理
- 可靠的项目探测：自动识别 .xcworkspace 优先，否则回退到 .xcodeproj
- 清晰的阶段化输出：彩色提示、结果摘要、失败兜底建议
- 安全优先：仅删除当前项目相关 DerivedData；模拟器与设备支持文件均需二次确认

## 功能概览

- Xcode 缓存
  - 检测 workspace/project 与首个 Scheme
  - xcodebuild clean，删除 ./build，定向清理 DerivedData/<项目名>-*
- CocoaPods
  - 删除 Pods 与 Podfile.lock，可选清理 pod 缓存
  - 重新安装：优先 bundle exec；无 Bundler 时回退 pod install
- Bundler
  - 删除 vendor/bundle 与 .bundle；bundle clean --force
  - 重新安装并恢复本地 path 配置（vendor/bundle）
- 设备与模拟器
  - 查看模拟器占用、删除不可用设备、选择性删除关机设备、抹除全部模拟器数据
  - 显示连接真机；清理 iOS DeviceSupport；清理 Xcode Archives
- 任务收尾
  - 非「仅安装」模式下自动关闭 Xcode；输出清理结果摘要与下一步提示

## 使用方式

- 交互式（推荐）：
  - 直接执行：
    - ./clean_pod.sh
  - 典型选项：
    - 完整清理（Xcode + Pods + Bundler）
    - 完整清理 + 重新安装所有依赖
    - 进入「设备和模拟器管理」
- 命令行直达：
  - 清理 Pods：
    - ./clean_pod.sh -p
  - 清理 Pods 并重装：
    - ./clean_pod.sh -p -r
  - 清理 Bundler 并重装：
    - ./clean_pod.sh -b -r
  - 仅安装 Pods / 仅安装 Bundler：
    - ./clean_pod.sh -i
    - ./clean_pod.sh -I

## 关键实现要点

1) 项目探测与 Scheme 获取
- 优先 workspace，其次 project；Scheme 缺失时回退为项目名
- 清理 DerivedData 仅匹配 "<项目名>-*"，避免误删其他项目缓存

## 代码解析与实现细节

1) 命令行参数解析与交互主循环
- 支持命令行直达和交互式两种入口。当没有参数时进入交互菜单，有参数时使用 case 解析选项。

```bash
# 无参数进入交互式
if [[ "$#" -eq 0 ]]; then
  INTERACTIVE_MODE=true
  run_interactive_mode
else
  # 命令行参数解析
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -h|--help) show_help; exit 0 ;;
      -p|--pods) CLEAN_PODS=true ;;
      -b|--bundle) CLEAN_BUNDLE=true ;;
      -r|--reinstall) REINSTALL_PODS=true; REINSTALL_BUNDLE=true ;;
      -i|--install) INSTALL_ONLY_PODS=true ;;
      -I|--install-bundle) INSTALL_ONLY_BUNDLE=true ;;
      *) echo -e "${RED}错误: 未知选项 $1${NC}" >&2; show_help; exit 1 ;;
    esac
    shift
  done
fi
```

- 交互模式中，先展示菜单，解析选择后按 Enter 执行；设备与模拟器管理为一个独立子菜单。

```bash
run_interactive_mode() {
  while true; do
    show_interactive_menu
    read -r choice
    if handle_interactive_choice "$choice"; then
      echo -e "\n${BLUE}按 Enter 键开始执行...${NC}"
      read -r
      break
    else
      echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
      read -r
    fi
  done
}
```

2) 项目探测与 Scheme 获取
- 优先寻找 .xcworkspace，其次 .xcodeproj，并据此获取第一个 Scheme；若解析不到则回退为项目名。

```bash
WORKSPACE_FILE=$(find . -maxdepth 1 -name "*.xcworkspace" -print -quit)
if [ -z "$WORKSPACE_FILE" ]; then
  PROJECT_FILE=$(find . -maxdepth 1 -name "*.xcodeproj" -print -quit)
  if [ -z "$PROJECT_FILE" ]; then
    echo -e "${YELLOW}⚠️ 未找到 .xcworkspace 或 .xcodeproj 文件${NC}"
  else
    PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)
    USE_PROJECT=true; HAS_XCODE_PROJECT=true
  fi
else
  PROJECT_NAME=$(basename "$WORKSPACE_FILE" .xcworkspace)
  USE_PROJECT=false; HAS_XCODE_PROJECT=true
fi

if [ "$HAS_XCODE_PROJECT" = true ]; then
  if [ "$USE_PROJECT" = true ]; then
    SCHEME=$(xcodebuild -list -project "$PROJECT_FILE" | awk '/Schemes:/ { getline; print $1; exit }')
  else
    SCHEME=$(xcodebuild -list -workspace "$WORKSPACE_FILE" | awk '/Schemes:/ { getline; print $1; exit }')
  fi
  [ -z "$SCHEME" ] && SCHEME="$PROJECT_NAME"
fi
```

- 注意：当前 `awk '/Schemes:/ { getline; print $1; exit }'` 在 Scheme 名包含空格时会截断，建议改为 `xcodebuild -list -json` 并解析 JSON，或对 `-scheme "$SCHEME"` 进行带引号传参。

3) Xcode 构建缓存清理
- 分为 xcodebuild clean、删除本地 build 目录、定向清理 DerivedData 三步，避免误删其他项目缓存。

```bash
# 清理构建
if [ "$USE_PROJECT" = true ]; then
  xcodebuild clean -project "$PROJECT_FILE" -scheme "$SCHEME"
else
  xcodebuild clean -workspace "$WORKSPACE_FILE" -scheme "$SCHEME"
fi

# 删除 build 目录
rm -rf ./build

# 清理当前项目相关 DerivedData
find ~/Library/Developer/Xcode/DerivedData -name "${PROJECT_NAME}-*" -type d -exec rm -rf {} +
```

4) CocoaPods 清理与重装流程
- 先删除 Pods 与 Podfile.lock，再根据是否使用 Bundler 选择安装路径；同时尝试清理 `pod cache`。

```bash
# 删除 Pods 与锁文件
rm -rf Pods Podfile.lock

# 清理 CocoaPods 缓存（可选）
if command -v bundle >/dev/null 2>&1; then
  bundle exec pod cache clean --all 2>/dev/null || pod cache clean --all 2>/dev/null
else
  pod cache clean --all 2>/dev/null || true
fi

# 重新安装（带 Bundler）
if command -v bundle >/dev/null 2>&1; then
  [ "$CLEAN_BUNDLE" = true ] && bundle config set --local path 'vendor/bundle'
  bundle install && bundle exec pod install --clean-install
else
  pod install --clean-install
fi
```

5) Bundler 清理与重装
- 清理 vendor/bundle 与 .bundle；`bundle clean --force` 清理缓存；重装前确保本地 path 指向 vendor/bundle。

```bash
# 清理 Bundler 产物
rm -rf vendor/bundle .bundle

# 清理 Bundler 缓存
if command -v bundle >/dev/null 2>&1; then
  bundle clean --force 2>/dev/null || true
fi

# 重新安装并恢复路径
if command -v bundle >/dev/null 2>&1; then
  bundle config set --local path 'vendor/bundle'
  bundle install
fi
```

6) 模拟器信息与空间占用
- 使用 `simctl list devices --json` 拉取所有模拟器，再结合本地目录体积评估空间占用。

```bash
xcrun simctl list devices --json > /tmp/simulators.json

simulator_dir="$HOME/Library/Developer/CoreSimulator/Devices"
for device_dir in "$simulator_dir"/*; do
  [ -d "$device_dir" ] || continue
  device_size=$(du -sh "$device_dir" 2>/dev/null | cut -f1)
  # 打印设备与占用体积 ...
done
```

- 建议：一次性解析 JSON 并映射到目录，减少多次 `du -sh` 调用的开销。

7) Archives 与 DeviceSupport 清理
- 提示风险并二次确认后删除；统计数量和总占用给出直观反馈。

```bash
archives_dir="$HOME/Library/Developer/Xcode/Archives"
archive_count=$(find "$archives_dir" -name "*.xcarchive" | wc -l | tr -d ' ')
# 确认后删除
rm -rf "$archives_dir"/*
```

8) 任务收尾与摘要
- 清理完成后关闭 Xcode，最后打印各步骤的成功/失败摘要，便于快速排查。

```bash
osascript -e 'tell application "Xcode" to quit' 2>/dev/null || true

echo -e "${BLUE}📋 清理摘要:${NC}"
# 按选项与结果变量输出 ...
```

## 实战建议

- 建议在执行前手动关闭 Xcode（脚本也会在清理结束时尝试关闭）
- Archives 中如有发布用构建，删除前做好备份；DeviceSupport 删除后，首次连机会重新下载
- 网络不稳定时，重装 Pods/Bundler 失败较常见，可重试或切换镜像源

## 潜在问题与改进建议（已验证）

1) 交互式删除模拟器的设备名解析不稳定
- 现实现使用了基于 ") " 的截断，遇到不同 Xcode 输出格式时可能得到空名称
- 建议与“模拟器信息展示”逻辑统一，使用正则截取第一组括号前的完整设备名

2) Scheme 解析与包含空格的 Scheme 名
- 当前通过 xcodebuild -list 在 "Schemes:" 后取下一行并仅取第一个单词，若 Scheme 名包含空格会解析错误
- 建议：在 Schemes 段落中整行截取首个 Scheme，并在 xcodebuild clean 里对 -scheme 进行带引号传递

3) 交互模式从「设备与模拟器管理」返回后的流程
- 选择设备菜单后返回主菜单时，当前实现会继续进入“按 Enter 开始执行”并进入清理阶段（即使没有选择清理项），体验略绕
- 建议：当未设置任何清理/安装选项时，不要 break 主循环，直接回到交互菜单

4) 健壮性与体验
- xcodebuild/pod/bundle 失败时可增加更明确的错误输出与退出码检查
- show_simulators_info 多次调用 simctl 可改为一次 JSON 解析以提升性能
- 可新增 --yes 无交互确认参数，适配 CI 或无人值守场景

## 结语

clean_pod.sh 覆盖了 Xcode 项目日常清理与依赖恢复的高频动作，能在多数构建异常与磁盘占用问题上“一把梭”。根据上述改进项进一步打磨后，脚本在可用性与健壮性上还可以更上一层楼。欢迎按需定制并在团队内推广使用。