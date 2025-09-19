#!/bin/bash

# =============================================================================
# Xcode项目清理和依赖管理工具
# 全新重构版本 - 更清晰的模块化结构
# =============================================================================

# 定义颜色常量
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;37m'
readonly NC='\033[0m' # No Color

# 全局配置
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认设置
CLEAN_PODS=false
REINSTALL_PODS=false
CLEAN_BUNDLE=false
REINSTALL_BUNDLE=false
INSTALL_ONLY_PODS=false
INSTALL_ONLY_BUNDLE=false
INTERACTIVE_MODE=false
DRY_RUN=false
ASSUME_YES=false

# 工作目录（所有操作将基于该目录执行）
WORKING_DIR=""

# 项目信息
PROJECT_NAME=""
PROJECT_FILE=""
WORKSPACE_FILE=""
SCHEME=""
HAS_XCODE_PROJECT=false

# =============================================================================
# 工具函数
# =============================================================================

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# 打印使用帮助
print_usage() {
    cat <<'EOF'
用法: clean_pod_new.sh [全局选项] <子命令> [子命令参数]

全局选项:
  -C, --workdir <path>   指定工作目录（默认: 当前目录；interactive 模式下会询问）
  -y, --yes               对需要确认的操作自动确认（非交互更友好）
  -n, --dry-run           仅显示将要执行的命令，不实际执行
  -h, --help              显示帮助

子命令（遵循单一职责，组合由调用方编排）:
  interactive                     进入交互式菜单

  xcode-clean                     清理 Xcode 构建缓存与项目 DerivedData

  pods-clean                      清理 Pods 与缓存
  pods-install                    安装 Pods 依赖
  pods-reinstall                  先清理 Pods 再安装

  bundler-clean                   清理 Bundler 缓存与目录
  bundler-install                 安装 Bundler 依赖
  bundler-reinstall               先清理 Bundler 再安装

  clean-all                       清理 Xcode + Pods + Bundler（不安装）
  clean-and-reinstall             清理后安装 Pods 与 Bundler

示例:
  ./clean_pod_new.sh --workdir ~/Projects/App xcode-clean
  ./clean_pod_new.sh -n xcode-clean
EOF
}

# 检查 Xcode 是否运行
is_xcode_running() {
    pgrep -x Xcode >/dev/null 2>&1
}

# 关闭 Xcode（若在运行）
close_xcode_if_running() {
    if is_xcode_running; then
        safe_execute 'osascript -e "tell application \"Xcode\" to quit"' "关闭 Xcode" true
        # 等待退出完成（最多 10 秒）
        for _ in {1..20}; do
            is_xcode_running || break
            sleep 0.5
        done
    fi
}

# 打开工作区或项目到 Xcode
open_primary_in_xcode() {
    local xcode_app="/Applications/Xcode.app"
    local target_path=""
    if [ -n "$WORKSPACE_FILE" ] && [ -e "$WORKSPACE_FILE" ]; then
        target_path="$(cd "$(dirname "$WORKSPACE_FILE")" && pwd)/$(basename "$WORKSPACE_FILE")"
    elif [ -n "$PROJECT_FILE" ] && [ -e "$PROJECT_FILE" ]; then
        target_path="$(cd "$(dirname "$PROJECT_FILE")" && pwd)/$(basename "$PROJECT_FILE")"
    fi
    if [ -n "$target_path" ]; then
        safe_execute "open -a '$xcode_app' --args -ApplePersistenceIgnoreState YES '$target_path'" "打开 Xcode: $(basename "$target_path")" true
    else
        print_warning "未找到可打开的 .xcworkspace 或 .xcodeproj"
    fi
}

# 解析全局参数与子命令
SUBCOMMAND=""
SUBCOMMAND_ARGS=()
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
            interactive|xcode-clean|pods-clean|pods-install|pods-reinstall|bundler-clean|bundler-install|bundler-reinstall|clean-all|clean-and-reinstall)
                SUBCOMMAND="$1"; shift
                SUBCOMMAND_ARGS=("$@"); break ;;
            *)
                # 将第一个未知位置参数视为子命令，方便拓展
                SUBCOMMAND="$1"; shift
                SUBCOMMAND_ARGS=("$@"); break ;;
        esac
    done
}

