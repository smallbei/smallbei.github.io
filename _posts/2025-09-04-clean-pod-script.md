---
title: "Xcode 项目清理脚本 clean_pod.sh：模块化架构与使用指南"
date: 2025-09-04
categories: [iOS, Tools]
tags: [Xcode, CocoaPods, Bundler, Shell, CLI]
---

## 前言

在实际 iOS 开发中，Xcode 缓存、CocoaPods、Bundler 等经常成为「神秘问题」的根源：构建失败、无法解析头文件、依赖冲突……为此我重构了 clean_pod.sh 脚本，采用模块化的子命令架构，支持命令行和交互两种方式，专注于核心的清理与重装功能，做到安全、可视、可组合。

源码位置：[clean_pod.sh](https://github.com/smallbei/smallbei.github.io/blob/main/clean_pod.sh)

## 设计理念与架构重构

### 核心设计原则

- **模块化架构**：每个子命令专注单一职责，便于维护和扩展
- **灵活组合**：支持全局选项与子命令的自由组合
- **安全优先**：仅清理当前项目相关缓存，避免误删其他项目
- **用户友好**：提供交互式和命令行两种使用方式

### 整体架构

```
clean_pod.sh
├── 全局选项 (--workdir, --yes, --dry-run, --help)
├── 子命令系统
│   ├── xcode-clean          # Xcode 构建缓存清理
│   ├── pods-clean           # CocoaPods 清理
│   ├── pods-install         # CocoaPods 安装
│   ├── pods-reinstall       # CocoaPods 重装
│   ├── bundler-clean        # Bundler 清理
│   ├── bundler-install      # Bundler 安装
│   ├── bundler-reinstall    # Bundler 重装
│   ├── clean-all            # 完整清理
│   ├── clean-and-reinstall  # 清理后重装
│   └── interactive          # 交互式菜单
└── 核心模块
    ├── 项目检测模块
    ├── Xcode 清理模块
    ├── CocoaPods 管理模块
    ├── Bundler 管理模块
    └── 交互式界面模块
```

## 功能概览

### Xcode 缓存管理
- **智能项目探测**：优先 .xcworkspace，回退 .xcodeproj
- **Scheme 选择策略**：精确匹配项目名 → 过滤测试/示例 → 回退第一个可用
- **定向清理**：仅清理项目相关的 DerivedData 目录
- **构建清理**：xcodebuild clean + 删除本地 build 目录

### CocoaPods 管理
- **清理功能**：删除 Pods 目录、Podfile.lock、清理 pod 缓存
- **安装策略**：检测 Bundler 时优先 bundle exec，否则直接 pod install
- **路径配置**：自动配置 .bundle/config 指向 vendor/bundle

### Bundler 管理
- **清理功能**：删除 vendor/bundle、.bundle 目录，清理 Bundler 缓存
- **安装功能**：配置本地路径并安装依赖
- **路径管理**：统一使用 vendor/bundle 作为本地安装路径

### 交互式界面
- **直观菜单**：分类展示各种操作选项
- **工作目录选择**：支持指定或交互式输入工作目录
- **操作确认**：重要操作前提供确认提示

## 使用方式

### 命令行模式

#### 基本语法
```bash
./clean_pod.sh [全局选项] <子命令> [子命令参数]
```

#### 全局选项
- `-C, --workdir <path>`：指定工作目录（默认：当前目录）
- `-y, --yes`：对需要确认的操作自动确认
- `-n, --dry-run`：仅显示将要执行的命令，不实际执行
- `-h, --help`：显示帮助信息

#### 子命令列表
- `xcode-clean`：清理 Xcode 构建缓存与项目 DerivedData
- `pods-clean`：清理 Pods 与缓存
- `pods-install`：安装 Pods 依赖
- `pods-reinstall`：先清理 Pods 再安装
- `bundler-clean`：清理 Bundler 缓存与目录
- `bundler-install`：安装 Bundler 依赖
- `bundler-reinstall`：先清理 Bundler 再安装
- `clean-all`：清理 Xcode + Pods + Bundler（不安装）
- `clean-and-reinstall`：清理后安装 Pods 与 Bundler
- `interactive`：进入交互式菜单

#### 使用示例
```bash
# 清理当前项目的 Xcode 缓存
./clean_pod.sh xcode-clean

# 清理指定项目的 Pods 并重装
./clean_pod.sh --workdir ~/Projects/MyApp pods-reinstall

# 完整清理并重装所有依赖
./clean_pod.sh clean-and-reinstall

# 预览将要执行的操作（不实际执行）
./clean_pod.sh --dry-run clean-all

# 进入交互式菜单
./clean_pod.sh interactive
```

### 交互式模式

直接运行脚本进入交互式菜单：
```bash
./clean_pod.sh
```

交互式菜单提供以下选项：
1. 清理 Xcode 缓存
2. 清理 Pods 目录
3. 清理 Pods 目录 + 重新安装
4. 仅重新安装 Pods 依赖
5. 清理 Bundler 缓存
6. 清理 Bundler 缓存 + 重新安装
7. 仅重新安装 Bundler 依赖
8. 完整清理 (Xcode + Pods + Bundler)
9. 完整清理 + 重新安装所有依赖
0. 退出

## 核心执行流程

### 项目检测流程
1. **工作目录初始化**：解析全局选项或交互式输入
2. **项目文件探测**：优先查找 .xcworkspace，回退到 .xcodeproj
3. **Scheme 解析**：使用三阶段策略选择最佳 Scheme
4. **环境验证**：检查必要的工具和依赖

### 清理执行流程
1. **Xcode 清理**：关闭 Xcode → 清理 build 目录 → 清理项目 DerivedData → 执行 xcodebuild clean
2. **CocoaPods 清理**：删除 Pods 目录和 Podfile.lock → 清理 pod 缓存
3. **Bundler 清理**：删除 vendor/bundle 和 .bundle → 清理 Bundler 缓存
4. **安装流程**：配置路径 → 安装依赖 → 自动打开 Xcode

## 关键实现要点

### 1. 模块化架构设计

#### 全局选项与子命令解析
```bash
parse_global_flags() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -C|--workdir)
                WORKING_DIR="$2"; shift 2 ;;
            -y|--yes)
                ASSUME_YES=true; shift ;;
            -n|--dry-run)
                DRY_RUN=true; shift ;;
            -h|--help)
                print_usage; exit 0 ;;
            interactive|xcode-clean|pods-clean|...)
                SUBCOMMAND="$1"; shift
                SUBCOMMAND_ARGS=("$@"); break ;;
            *)
                SUBCOMMAND="$1"; shift
                SUBCOMMAND_ARGS=("$@"); break ;;
        esac
    done
}
```

#### 子命令封装（单一职责）
```bash
cmd_xcode_clean() { detect_xcode_project && get_project_scheme; clean_xcode_build_cache; }
cmd_pods_clean() { clean_cocoapods; }
cmd_pods_install() { install_cocoapods; }
cmd_pods_reinstall() { clean_cocoapods; install_cocoapods; }
cmd_bundler_clean() { clean_bundler; }
cmd_bundler_install() { install_bundler; }
cmd_bundler_reinstall() { clean_bundler; install_bundler; }
cmd_clean_all() { cmd_xcode_clean; cmd_pods_clean; cmd_bundler_clean; }
cmd_clean_and_reinstall() { cmd_xcode_clean; cmd_pods_clean; cmd_bundler_clean; cmd_pods_install; cmd_bundler_install; }
```

### 2. 项目检测与 Scheme 选择

#### 智能项目探测
```bash
detect_xcode_project() {
    # 优先查找 .xcworkspace
    WORKSPACE_FILE=$(find . -maxdepth 1 -name "*.xcworkspace" -print -quit)
    if [ -n "$WORKSPACE_FILE" ]; then
        PROJECT_NAME=$(basename "$WORKSPACE_FILE" .xcworkspace)
        HAS_XCODE_PROJECT=true
        return 0
    fi
    
    # 回退到 .xcodeproj
    PROJECT_FILE=$(find . -maxdepth 1 -name "*.xcodeproj" -print -quit)
    if [ -n "$PROJECT_FILE" ]; then
        PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)
        HAS_XCODE_PROJECT=true
        return 0
    fi
    
    return 1
}
```

#### 三阶段 Scheme 选择策略
```bash
select_preferred_scheme() {
    local schemes="$1"
    
    # 1. 精确匹配项目名
    local preferred=$(echo "$schemes" | awk -v name="$PROJECT_NAME" '$0==name{print;exit}')
    if [ -n "$preferred" ]; then
        echo "$preferred"
        return
    fi
    
    # 2. 排除测试和示例
    preferred=$(echo "$schemes" | grep -viE '(tests$|uitests$|ui tests$|example$|demo$|sample$)' | head -n 1)
    if [ -n "$preferred" ]; then
        echo "$preferred"
        return
    fi
    
    # 3. 第一个可用的
    echo "$schemes" | head -n 1
}
```

### 3. 安全执行机制

#### 命令执行封装
```bash
safe_execute() {
    local cmd="$1"
    local description="$2"
    local silent="${3:-false}"
    
    if [ "$DRY_RUN" = true ]; then
        print_info "DRY RUN: $cmd"
        return 0
    fi
    
    if [ "$silent" = true ]; then
        eval "$cmd" >/dev/null 2>&1
    else
        print_progress "$description"
        eval "$cmd"
    fi
    
    return $?
}
```

#### 项目特定 DerivedData 清理
```bash
clean_project_derived_data() {
    local derived_data_dir="$HOME/Library/Developer/Xcode/DerivedData"
    
    # 仅清理项目相关的目录
    local project_dirs=$(find "$derived_data_dir" -maxdepth 1 -type d -name "${PROJECT_NAME}-*" 2>/dev/null)
    
    # 计算总大小并显示
    local total_size=0
    local dir_count=0
    while IFS= read -r dir; do
        if [ -d "$dir" ]; then
            local size=$(du -sk "$dir" 2>/dev/null | cut -f1)
            total_size=$((total_size + size))
            dir_count=$((dir_count + 1))
        fi
    done <<< "$project_dirs"
    
    # 安全删除
    while IFS= read -r dir; do
        if [ -d "$dir" ]; then
            safe_execute "rm -rf '$dir'" "删除 $(basename "$dir")" true
        fi
    done <<< "$project_dirs"
}
```

### 4. CocoaPods 管理实现

#### 清理功能
```bash
clean_cocoapods() {
    if [ ! -f "Podfile" ]; then
        print_warning "未找到Podfile，跳过CocoaPods清理"
        return 0
    fi
    
    print_progress "清理CocoaPods..."
    close_xcode_if_running
    
    # 删除Pods目录和Podfile.lock
    safe_execute "rm -rf Pods Podfile.lock" "删除Pods目录和Podfile.lock" true
    
    # 清理CocoaPods缓存
    if command_exists bundle; then
        safe_execute "bundle exec pod cache clean --all" "清理CocoaPods缓存" true
    else
        safe_execute "pod cache clean --all" "清理CocoaPods缓存" true
    fi
    
    print_success "CocoaPods清理完成"
}
```

#### 安装功能
```bash
install_cocoapods() {
    if [ ! -f "Podfile" ]; then
        print_error_and_exit "未找到Podfile，无法安装CocoaPods依赖"
    fi
    
    print_progress "安装CocoaPods依赖..."
    close_xcode_if_running
    
    # 确保Bundler配置正确
    if command_exists bundle && [ ! -f ".bundle/config" ]; then
        safe_execute "bundle config set --local path 'vendor/bundle'" "配置Bundler路径" true
    fi
    
    # 安装依赖
    if command_exists bundle; then
        safe_execute "bundle install" "安装Bundler依赖"
        if [ $? -eq 0 ]; then
            safe_execute "bundle exec pod install --clean-install" "安装CocoaPods依赖"
        else
            print_error_and_exit "bundle install 失败"
        fi
    else
        safe_execute "pod install --clean-install" "安装CocoaPods依赖"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "CocoaPods依赖安装完成"
        # 自动打开 Xcode
        detect_xcode_project && get_project_scheme
        open_primary_in_xcode
    else
        print_error_and_exit "CocoaPods依赖安装失败"
    fi
}
```

### 5. Bundler 管理实现

#### 清理与安装
```bash
clean_bundler() {
    if [ ! -f "Gemfile" ]; then
        print_warning "未找到Gemfile，跳过Bundler清理"
        return 0
    fi
    
    print_progress "清理Bundler..."
    close_xcode_if_running
    
    # 删除vendor/bundle和.bundle目录
    safe_execute "rm -rf vendor/bundle" "删除Bundler目录" true
    
    # 清理Bundler缓存
    if command_exists bundle; then
        safe_execute "bundle clean --force" "清理Bundler缓存" true
    fi
    
    print_success "Bundler清理完成"
}

install_bundler() {
    if [ ! -f "Gemfile" ]; then
        print_error_and_exit "未找到Gemfile，无法安装Bundler依赖"
    fi
    
    if ! command_exists bundle; then
        print_error_and_exit "未安装Bundler，请先安装: gem install bundler"
    fi
    
    print_progress "安装Bundler依赖..."
    close_xcode_if_running
    
    # 配置Bundler路径
    safe_execute "bundle config set --local path 'vendor/bundle'" "配置Bundler路径" true
    
    # 安装依赖
    safe_execute "bundle install" "安装Bundler依赖"
    
    if [ $? -eq 0 ]; then
        print_success "Bundler依赖安装完成"
        # 若项目存在，自动打开
        detect_xcode_project && get_project_scheme
        open_primary_in_xcode
    else
        print_error_and_exit "Bundler依赖安装失败"
    fi
}
```

### 6. 交互式界面实现

#### 主菜单显示
```bash
show_main_menu() {
    clear
    print_message "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
    print_message "$CYAN" "║                    🧹 项目清理工具 (新版本)                  ║"
    print_message "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
    echo
    if [ -n "$WORKING_DIR" ]; then
        print_message "$GRAY" "当前工作目录: $WORKING_DIR"
        echo
    fi
    print_message "$YELLOW" "请选择要执行的操作:"
    echo
    print_message "$GREEN" "📱 Xcode 相关操作:"
    print_message "$BLUE" "  1) 清理 Xcode 缓存 (DerivedData, Build目录)"
    echo
    print_message "$GREEN" "🔗 CocoaPods 相关操作:"
    print_message "$BLUE" "  2) 清理 Pods 目录"
    print_message "$BLUE" "  3) 清理 Pods 目录 + 重新安装"
    print_message "$BLUE" "  4) 仅重新安装 Pods 依赖"
    echo
    print_message "$GREEN" "💎 Bundler 相关操作:"
    print_message "$BLUE" "  5) 清理 Bundler 缓存"
    print_message "$BLUE" "  6) 清理 Bundler 缓存 + 重新安装"
    print_message "$BLUE" "  7) 仅重新安装 Bundler 依赖"
    echo
    print_message "$GREEN" "🔄 组合操作:"
    print_message "$BLUE" "  8) 完整清理 (Xcode + Pods + Bundler)"
    print_message "$BLUE" "  9) 完整清理 + 重新安装所有依赖"
    echo
    print_message "$RED" "  0) 退出"
    echo
    echo -n "请输入选项 (0-9): "
}
```

#### 用户选择处理
```bash
handle_user_choice() {
    local choice=$1
    detect_xcode_project && get_project_scheme
    case $choice in
        1) clean_xcode_build_cache ;;
        2) clean_cocoapods ;;
        3) clean_cocoapods; install_cocoapods ;;
        4) install_cocoapods ;;
        5) clean_bundler ;;
        6) clean_bundler; install_bundler ;;
        7) install_bundler ;;
        8) clean_xcode_build_cache; clean_cocoapods; clean_bundler ;;
        9) clean_xcode_build_cache; clean_cocoapods; clean_bundler; install_bundler; install_cocoapods ;;
        0) print_info "退出程序"; exit 0 ;;
        *) print_error_and_exit "无效选项，请重新选择" ;;
    esac
    return 0
}
```

## 架构优势与改进

### 模块化设计优势
- **单一职责**：每个子命令专注一个功能，便于维护和测试
- **组合灵活**：支持全局选项与子命令的自由组合
- **扩展性强**：新增功能只需添加新的子命令和对应函数
- **代码复用**：核心功能模块可在不同子命令间复用

### 用户体验改进
- **命令行友好**：支持 `--dry-run` 预览操作，`--yes` 自动确认
- **工作目录灵活**：支持 `--workdir` 指定任意项目目录
- **错误处理完善**：每个步骤都有详细的错误提示和解决建议
- **自动恢复**：安装完成后自动打开 Xcode 项目

### 安全性提升
- **项目隔离**：仅清理当前项目相关的 DerivedData
- **操作可逆**：提供 `--dry-run` 模式预览所有操作
- **依赖检测**：安装前检查必要的工具和文件
- **路径管理**：统一使用 vendor/bundle 作为本地安装路径


## 使用建议

### 日常开发流程
1. **项目初始化**：`./clean_pod.sh --workdir ~/Projects/MyApp interactive`
2. **快速清理**：`./clean_pod.sh xcode-clean`
3. **依赖重装**：`./clean_pod.sh clean-and-reinstall`
4. **预览操作**：`./clean_pod.sh --dry-run clean-all`