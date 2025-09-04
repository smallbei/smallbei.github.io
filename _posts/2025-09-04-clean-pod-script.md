---
title: "Xcode 项目清理脚本 clean_pod.sh：开发思路与使用指南"
date: 2025-09-04
categories: [iOS, Tools]
tags: [Xcode, CocoaPods, Bundler, Simulator, Shell]
---

## 前言

在实际 iOS 开发中，Xcode 缓存、CocoaPods、Bundler、模拟器数据等经常成为「神秘问题」的根源：构建失败、无法解析头文件、模拟器存储暴涨、设备支持文件占用几十 GB……为此我写了一个一站式脚本 clean_pod.sh，支持命令行和交互两种方式，覆盖常见的清理与重装动作，尽量做到安全、可视、可回退。

源码位置：<mcfile name="clean_pod.sh" path='https://github.com/smallbei/smallbei.github.io/blob/main/clean_pod.sh'></mcfile>

## 设计目标与整体架构

- 双入口：
  - 命令行参数直达：-p/-b 选择清理 Pods 或 Bundler；-r 重新安装依赖；-i/-I 仅安装
  - 无参数进入交互式菜单，包含组合动作与设备/模拟器管理
- 可靠的项目探测：自动识别 .xcworkspace 优先，否则回退到 .xcodeproj
- 清晰的阶段化输出：彩色提示、结果摘要、失败兜底建议
- 安全优先：仅删除当前项目相关 DerivedData；模拟器与设备支持文件均需二次确认

## 功能概览

- Xcode 缓存
  - 自动探测 workspace 或 project，并按三阶段规则选择 Scheme（优先精确匹配项目名；过滤 Tests/UITests/Example/Demo/Sample；最后回退第一个可用）
  - 在 workspace 模式下优先查找同名 .xcodeproj 的共享 schemes，其次使用 workspace 自身的共享 schemes
  - xcodebuild clean，删除 ./build，定向清理 DerivedData/<项目名>-*
- CocoaPods
  - 删除 Pods 与 Podfile.lock，可选清理 pod 缓存
  - 安装策略：检测到 Bundler 时优先 bundle exec；无 Bundler 回退 pod install
  - .bundle/config 的写入与恢复：仅在需要时创建/修复，并始终将 path 指向 vendor/bundle
- Bundler
  - 删除 vendor/bundle 与 .bundle；bundle clean --force
  - 重新安装并恢复本地 path（vendor/bundle）；在仅安装 Pods 且 .bundle/config 不存在时，为 pod 安装做一次性路径配置
- 设备与模拟器
  - 查看模拟器占用、删除不可用设备、选择性删除关机设备、抹除全部模拟器数据
  - 显示连接真机；清理 iOS DeviceSupport；清理 Xcode Archives
- 任务收尾
  - 非「仅安装」模式下自动关闭 Xcode；输出清理结果摘要与下一步提示

## 核心执行流程（TL;DR）

1) 探测项目结构：优先 .xcworkspace，回退 .xcodeproj
2) 解析可用 Schemes，按三阶段规则选中最终 Scheme，并在日志中明确打印
3) 根据选项执行 Xcode 缓存清理（xcodebuild clean + 本地 build + 定向 DerivedData）
4) Pods 清理与安装：
   - 清理 Pods/Podfile.lock 与可选的 pod cache
   - 优先 bundle exec pod install --clean-install；若无 Bundler，回退 pod install --clean-install
5) Bundler 清理与安装：
   - 删除 vendor/bundle 与 .bundle；bundle clean --force
   - bundle config set --local path 'vendor/bundle' + bundle install
6) 设备与模拟器工具箱（可选）：查看/删除/抹除/统计等
7) 收尾：尝试关闭 Xcode，汇总结果

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

1) 项目探测与 Scheme 获取（修复后）
- 优先 workspace，其次 project；Scheme 缺失时回退为项目名
- 三阶段选择规则：
  1. 优先精确匹配项目名同名的 Scheme（例如项目 xxx -> Scheme xxx）
  2. 过滤 Tests/UITests/Example/Demo/Sample 等测试或示例类 Scheme
  3. 仍未命中则回退到第一个可用 Scheme
- 在 workspace 分支中先查找同名 .xcodeproj 的共享 Schemes，再回退到 workspace 自身的共享 Schemes（更贴合多工程聚合场景）
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
- 优先寻找 .xcworkspace，其次 .xcodeproj，并据此获取可用 Schemes；在 workspace 下先尝试同名 .xcodeproj 的共享 Schemes，再回退到 workspace 的共享 Schemes；若最终解析不到则回退为项目名。

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