# 子命令封装（单一动作）
cmd_xcode_clean() { detect_xcode_project && get_project_scheme; clean_xcode_build_cache; }
cmd_pods_clean() { clean_cocoapods; }
cmd_pods_install() { install_cocoapods; }
cmd_pods_reinstall() { clean_cocoapods; install_cocoapods; }
cmd_bundler_clean() { clean_bundler; }
cmd_bundler_install() { install_bundler; }
cmd_bundler_reinstall() { clean_bundler; install_bundler; }
cmd_clean_all() { cmd_xcode_clean; cmd_pods_clean; cmd_bundler_clean; }
cmd_clean_and_reinstall() { cmd_xcode_clean; cmd_pods_clean; cmd_bundler_clean; cmd_pods_install; cmd_bundler_install; }
:

:

# 打印错误消息并退出
print_error_and_exit() {
    print_message "$RED" "❌ $1"
    exit 1
}

# 打印成功消息
print_success() {
    print_message "$GREEN" "✅ $1"
}

# 打印警告消息
print_warning() {
    print_message "$YELLOW" "⚠️ $1"
}

# 打印信息消息
print_info() {
    print_message "$BLUE" "ℹ️ $1"
}

# 打印进度消息
print_progress() {
    print_message "$CYAN" "🔄 $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安全执行命令
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

# 初始化工作目录：优先使用第一个参数，否则交互输入
init_working_directory() {
    local input_dir="$1"
    if [ -n "$input_dir" ]; then
        if [ -d "$input_dir" ]; then
            WORKING_DIR="$(cd "$input_dir" && pwd)"
        else
            print_warning "传入目录不存在: $input_dir"
        fi
    fi

    if [ -z "$WORKING_DIR" ]; then
        if [ "$INTERACTIVE_MODE" = true ]; then
            while [ -z "$WORKING_DIR" ]; do
                echo -n "请输入项目工作目录路径: "
                read -r input_dir
                if [ -d "$input_dir" ]; then
                    WORKING_DIR="$(cd "$input_dir" && pwd)"
                else
                    print_warning "目录无效，请重试"
                fi
            done
        else
            WORKING_DIR="$(pwd)"
        fi
    fi

    print_success "已设置工作目录: $WORKING_DIR"
    cd "$WORKING_DIR" || print_error_and_exit "无法切换到工作目录"
}

# =============================================================================
# 项目检测模块
# =============================================================================

# 检测Xcode项目文件
detect_xcode_project() {
    print_progress "检测Xcode项目文件..."
    
    # 查找 .xcworkspace 文件
    WORKSPACE_FILE=$(find . -maxdepth 1 -name "*.xcworkspace" -print -quit)
    
    if [ -n "$WORKSPACE_FILE" ]; then
        PROJECT_NAME=$(basename "$WORKSPACE_FILE" .xcworkspace)
        HAS_XCODE_PROJECT=true
        print_success "发现工作区文件: $WORKSPACE_FILE"
        return 0
    fi
    
    # 查找 .xcodeproj 文件
    PROJECT_FILE=$(find . -maxdepth 1 -name "*.xcodeproj" -print -quit)
    
    if [ -n "$PROJECT_FILE" ]; then
        PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)
        HAS_XCODE_PROJECT=true
        print_success "发现项目文件: $PROJECT_FILE"
        return 0
    fi
    
    print_warning "未找到Xcode项目文件"
    return 1
}

