#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# 默认设置
CLEAN_PODS=false
REINSTALL_PODS=false
CLEAN_BUNDLE=false
REINSTALL_BUNDLE=false
INSTALL_ONLY_PODS=false
INSTALL_ONLY_BUNDLE=false
INTERACTIVE_MODE=false

# 显示帮助信息
show_help() {
    echo -e "${BLUE}用法:${NC} $0 [选项]"
    echo -e "清理Xcode项目缓存和依赖管理器相关文件"
    echo
    echo -e "${YELLOW}选项:${NC}"
    echo -e "  -h, --help       显示此帮助信息"
    echo -e "  -p, --pods       清理Pods目录 (CocoaPods)"
    echo -e "  -r, --reinstall  清理后重新安装依赖 (CocoaPods或Bundler)"
    echo -e "  -b, --bundle     清理Bundler缓存和vendor/bundle目录"
    echo -e "  -i, --install    仅安装Pods依赖 (不清理)"
    echo -e "  -I, --install-bundle 仅安装Bundler依赖 (不清理)"
    echo
    echo -e "${YELLOW}示例:${NC}"
    echo -e "  $0               进入交互模式"
    echo -e "  $0 -p            清理Xcode缓存和Pods目录"
    echo -e "  $0 -p -r         清理Xcode缓存和Pods目录，并重新安装Pods"
    echo -e "  $0 -b            清理Xcode缓存和Bundler缓存"
    echo -e "  $0 -b -r         清理Xcode缓存和Bundler缓存，并重新安装依赖"
    echo -e "  $0 -p -b         同时清理CocoaPods和Bundler缓存"
    echo -e "  $0 -i            仅安装Pods依赖"
    echo -e "  $0 -I            仅安装Bundler依赖"
}

# 显示交互式菜单
show_interactive_menu() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🧹 项目清理工具                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}请选择要执行的操作:${NC}"
    echo
    echo -e "${GREEN}📱 Xcode 相关操作:${NC}"
    echo -e "  ${BLUE}1)${NC} 清理 Xcode 缓存 (DerivedData, Build目录)"
    echo
    echo -e "${GREEN}🔗 CocoaPods 相关操作:${NC}"
    echo -e "  ${BLUE}2)${NC} 清理 Pods 目录"
    echo -e "  ${BLUE}3)${NC} 清理 Pods 目录 + 重新安装"
    echo -e "  ${BLUE}4)${NC} 仅重新安装 Pods 依赖"
    echo
    echo -e "${GREEN}💎 Bundler 相关操作:${NC}"
    echo -e "  ${BLUE}5)${NC} 清理 Bundler 缓存"
    echo -e "  ${BLUE}6)${NC} 清理 Bundler 缓存 + 重新安装"
    echo -e "  ${BLUE}7)${NC} 仅重新安装 Bundler 依赖"
    echo
    echo -e "${GREEN}🔄 组合操作:${NC}"
    echo -e "  ${BLUE}8)${NC} 完整清理 (Xcode + Pods + Bundler)"
    echo -e "  ${BLUE}9)${NC} 完整清理 + 重新安装所有依赖"
    echo
    echo -e "${GREEN}📱 设备管理:${NC}"
    echo -e "  ${BLUE}10)${NC} Xcode 设备和模拟器管理"
    echo
    echo -e "${RED}0)${NC} 退出"
    echo
    echo -ne "${PURPLE}请输入选项 (0-10): ${NC}"
}

# 重置所有选项
reset_options() {
    CLEAN_PODS=false
    REINSTALL_PODS=false
    CLEAN_BUNDLE=false
    REINSTALL_BUNDLE=false
    INSTALL_ONLY_PODS=false
    INSTALL_ONLY_BUNDLE=false
}

# 处理交互式选择
handle_interactive_choice() {
    local choice=$1
    reset_options
    
    case $choice in
        1)
            echo -e "\n${GREEN}✅ 选择: 清理 Xcode 缓存${NC}"
            # 只清理Xcode，不设置其他选项
            ;;
        2)
            echo -e "\n${GREEN}✅ 选择: 清理 Pods 目录${NC}"
            CLEAN_PODS=true
            ;;
        3)
            echo -e "\n${GREEN}✅ 选择: 清理 Pods 目录 + 重新安装${NC}"
            CLEAN_PODS=true
            REINSTALL_PODS=true
            ;;
        4)
            echo -e "\n${GREEN}✅ 选择: 仅重新安装 Pods 依赖${NC}"
            REINSTALL_PODS=true
            ;;
        5)
            echo -e "\n${GREEN}✅ 选择: 清理 Bundler 缓存${NC}"
            CLEAN_BUNDLE=true
            ;;
        6)
            echo -e "\n${GREEN}✅ 选择: 清理 Bundler 缓存 + 重新安装${NC}"
            CLEAN_BUNDLE=true
            REINSTALL_BUNDLE=true
            ;;
        7)
            echo -e "\n${GREEN}✅ 选择: 仅重新安装 Bundler 依赖${NC}"
            REINSTALL_BUNDLE=true
            ;;
        8)
            echo -e "\n${GREEN}✅ 选择: 完整清理 (Xcode + Pods + Bundler)${NC}"
            CLEAN_PODS=true
            CLEAN_BUNDLE=true
            ;;
        9)
            echo -e "\n${GREEN}✅ 选择: 完整清理 + 重新安装所有依赖${NC}"
            CLEAN_PODS=true
            CLEAN_BUNDLE=true
            REINSTALL_PODS=true
            REINSTALL_BUNDLE=true
            ;;
        10)
            echo -e "\n${GREEN}✅ 选择: Xcode 设备和模拟器管理${NC}"
            show_device_management_menu
            return 0
            ;;
        0)
            echo -e "\n${YELLOW}👋 退出程序${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}❌ 无效选项，请重新选择${NC}"
            return 1
            ;;
    esac
    return 0
}