# 使用 xcodebuild -list -json 解析 Schemes，并做三阶段筛选（略，见脚本）
[ -z "$SCHEME" ] && SCHEME="$PROJECT_NAME"
```

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
- 清理 vendor/bundle 与 .bundle；`bundle clean --force` 清理缓存；重装前确保本地 path 指向 vendor/bundle。仅安装 Pods 时若 .bundle/config 缺失，也会临时写入 path。

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
- 使用 `simctl list devices --json` 拉取所有模拟器，再结合本地目录体积评估空间占用，日志中显示数量与总占用。

```bash
# 获取 json 并统计空间占用（实现细节见脚本）
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

## 修复后的关键改动（What’s new）

- Scheme 选择更智能：精确匹配项目名 > 过滤测试/示例 Scheme > 回退第一个可用；并在 workspace 中优先读取同名 .xcodeproj 的共享 Schemes
- 日志更可验证：明确打印「使用共享的 Scheme: <名称>」与「最终 -scheme 传参」
- Bundler 行为更安全：仅在需要时写入/重建 .bundle/config，且 path 始终固定为 vendor/bundle
- Pods 安装更稳健：在 Bundler 存在时一律 bundle exec；仅安装 Pods 且缺少 .bundle/config 时会做一次性路径配置
- 模拟器信息展示修复：解析 JSON、统一大小统计，避免文本解析误差
- 失败兜底提示更友好：网络/权限/环境问题时给出可操作建议

## 环境与兼容性（Ruby/CocoaPods/Xcode）

- 推荐使用 rbenv 安装 Ruby 3.3.x 或 3.4.x，并在项目根目录设置 .ruby-version 统一团队环境
- 如果遇到 `pod install` 期间 Ruby 扩展崩溃（例如 digest/sha2.bundle 相关），多半是老 Ruby 与新系统 ABI 不兼容，解决思路：
  1. 安装新 Ruby：rbenv install 3.4.3 && rbenv local 3.4.3 && rbenv rehash
  2. 更新 gem 与 bundler：gem update --system && gem install bundler
  3. 清理并重装依赖：rm -rf vendor/bundle .bundle && bundle config set --local path 'vendor/bundle' && bundle install
  4. 重新安装 Pods：bundle exec pod install --clean-install（或直接 pod install）
- 确认 Xcode 命令行工具已选择到当前 Xcode（xcode-select -p）

## 验证清单（你可以这样自检）

- Scheme 选择：脚本输出应包含「使用共享的 Scheme: xxx」或与你项目名一致的 Scheme；xcodebuild 命令行中应看到 `-scheme "xxx"`
- Bundler 路径：执行 `bundle config get path`，应显示 `vendor/bundle`；若你仅安装 Pods 且之前没有 .bundle/config，安装后应能看到该路径被写入
- Pods 安装：`pod install --clean-install` 或 `bundle exec pod install --clean-install` 能顺利完成，无 Ruby 扩展崩溃
- 清理范围：DerivedData 仅清理 `${PROJECT_NAME}-*` 前缀目录，避免误删其他项目

## 实战建议

- 建议在执行前手动关闭 Xcode（脚本也会在清理结束时尝试关闭）
- Archives 中如有发布用构建，删除前做好备份；DeviceSupport 删除后，首次连机会重新下载
- 网络不稳定时，重装 Pods/Bundler 失败较常见，可重试或切换镜像源

## 已实现的改进

1) Scheme 解析与包含空格的 Scheme 名
- 已改进：使用 `xcodebuild -list -json` 结合 Python 解析 JSON，正确获取包含空格的 Scheme 名称
- 增加了错误处理，确保解析失败时能回退到默认 Scheme

2) 交互式删除模拟器的设备名解析
- 已改进：使用 `xcrun simctl list devices --json` 结合 Python 解析 JSON，准确获取设备名称
- 不再依赖文本解析，提高了稳定性和准确性

3) 交互模式从「设备与模拟器管理」返回后的流程
- 已修复：从设备管理菜单返回时，现在会重新显示主菜单，而不是直接进入清理阶段
- 优化了用户体验，避免了无意中执行清理操作

4) 模拟器信息与空间占用
- 已优化：一次性获取所有模拟器目录大小，结合 JSON 解析，减少了多次 `du -sh` 调用
- 提高了性能和准确性