# 获取项目Scheme
get_project_scheme() {
    if [ "$HAS_XCODE_PROJECT" = false ]; then
        return 1
    fi
    
    print_progress "获取项目Scheme..."
    
    # 优先查找共享的Scheme
    local shared_schemes_dir=""
    if [ -n "$WORKSPACE_FILE" ]; then
        shared_schemes_dir="./${PROJECT_NAME}.xcodeproj/xcshareddata/xcschemes"
        if [ ! -d "$shared_schemes_dir" ]; then
            shared_schemes_dir="$(dirname "$WORKSPACE_FILE")/xcshareddata/xcschemes"
        fi
    else
        shared_schemes_dir="$(dirname "$PROJECT_FILE")/xcshareddata/xcschemes"
    fi
    
    if [ -d "$shared_schemes_dir" ]; then
        local shared_schemes=$(find "$shared_schemes_dir" -name "*.xcscheme" -exec basename {} \; | sed 's/\.xcscheme$//')
        if [ -n "$shared_schemes" ]; then
            SCHEME=$(select_preferred_scheme "$shared_schemes")
            print_success "使用共享Scheme: $SCHEME"
            return 0
        fi
    fi
    
    # 通过xcodebuild获取Scheme
    local schemes_json=""
    if [ -n "$WORKSPACE_FILE" ]; then
        schemes_json=$(xcodebuild -list -workspace "$WORKSPACE_FILE" -json 2>/dev/null)
    else
        schemes_json=$(xcodebuild -list -project "$PROJECT_FILE" -json 2>/dev/null)
    fi
    
    if [ $? -eq 0 ] && [ -n "$schemes_json" ]; then
        local schemes=$(echo "$schemes_json" | /usr/bin/python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'workspace' in data:
        schemes = data['workspace'].get('schemes', [])
    else:
        schemes = data.get('project', {}).get('schemes', [])
    print('\n'.join(schemes) if schemes else '')
except Exception:
    print('')
" 2>/dev/null)
        
        if [ -n "$schemes" ]; then
            SCHEME=$(select_preferred_scheme "$schemes")
            print_success "使用Scheme: $SCHEME"
            return 0
        fi
    fi
    
    # 回退到项目名
    SCHEME="$PROJECT_NAME"
    print_warning "无法获取Scheme，使用项目名: $SCHEME"
    return 1
}

# 选择首选的Scheme
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

# =============================================================================
# Xcode清理模块
# =============================================================================

# 清理Xcode构建缓存
clean_xcode_build_cache() {
    if [ "$HAS_XCODE_PROJECT" = false ]; then
        print_warning "未找到Xcode项目，跳过构建缓存清理"
        return 0
    fi
    
    print_progress "清理Xcode构建缓存..."
    close_xcode_if_running
    
    # 清理构建目录
    safe_execute "rm -rf ./build" "删除build目录" true
    
    # 清理项目特定的DerivedData
    clean_project_derived_data
    
    # 执行xcodebuild clean
    local clean_cmd=""
    if [ -n "$WORKSPACE_FILE" ]; then
        clean_cmd="xcodebuild clean -workspace '$WORKSPACE_FILE' -scheme '$SCHEME'"
    else
        clean_cmd="xcodebuild clean -project '$PROJECT_FILE' -scheme '$SCHEME'"
    fi
    
    safe_execute "$clean_cmd" "执行xcodebuild clean"
    
    print_success "Xcode构建缓存清理完成"
}

# 清理项目特定的DerivedData
clean_project_derived_data() {
    local derived_data_dir="$HOME/Library/Developer/Xcode/DerivedData"
    
    if [ ! -d "$derived_data_dir" ]; then
        print_warning "DerivedData目录不存在"
        return 0
    fi
    
    print_progress "清理项目特定的DerivedData..."
    
    # 查找项目相关的DerivedData目录
    local project_dirs=$(find "$derived_data_dir" -maxdepth 1 -type d -name "${PROJECT_NAME}-*" 2>/dev/null)
    
    if [ -z "$project_dirs" ]; then
        print_info "未找到项目相关的DerivedData目录"
        return 0
    fi
    
    # 计算总大小
    local total_size=0
    local dir_count=0
    while IFS= read -r dir; do
        if [ -d "$dir" ]; then
            local size=$(du -sk "$dir" 2>/dev/null | cut -f1)
            total_size=$((total_size + size))
            dir_count=$((dir_count + 1))
        fi
    done <<< "$project_dirs"
    
    # 显示将要删除的内容
    local size_mb=$((total_size / 1024))
    print_info "找到 $dir_count 个相关目录，总大小: ${size_mb}MB"
    
    # 删除项目相关的DerivedData
    while IFS= read -r dir; do
        if [ -d "$dir" ]; then
            safe_execute "rm -rf '$dir'" "删除 $(basename "$dir")" true
        fi
    done <<< "$project_dirs"
    
    print_success "项目DerivedData清理完成"
}

# =============================================================================
# CocoaPods管理模块
# =============================================================================

# 清理CocoaPods
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

# 安装CocoaPods依赖
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

# =============================================================================
# Bundler管理模块
# =============================================================================

# 清理Bundler
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

# 安装Bundler依赖
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

# =============================================================================
# 交互式界面模块
# =============================================================================

# 显示主菜单
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
    # 设备与模拟器管理已移除
    echo
    print_message "$RED" "  0) 退出"
    echo
    echo -n "请输入选项 (0-9): "
}