# 显示设备管理菜单
show_device_management_menu() {
    while true; do
        clear
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                📱 Xcode 设备和模拟器管理                    ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        echo -e "${YELLOW}请选择要执行的操作:${NC}"
        echo
        echo -e "${GREEN}📱 模拟器管理:${NC}"
        echo -e "  ${BLUE}1)${NC} 查看所有模拟器和占用空间"
        echo -e "  ${BLUE}2)${NC} 删除不可用的模拟器"
        echo -e "  ${BLUE}3)${NC} 选择性删除模拟器"
        echo -e "  ${BLUE}4)${NC} 清理所有模拟器数据"
        echo
        echo -e "${GREEN}📲 真机设备管理:${NC}"
        echo -e "  ${BLUE}5)${NC} 查看连接的设备信息"
        echo -e "  ${BLUE}6)${NC} 清理设备支持文件"
        echo
        echo -e "${GREEN}🗂️ 其他清理:${NC}"
        echo -e "  ${BLUE}7)${NC} 清理Xcode Archives"
        echo -e "  ${BLUE}8)${NC} 清理iOS DeviceSupport"
        echo
        echo -e "${RED}0)${NC} 返回主菜单"
        echo
        echo -ne "${PURPLE}请输入选项 (0-8): ${NC}"
        read -r device_choice
        
        case $device_choice in
            1)
                show_simulators_info
                ;;
            2)
                delete_unavailable_simulators
                ;;
            3)
                interactive_delete_simulators
                ;;
            4)
                clean_all_simulator_data
                ;;
            5)
                show_connected_devices
                ;;
            6)
                clean_device_support_files
                ;;
            7)
                clean_xcode_archives
                ;;
            8)
                clean_ios_device_support
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "\n${RED}❌ 无效选项，请重新选择${NC}"
                echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
                read -r
                ;;
        esac
    done
}