# 处理用户选择
handle_user_choice() {
    local choice=$1
    detect_xcode_project && get_project_scheme
    case $choice in
        1)
            print_success "选择: 清理 Xcode 缓存"
            clean_xcode_build_cache
            ;;
        2)
            print_success "选择: 清理 Pods 目录"
            clean_cocoapods
            ;;
        3)
            print_success "选择: 清理 Pods 目录 + 重新安装"
            clean_cocoapods
            install_cocoapods
            ;;
        4)
            print_success "选择: 仅重新安装 Pods 依赖"
            install_cocoapods
            ;;
        5)
            print_success "选择: 清理 Bundler 缓存"
            clean_bundler
            ;;
        6)
            print_success "选择: 清理 Bundler 缓存 + 重新安装"
            clean_bundler
            install_bundler
            ;;
        7)
            print_success "选择: 仅重新安装 Bundler 依赖"
            install_bundler
            ;;
        8)
            print_success "选择: 完整清理 (Xcode + Pods + Bundler)"
            clean_xcode_build_cache
            clean_cocoapods
            clean_bundler
            ;;
        9)
            print_success "选择: 完整清理 + 重新安装所有依赖"
            clean_xcode_build_cache
            clean_cocoapods
            clean_bundler
            install_bundler
            install_cocoapods
            ;;
        0)
            print_info "退出程序"
            exit 0
            ;;
        *)
            print_error_and_exit "无效选项，请重新选择"
            ;;
    esac
    return 0
}

:

# 运行交互模式
run_interactive_mode() {
    while true; do
        show_main_menu
        read -r choice
        
        if handle_user_choice "$choice"; then
            echo
            echo -n "按 Enter 键继续... "
            read -r
        fi
    done
}

# =============================================================================
# 主执行逻辑
# =============================================================================

# 主函数
main() {
    parse_global_flags "$@"

    # 交互子命令：优先设置交互标志以便工作目录读取逻辑使用
    if [ "$SUBCOMMAND" = "interactive" ]; then
        INTERACTIVE_MODE=true
        init_working_directory "$WORKING_DIR"
        run_interactive_mode
        return
    fi

    # 非交互：若未提供 workdir 则默认当前目录
    INTERACTIVE_MODE=false
    init_working_directory "$WORKING_DIR"

    # 子命令分发（单一职责）
    case "$SUBCOMMAND" in
        xcode-clean) cmd_xcode_clean ;;
        pods-clean) cmd_pods_clean ;;
        pods-install) cmd_pods_install ;;
        pods-reinstall) cmd_pods_reinstall ;;
        bundler-clean) cmd_bundler_clean ;;
        bundler-install) cmd_bundler_install ;;
        bundler-reinstall) cmd_bundler_reinstall ;;
        clean-all) cmd_clean_all ;;
        clean-and-reinstall) cmd_clean_and_reinstall ;;
        # 设备与模拟器相关子命令已移除
        "" )
            # 未提供子命令则进入交互
            INTERACTIVE_MODE=true
            init_working_directory "$WORKING_DIR"
            run_interactive_mode ;;
        *)
            print_warning "未知子命令: $SUBCOMMAND"
            print_usage
            exit 1 ;;
    esac
}

# 执行主函数
main "$@"