# 查看模拟器信息和占用空间
show_simulators_info() {
    echo -e "\n${BLUE}🔍 正在扫描模拟器信息...${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    # 获取所有模拟器列表
    xcrun simctl list devices --json > /tmp/simulators.json 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ 无法获取模拟器信息${NC}"
        echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
        read -r
        return
    fi
    
    echo -e "${GREEN}📱 模拟器列表:${NC}"
    echo
    
    # 计算总占用空间
    local total_size=0
    local simulator_count=0
    
    # 遍历模拟器目录
    local simulator_dir="$HOME/Library/Developer/CoreSimulator/Devices"
    if [ -d "$simulator_dir" ]; then
        for device_dir in "$simulator_dir"/*; do
            if [ -d "$device_dir" ]; then
                local device_id=$(basename "$device_dir")
                local device_size=$(du -sh "$device_dir" 2>/dev/null | cut -f1)
                
                # 获取设备名称和状态
                local device_info=$(xcrun simctl list devices | grep "$device_id" | head -1)
                if [ -n "$device_info" ]; then
                    # 更精确的设备名称解析
                    local device_name=$(echo "$device_info" | sed -E 's/^[[:space:]]*([^(]+).*$/\1/' | sed 's/[[:space:]]*$//')
                    local device_status="未知"
                    
                    # 解析设备状态
                    if echo "$device_info" | grep -q "(Shutdown)"; then
                        device_status="Shutdown"
                    elif echo "$device_info" | grep -q "(Booted)"; then
                        device_status="Booted"
                    elif echo "$device_info" | grep -q "unavailable"; then
                        device_status="unavailable"
                        # 对于不可用设备，尝试从plist获取更好的名称
                        local plist_file="$device_dir/device.plist"
                        if [ -f "$plist_file" ]; then
                            local plist_name=$(plutil -p "$plist_file" 2>/dev/null | grep '"name"' | sed 's/.*"name" => "\(.*\)"/\1/')
                            if [ -n "$plist_name" ]; then
                                device_name="$plist_name"
                            fi
                        fi
                    fi
                    
                    # 如果设备名称为空或只包含ID，使用默认名称
                    if [ -z "$device_name" ] || [[ "$device_name" =~ ^[A-F0-9-]{36}$ ]]; then
                        device_name="未知设备"
                    fi
                    
                    # 根据状态显示不同颜色
                    if [ "$device_status" = "Shutdown" ]; then
                        echo -e "  ${YELLOW}📱${NC} $device_name ${GRAY}($device_status)${NC} - ${BLUE}$device_size${NC}"
                    elif [ "$device_status" = "Booted" ]; then
                        echo -e "  ${GREEN}📱${NC} $device_name ${GREEN}($device_status)${NC} - ${BLUE}$device_size${NC}"
                    elif [ "$device_status" = "unavailable" ]; then
                        echo -e "  ${RED}📱${NC} $device_name ${RED}($device_status)${NC} - ${BLUE}$device_size${NC}"
                    else
                        echo -e "  ${CYAN}📱${NC} $device_name ${CYAN}($device_status)${NC} - ${BLUE}$device_size${NC}"
                    fi
                    
                    simulator_count=$((simulator_count + 1))
                fi
            fi
        done
        
        # 计算总大小
        local total_size_mb=$(du -sm "$simulator_dir" 2>/dev/null | cut -f1)
        if [ -n "$total_size_mb" ]; then
            if [ $total_size_mb -gt 1024 ]; then
                local total_size_gb=$((total_size_mb / 1024))
                echo -e "\n${CYAN}📊 统计信息:${NC}"
                echo -e "  模拟器数量: ${YELLOW}$simulator_count${NC}"
                echo -e "  总占用空间: ${RED}${total_size_gb}GB${NC}"
            else
                echo -e "\n${CYAN}📊 统计信息:${NC}"
                echo -e "  模拟器数量: ${YELLOW}$simulator_count${NC}"
                echo -e "  总占用空间: ${RED}${total_size_mb}MB${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️ 未找到模拟器目录${NC}"
    fi
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 删除不可用的模拟器
delete_unavailable_simulators() {
    echo -e "\n${BLUE}🔍 正在查找不可用的模拟器...${NC}"
    
    # 获取不可用的模拟器
    local unavailable_simulators=$(xcrun simctl list devices | grep "unavailable" | wc -l | tr -d ' ')
    
    if [ "$unavailable_simulators" -eq 0 ]; then
        echo -e "${GREEN}✅ 没有发现不可用的模拟器${NC}"
    else
        echo -e "${YELLOW}发现 $unavailable_simulators 个不可用的模拟器${NC}"
        echo -e "\n${RED}⚠️ 确定要删除所有不可用的模拟器吗？ (y/N): ${NC}"
        read -r confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "\n${BLUE}🗑️ 正在删除不可用的模拟器...${NC}"
            xcrun simctl delete unavailable
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 成功删除不可用的模拟器${NC}"
            else
                echo -e "${RED}❌ 删除失败${NC}"
            fi
        else
            echo -e "${YELLOW}取消删除操作${NC}"
        fi
    fi
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 交互式删除模拟器
interactive_delete_simulators() {
    echo -e "\n${BLUE}🔍 正在获取模拟器列表...${NC}"
    
    # 获取所有关闭的模拟器
    local simulators=$(xcrun simctl list devices | grep "Shutdown" | grep -v "unavailable")
    
    if [ -z "$simulators" ]; then
        echo -e "${YELLOW}⚠️ 没有找到可删除的模拟器（只能删除已关闭的模拟器）${NC}"
        echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
        read -r
        return
    fi
    
    echo -e "${GREEN}📱 可删除的模拟器列表:${NC}"
    echo
    
    # 创建临时数组存储模拟器信息
    local -a simulator_ids
    local -a simulator_names
    local index=1
    
    while IFS= read -r line; do
        local device_id=$(echo "$line" | grep -o '[A-F0-9-]\{36\}')
        local device_name=$(echo "$line" | sed 's/.*) //g' | sed 's/ (.*//g')
        
        simulator_ids[$index]="$device_id"
        simulator_names[$index]="$device_name"
        
        echo -e "  ${BLUE}$index)${NC} $device_name"
        index=$((index + 1))
    done <<< "$simulators"
    
    echo -e "\n  ${RED}0)${NC} 返回上级菜单"
    echo -e "\n${PURPLE}请选择要删除的模拟器编号 (多个编号用空格分隔): ${NC}"
    read -r selection
    
    if [ "$selection" = "0" ] || [ -z "$selection" ]; then
        return
    fi
    
    # 处理选择的模拟器
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -gt 0 ] && [ "$num" -lt "$index" ]; then
            local selected_id="${simulator_ids[$num]}"
            local selected_name="${simulator_names[$num]}"
            
            echo -e "\n${RED}⚠️ 确定要删除模拟器 '$selected_name' 吗？ (y/N): ${NC}"
            read -r confirm
            
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}🗑️ 正在删除 '$selected_name'...${NC}"
                xcrun simctl delete "$selected_id"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ 成功删除 '$selected_name'${NC}"
                else
                    echo -e "${RED}❌ 删除 '$selected_name' 失败${NC}"
                fi
            else
                echo -e "${YELLOW}跳过删除 '$selected_name'${NC}"
            fi
        fi
    done
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 清理所有模拟器数据
clean_all_simulator_data() {
    echo -e "\n${RED}⚠️ 这将清理所有模拟器的应用数据和缓存${NC}"
    echo -e "${RED}⚠️ 确定要继续吗？ (y/N): ${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n${BLUE}🧹 正在清理模拟器数据...${NC}"
        
        # 关闭所有模拟器
        xcrun simctl shutdown all
        
        # 清理模拟器数据
        xcrun simctl erase all
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ 成功清理所有模拟器数据${NC}"
        else
            echo -e "${RED}❌ 清理失败${NC}"
        fi
    else
        echo -e "${YELLOW}取消清理操作${NC}"
    fi
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 查看连接的设备信息
show_connected_devices() {
    echo -e "\n${BLUE}🔍 正在查找连接的设备...${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    
    # 获取连接的设备
    local devices=$(xcrun xctrace list devices 2>/dev/null | grep -v "Simulator" | grep -v "^=" | grep -v "^My Mac")
    
    if [ -z "$devices" ]; then
        echo -e "${YELLOW}⚠️ 没有发现连接的设备${NC}"
    else
        echo -e "${GREEN}📲 连接的设备:${NC}"
        echo
        echo "$devices" | while IFS= read -r line; do
            if [ -n "$line" ]; then
                echo -e "  ${GREEN}📱${NC} $line"
            fi
        done
    fi
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 清理设备支持文件
clean_device_support_files() {
    local device_support_dir="$HOME/Library/Developer/Xcode/iOS DeviceSupport"
    
    if [ ! -d "$device_support_dir" ]; then
        echo -e "\n${YELLOW}⚠️ 未找到设备支持文件目录${NC}"
        echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
        read -r
        return
    fi
    
    echo -e "\n${BLUE}🔍 正在扫描设备支持文件...${NC}"
    
    local total_size=$(du -sh "$device_support_dir" 2>/dev/null | cut -f1)
    local file_count=$(find "$device_support_dir" -type d -maxdepth 1 | wc -l | tr -d ' ')
    file_count=$((file_count - 1))  # 减去目录本身
    
    echo -e "${CYAN}📊 设备支持文件信息:${NC}"
    echo -e "  文件数量: ${YELLOW}$file_count${NC}"
    echo -e "  占用空间: ${RED}$total_size${NC}"
    echo
    
    if [ $file_count -gt 0 ]; then
        echo -e "${RED}⚠️ 确定要删除所有设备支持文件吗？${NC}"
        echo -e "${YELLOW}注意: 删除后首次连接设备时需要重新下载支持文件${NC}"
        echo -e "${RED}确认删除? (y/N): ${NC}"
        read -r confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "\n${BLUE}🗑️ 正在删除设备支持文件...${NC}"
            rm -rf "$device_support_dir"/*
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 成功删除设备支持文件${NC}"
            else
                echo -e "${RED}❌ 删除失败${NC}"
            fi
        else
            echo -e "${YELLOW}取消删除操作${NC}"
        fi
    fi
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 清理Xcode Archives
clean_xcode_archives() {
    local archives_dir="$HOME/Library/Developer/Xcode/Archives"
    
    if [ ! -d "$archives_dir" ]; then
        echo -e "\n${YELLOW}⚠️ 未找到Archives目录${NC}"
        echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
        read -r
        return
    fi
    
    echo -e "\n${BLUE}🔍 正在扫描Archives...${NC}"
    
    local total_size=$(du -sh "$archives_dir" 2>/dev/null | cut -f1)
    local archive_count=$(find "$archives_dir" -name "*.xcarchive" | wc -l | tr -d ' ')
    
    echo -e "${CYAN}📊 Archives信息:${NC}"
    echo -e "  Archive数量: ${YELLOW}$archive_count${NC}"
    echo -e "  占用空间: ${RED}$total_size${NC}"
    echo
    
    if [ $archive_count -gt 0 ]; then
        echo -e "${RED}⚠️ 确定要删除所有Archives吗？${NC}"
        echo -e "${YELLOW}注意: 删除后将无法重新提交到App Store${NC}"
        echo -e "${RED}确认删除? (y/N): ${NC}"
        read -r confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "\n${BLUE}🗑️ 正在删除Archives...${NC}"
            rm -rf "$archives_dir"/*
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ 成功删除Archives${NC}"
            else
                echo -e "${RED}❌ 删除失败${NC}"
            fi
        else
            echo -e "${YELLOW}取消删除操作${NC}"
        fi
    fi
    
    echo -e "\n${YELLOW}按 Enter 键继续...${NC}"
    read -r
}

# 清理iOS DeviceSupport
clean_ios_device_support() {
    clean_device_support_files
}

# 交互式主循环
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

# 检查是否有命令行参数
if [[ "$#" -eq 0 ]]; then
    INTERACTIVE_MODE=true
    run_interactive_mode
else
    # 解析命令行参数
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

# 开始执行清理任务
echo -e "${GREEN}🧹 开始执行清理任务...${NC}"

# 1. 自动检测 .xcworkspace 文件
WORKSPACE_FILE=$(find . -maxdepth 1 -name "*.xcworkspace" -print -quit)

if [ -z "$WORKSPACE_FILE" ]; then
    # 尝试查找 .xcodeproj 文件
    PROJECT_FILE=$(find . -maxdepth 1 -name "*.xcodeproj" -print -quit)
    
    if [ -z "$PROJECT_FILE" ]; then
        echo -e "${YELLOW}⚠️ 未找到 .xcworkspace 或 .xcodeproj 文件${NC}"
        echo -e "${YELLOW}📁 当前目录内容：${NC}"
        ls -la
        
        # 如果没有Xcode项目文件，但有Gemfile，则可能是纯Ruby项目
        if [ -f "Gemfile" ] && [ "$CLEAN_BUNDLE" = false ] && [ "$CLEAN_PODS" = false ]; then
            echo -e "${YELLOW}⚠️ 检测到Gemfile但未指定-b选项，建议使用 -b 选项清理Bundler缓存${NC}"
        fi
        
        # 如果没有指定清理选项、安装选项或重新安装选项，则退出
        if [ "$CLEAN_BUNDLE" = false ] && [ "$CLEAN_PODS" = false ] && [ "$INSTALL_ONLY_PODS" = false ] && [ "$INSTALL_ONLY_BUNDLE" = false ] && [ "$REINSTALL_PODS" = false ] && [ "$REINSTALL_BUNDLE" = false ]; then
            echo -e "${RED}❌ 未找到可清理的Xcode项目，退出脚本${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️ 未找到 .xcworkspace 文件，将使用 .xcodeproj 文件${NC}"
        PROJECT_NAME=$(basename "$PROJECT_FILE" .xcodeproj)
        USE_PROJECT=true
        HAS_XCODE_PROJECT=true
    fi
else
    PROJECT_NAME=$(basename "$WORKSPACE_FILE" .xcworkspace)
    USE_PROJECT=false
    HAS_XCODE_PROJECT=true
fi

# 2. 如果有Xcode项目，获取Scheme并清理
if [ "$HAS_XCODE_PROJECT" = true ]; then
    # 获取第一个 Scheme
    if [ "$USE_PROJECT" = true ]; then
        SCHEME=$(xcodebuild -list -project "$PROJECT_FILE" | awk '/Schemes:/ { getline; print $1; exit }')
        if [ -z "$SCHEME" ]; then
            SCHEME="$PROJECT_NAME" # 默认使用项目名
        fi
        echo -e "${GREEN}✅ 项目文件: ${NC}$PROJECT_FILE"
    else
        SCHEME=$(xcodebuild -list -workspace "$WORKSPACE_FILE" | awk '/Schemes:/ { getline; print $1; exit }')
        if [ -z "$SCHEME" ]; then
            SCHEME="$PROJECT_NAME" # 默认使用项目名
        fi
        echo -e "${GREEN}✅ 工作区文件: ${NC}$WORKSPACE_FILE"
    fi

    echo -e "${GREEN}📛 Scheme: ${NC}$SCHEME"

    # 3. 清理构建目录
    echo -e "${BLUE}🔄 清理Xcode构建缓存...${NC}"
    if [ "$USE_PROJECT" = true ]; then
        xcodebuild clean -project "$PROJECT_FILE" -scheme "$SCHEME"
    else
        xcodebuild clean -workspace "$WORKSPACE_FILE" -scheme "$SCHEME"
    fi

    # 4. 删除 build 目录
    echo -e "${BLUE}🔄 删除build目录...${NC}"
    rm -rf ./build 2>/dev/null || true

    # 5. 清理 DerivedData
    echo -e "${BLUE}🔄 清理DerivedData...${NC}"
    find ~/Library/Developer/Xcode/DerivedData -name "${PROJECT_NAME}-*" -type d -exec rm -rf {} + 2>/dev/null || true
fi

# 6. 清理 Pods 目录（如果指定）
if [ "$CLEAN_PODS" = true ]; then
    echo -e "${BLUE}🔄 清理Pods目录...${NC}"
    
    # 检查Podfile是否存在
    if [ ! -f "Podfile" ]; then
        echo -e "${YELLOW}⚠️ 未找到Podfile，跳过清理Pods${NC}"
    else
        # 删除Pods目录和Podfile.lock
        rm -rf Pods Podfile.lock
        echo -e "${GREEN}✅ 已删除Pods目录和Podfile.lock${NC}"
        
        # 清理CocoaPods缓存（可选）
        echo -e "${BLUE}🔄 清理CocoaPods缓存...${NC}"
        if command -v bundle >/dev/null 2>&1; then
            bundle exec pod cache clean --all 2>/dev/null || pod cache clean --all 2>/dev/null || echo -e "${YELLOW}⚠️ 无法清理CocoaPods缓存${NC}"
        else
            pod cache clean --all 2>/dev/null || echo -e "${YELLOW}⚠️ 无法清理CocoaPods缓存${NC}"
        fi
        
        # 重新安装Pods（如果指定）
        PODS_REINSTALL_SUCCESS=false
        if [ "$REINSTALL_PODS" = true ]; then
            echo -e "${BLUE}🔄 重新安装Pods...${NC}"
            if command -v bundle >/dev/null 2>&1; then
                # 如果之前清理了 .bundle 目录，需要重新配置
                if [ "$CLEAN_BUNDLE" = true ]; then
                    echo -e "${BLUE}🔄 重新配置Bundler路径...${NC}"
                    bundle config set --local path 'vendor/bundle'
                fi
                
                # 先执行 bundle install，然后再执行 pod install
                echo -e "${BLUE}🔄 执行 bundle install...${NC}"
                bundle install
                if [ $? -eq 0 ]; then
                    echo -e "${BLUE}🔄 执行 bundle exec pod install...${NC}"
                    bundle exec pod install --clean-install
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}✅ Pods重新安装成功${NC}"
                        PODS_REINSTALL_SUCCESS=true
                    else
                        echo -e "${RED}❌ Pods重新安装失败${NC}"
                        echo -e "${YELLOW}💡 提示: 请检查Podfile语法或网络连接${NC}"
                    fi
                else
                    echo -e "${RED}❌ bundle install 失败，无法继续安装Pods${NC}"
                    echo -e "${YELLOW}💡 提示: 请检查Gemfile语法或网络连接${NC}"
                fi
            else
                pod install --clean-install
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Pods重新安装成功${NC}"
                    PODS_REINSTALL_SUCCESS=true
                else
                    echo -e "${RED}❌ Pods重新安装失败${NC}"
                    echo -e "${YELLOW}💡 提示: 请检查Podfile语法或网络连接${NC}"
                fi
            fi
        fi
    fi
fi

# 7. 清理 Bundler 缓存（如果指定）
if [ "$CLEAN_BUNDLE" = true ]; then
    echo -e "${BLUE}🔄 清理Bundler缓存...${NC}"
    
    # 检查Gemfile是否存在
    if [ ! -f "Gemfile" ]; then
        echo -e "${YELLOW}⚠️ 未找到Gemfile，跳过清理Bundler${NC}"
    else
        # 删除vendor/bundle目录
        if [ -d "vendor/bundle" ]; then
            echo -e "${BLUE}🔄 删除vendor/bundle目录...${NC}"
            rm -rf vendor/bundle
            echo -e "${GREEN}✅ 已删除vendor/bundle目录${NC}"
        fi
        
        # 删除.bundle目录
        if [ -d ".bundle" ]; then
            echo -e "${BLUE}🔄 删除.bundle目录...${NC}"
            rm -rf .bundle
            echo -e "${GREEN}✅ 已删除.bundle目录${NC}"
        fi
        
        # 清理Bundler缓存
        echo -e "${BLUE}🔄 清理Bundler缓存...${NC}"
        if command -v bundle >/dev/null 2>&1; then
            bundle clean --force 2>/dev/null || echo -e "${YELLOW}⚠️ 无法清理Bundler缓存${NC}"
        else
            echo -e "${YELLOW}⚠️ 未安装Bundler，跳过缓存清理${NC}"
        fi
        
        # 重新安装Bundler依赖（如果指定）
        BUNDLE_REINSTALL_SUCCESS=false
        if [ "$REINSTALL_BUNDLE" = true ]; then
            echo -e "${BLUE}🔄 重新安装Bundler依赖...${NC}"
            if command -v bundle >/dev/null 2>&1; then
                # 重新配置 bundle 路径（因为 .bundle 目录已被删除）
                echo -e "${BLUE}🔄 重新配置Bundler路径...${NC}"
                bundle config set --local path 'vendor/bundle'
                
                bundle install
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Bundler依赖重新安装成功${NC}"
                    BUNDLE_REINSTALL_SUCCESS=true
                else
                    echo -e "${RED}❌ Bundler依赖重新安装失败${NC}"
                    echo -e "${YELLOW}💡 提示: 请检查Gemfile语法或网络连接${NC}"
                fi
            else
                echo -e "${RED}❌ 未安装Bundler，无法安装依赖${NC}"
                echo -e "${YELLOW}💡 提示: 请先安装Bundler: gem install bundler${NC}"
            fi
        fi
    fi
fi

# 8. 仅安装 Pods（如果指定）
PODS_INSTALL_ONLY_SUCCESS=false
if [ "$INSTALL_ONLY_PODS" = true ]; then
    echo -e "${BLUE}🔄 安装Pods依赖...${NC}"
    
    # 检查Podfile是否存在
    if [ ! -f "Podfile" ]; then
        echo -e "${RED}❌ 未找到Podfile，无法安装Pods${NC}"
    else
        if command -v bundle >/dev/null 2>&1; then
            # 确保 Bundler 配置正确（检查是否存在 .bundle/config）
            if [ ! -f ".bundle/config" ]; then
                echo -e "${BLUE}🔄 配置Bundler路径...${NC}"
                bundle config set --local path 'vendor/bundle'
            fi
            
            # 先执行 bundle install，然后再执行 pod install
            echo -e "${BLUE}🔄 执行 bundle install...${NC}"
            bundle install
            if [ $? -eq 0 ]; then
                echo -e "${BLUE}🔄 执行 bundle exec pod install...${NC}"
                bundle exec pod install --clean-install
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Pods安装成功${NC}"
                    PODS_INSTALL_ONLY_SUCCESS=true
                else
                    echo -e "${RED}❌ Pods安装失败${NC}"
                    echo -e "${YELLOW}💡 提示: 请检查Podfile语法或网络连接${NC}"
                fi
            else
                echo -e "${RED}❌ bundle install 失败，无法继续安装Pods${NC}"
                echo -e "${YELLOW}💡 提示: 请检查Gemfile语法或网络连接${NC}"
            fi
        else
            pod install --clean-install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Pods安装成功${NC}"
                PODS_INSTALL_ONLY_SUCCESS=true
            else
                echo -e "${RED}❌ Pods安装失败${NC}"
                echo -e "${YELLOW}💡 提示: 请检查Podfile语法或网络连接${NC}"
            fi
        fi
    fi
fi

# 9. 仅安装 Bundler 依赖（如果指定）
BUNDLE_INSTALL_ONLY_SUCCESS=false
if [ "$INSTALL_ONLY_BUNDLE" = true ]; then
    echo -e "${BLUE}🔄 安装Bundler依赖...${NC}"
    
    # 检查Gemfile是否存在
    if [ ! -f "Gemfile" ]; then
        echo -e "${RED}❌ 未找到Gemfile，无法安装Bundler依赖${NC}"
    else
        if command -v bundle >/dev/null 2>&1; then
            bundle install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Bundler依赖安装成功${NC}"
                BUNDLE_INSTALL_ONLY_SUCCESS=true
            else
                echo -e "${RED}❌ Bundler依赖安装失败${NC}"
                echo -e "${YELLOW}💡 提示: 请检查Gemfile语法或网络连接${NC}"
            fi
        else
            echo -e "${RED}❌ 未安装Bundler，无法安装依赖${NC}"
            echo -e "${YELLOW}💡 提示: 请先安装Bundler: gem install bundler${NC}"
        fi
    fi
fi

# 10. 仅重新安装 Pods（如果指定且未进行清理）
PODS_ONLY_REINSTALL_SUCCESS=false
if [ "$REINSTALL_PODS" = true ] && [ "$CLEAN_PODS" = false ]; then
    echo -e "${BLUE}🔄 重新安装Pods...${NC}"
    
    # 检查Podfile是否存在
    if [ ! -f "Podfile" ]; then
        echo -e "${RED}❌ 未找到Podfile，无法重新安装Pods${NC}"
    else
        if command -v bundle >/dev/null 2>&1; then
            # 确保 Bundler 配置正确（检查是否存在 .bundle/config）
            if [ ! -f ".bundle/config" ]; then
                echo -e "${BLUE}🔄 配置Bundler路径...${NC}"
                bundle config set --local path 'vendor/bundle'
            fi
            
            # 先执行 bundle install，然后再执行 pod install
            echo -e "${BLUE}🔄 执行 bundle install...${NC}"
            bundle install
            if [ $? -eq 0 ]; then
                echo -e "${BLUE}🔄 执行 bundle exec pod install...${NC}"
                bundle exec pod install --clean-install
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ Pods重新安装成功${NC}"
                    PODS_ONLY_REINSTALL_SUCCESS=true
                else
                    echo -e "${RED}❌ Pods重新安装失败${NC}"
                    echo -e "${YELLOW}💡 提示: 请检查Podfile语法或网络连接${NC}"
                fi
            else
                echo -e "${RED}❌ bundle install 失败，无法继续安装Pods${NC}"
                echo -e "${YELLOW}💡 提示: 请检查Gemfile语法或网络连接${NC}"
            fi
        else
            pod install --clean-install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Pods重新安装成功${NC}"
                PODS_ONLY_REINSTALL_SUCCESS=true
            else
                echo -e "${RED}❌ Pods重新安装失败${NC}"
                echo -e "${YELLOW}💡 提示: 请检查Podfile语法或网络连接${NC}"
            fi
        fi
    fi
fi

# 11. 仅重新安装 Bundler 依赖（如果指定且未进行清理）
BUNDLE_ONLY_REINSTALL_SUCCESS=false
if [ "$REINSTALL_BUNDLE" = true ] && [ "$CLEAN_BUNDLE" = false ]; then
    echo -e "${BLUE}🔄 重新安装Bundler依赖...${NC}"
    
    # 检查Gemfile是否存在
    if [ ! -f "Gemfile" ]; then
        echo -e "${RED}❌ 未找到Gemfile，无法重新安装Bundler依赖${NC}"
    else
        if command -v bundle >/dev/null 2>&1; then
            bundle install
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Bundler依赖重新安装成功${NC}"
                BUNDLE_ONLY_REINSTALL_SUCCESS=true
            else
                echo -e "${RED}❌ Bundler依赖重新安装失败${NC}"
                echo -e "${YELLOW}💡 提示: 请检查Gemfile语法或网络连接${NC}"
            fi
        else
            echo -e "${RED}❌ 未安装Bundler，无法重新安装依赖${NC}"
            echo -e "${YELLOW}💡 提示: 请先安装Bundler: gem install bundler${NC}"
        fi
    fi
fi

# 12. 关闭 Xcode
if [ "$INSTALL_ONLY_PODS" = false ] && [ "$INSTALL_ONLY_BUNDLE" = false ]; then
    echo -e "${BLUE}🔄 关闭Xcode...${NC}"
    osascript -e 'tell application "Xcode" to quit' 2>/dev/null || true
fi

echo -e "${GREEN}✅ 清理完成！${NC}"

# 显示清理状态摘要
echo -e "${BLUE}📋 清理摘要:${NC}"

if [ "$HAS_XCODE_PROJECT" = true ]; then
    echo -e "  - Xcode缓存: ${GREEN}已清理${NC}"
    echo -e "  - Build目录: ${GREEN}已清理${NC}"
    echo -e "  - DerivedData: ${GREEN}已清理${NC}"
else
    echo -e "  - Xcode缓存: ${YELLOW}未清理${NC} (未找到Xcode项目)"
fi

if [ "$CLEAN_PODS" = true ]; then
    if [ -f "Podfile" ]; then
        echo -e "  - Pods目录: ${GREEN}已清理${NC}"
        if [ "$REINSTALL_PODS" = true ]; then
            if [ "$PODS_REINSTALL_SUCCESS" = true ]; then
                echo -e "  - Pods重新安装: ${GREEN}成功${NC}"
            else
                echo -e "  - Pods重新安装: ${RED}失败${NC}"
            fi
        fi
    else
        echo -e "  - Pods目录: ${YELLOW}未清理${NC} (未找到Podfile)"
    fi
else
    echo -e "  - Pods目录: ${YELLOW}未清理${NC} (使用 -p 选项清理)"
fi

if [ "$CLEAN_BUNDLE" = true ]; then
    if [ -f "Gemfile" ]; then
        echo -e "  - Bundler缓存: ${GREEN}已清理${NC}"
        if [ "$REINSTALL_BUNDLE" = true ]; then
            if [ "$BUNDLE_REINSTALL_SUCCESS" = true ]; then
                echo -e "  - Bundler依赖重新安装: ${GREEN}成功${NC}"
            else
                echo -e "  - Bundler依赖重新安装: ${RED}失败${NC}"
            fi
        fi
    else
        echo -e "  - Bundler缓存: ${YELLOW}未清理${NC} (未找到Gemfile)"
    fi
else
    echo -e "  - Bundler缓存: ${YELLOW}未清理${NC} (使用 -b 选项清理)"
fi

if [ "$INSTALL_ONLY_PODS" = true ]; then
    if [ -f "Podfile" ]; then
        if [ "$PODS_INSTALL_ONLY_SUCCESS" = true ]; then
            echo -e "  - Pods安装: ${GREEN}成功${NC}"
        else
            echo -e "  - Pods安装: ${RED}失败${NC}"
        fi
    else
        echo -e "  - Pods安装: ${RED}失败${NC} (未找到Podfile)"
    fi
fi

if [ "$INSTALL_ONLY_BUNDLE" = true ]; then
    if [ -f "Gemfile" ]; then
        if [ "$BUNDLE_INSTALL_ONLY_SUCCESS" = true ]; then
            echo -e "  - Bundler依赖安装: ${GREEN}成功${NC}"
        else
            echo -e "  - Bundler依赖安装: ${RED}失败${NC}"
        fi
    else
        echo -e "  - Bundler依赖安装: ${RED}失败${NC} (未找到Gemfile)"
    fi
fi

if [ "$REINSTALL_PODS" = true ] && [ "$CLEAN_PODS" = false ]; then
    if [ -f "Podfile" ]; then
        if [ "$PODS_ONLY_REINSTALL_SUCCESS" = true ]; then
            echo -e "  - Pods重新安装: ${GREEN}成功${NC}"
        else
            echo -e "  - Pods重新安装: ${RED}失败${NC}"
        fi
    else
        echo -e "  - Pods重新安装: ${RED}失败${NC} (未找到Podfile)"
    fi
fi

if [ "$REINSTALL_BUNDLE" = true ] && [ "$CLEAN_BUNDLE" = false ]; then
    if [ -f "Gemfile" ]; then
        if [ "$BUNDLE_ONLY_REINSTALL_SUCCESS" = true ]; then
            echo -e "  - Bundler依赖重新安装: ${GREEN}成功${NC}"
        else
            echo -e "  - Bundler依赖重新安装: ${RED}失败${NC}"
        fi
    else
        echo -e "  - Bundler依赖重新安装: ${RED}失败${NC} (未找到Gemfile)"
    fi
fi

echo -e "\n${GREEN}✅ 任务执行完成！${NC}"
echo -e "${GREEN}提示: 重新打开Xcode并重新构建项目。${NC}"

# 如果是交互模式，询问是否继续
if [ "$INTERACTIVE_MODE" = true ]; then
    echo
    echo -e "${YELLOW}是否继续使用清理工具？${NC}"
    echo -e "  ${BLUE}1)${NC} 返回主菜单"
    echo -e "  ${BLUE}2)${NC} 打开 Xcode"
    echo -e "  ${BLUE}3)${NC} 退出程序"
    echo -ne "${PURPLE}请选择 (1-3): ${NC}"
    read -r continue_choice
    
    case $continue_choice in
        1)
            echo -e "\n${GREEN}返回主菜单...${NC}"
            sleep 1
            exec "$0"  # 重新启动脚本
            ;;
        2)
            echo -e "\n${GREEN}正在打开 Xcode...${NC}"
            open -a /Applications/Xcode.app --args -ApplePersistenceIgnoreState YES
            echo -e "${YELLOW}👋 感谢使用，再见！${NC}"
            exit 0
            ;;
        3|*)
            echo -e "\n${YELLOW}👋 感谢使用，再见！${NC}"
            exit 0
            ;;
    esac
fi