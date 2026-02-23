#!/bin/bash

# =================================================================
# 项目名称: Steam Installer for General Linux Systems
# 版本: V3.0 (Ultimate Universal Edition)
# 功能: 跨发行版安装、自动补全32位驱动、残留清理、权限智能切换
# =================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 权限与身份初始化
[[ "$EUID" -ne 0 ]] && echo -e "${RED}[错误] 请使用 sudo 运行此脚本。${NC}" && exit 1
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}     Steam Installer for General Linux   ${NC}"
echo -e "${BLUE}=========================================${NC}"

# 发行版精准侦测
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    ID_LIKE_LIST=$ID_LIKE
    echo -e "${GREEN}[信息] 检测到系统: $NAME ($DISTRO)${NC}"
else
    echo -e "${RED}[错误] 无法识别发行版，尝试进入通用模式。${NC}"
    DISTRO="unknown"
fi

# --- 核心功能 1: 显卡驱动补全 ---
install_gpu_libs() {
    GPU_TYPE=$(lspci | grep -iE 'vga|display' | tr '[:upper:]' '[:lower:]')
    echo -e "${YELLOW}[检测] 正在为 $GPU_TYPE 安装 32位 兼容库...${NC}"

    case "$DISTRO" in
        ubuntu|debian|kali|linuxmint|pop)
            apt update
            if [[ $GPU_TYPE == *"nvidia"* ]]; then
                apt install -y libnvidia-gl-535:i386 2>/dev/null || echo "请手动核对Nvidia驱动版本"
            else
                apt install -y libgl1-mesa-dri:i386 libglx-mesa0:i386 mesa-vulkan-drivers:i386
            fi
            ;;
        fedora|nobara|rocky|almalinux)
            if [[ $GPU_TYPE == *"nvidia"* ]]; then
                dnf install -y xorg-x11-drv-nvidia-libs.i686
            else
                dnf install -y mesa-dri-drivers.i686 vulkan-loader.i686 mesa-vulkan-drivers.i686
            fi
            ;;
        arch|manjaro|endeavouros)
            if [[ $GPU_TYPE == *"nvidia"* ]]; then
                pacman -S --noconfirm lib32-nvidia-utils
            else
                pacman -S --noconfirm lib32-mesa lib32-vulkan-radeon lib32-vulkan-intel
            fi
            ;;
        opensuse*|suse)
            zypper install -y Mesa-libGL1-32bit Mesa-dri-32bit
            ;;
    esac
}

# --- 核心功能 2: 发行版安装逻辑 ---
install_logic() {
    case "$DISTRO" in
        ubuntu|debian|kali|linuxmint|pop)
            [[ "$DISTRO" == "kali" ]] && wget -q -O - https://archive.kali.org/archive-key.asc | apt-key add -
            dpkg --add-architecture i386
            apt update
            [[ "$DISTRO" == "ubuntu" ]] && add-apt-repository multiverse -y && apt update
            apt install -y steam || apt install -y steam-installer
            ;;
        fedora|nobara)
            dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                           https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            dnf install -y steam
            ;;
        arch|manjaro|endeavouros)
            sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
            pacman -Syu --noconfirm steam ttf-liberation
            ;;
        *)
            echo -e "${YELLOW}[警告] 未知发行版，尝试寻找 Flatpak 作为备选计划...${NC}"
            if command -v flatpak &> /dev/null; then
                sudo -u "$REAL_USER" flatpak install flathub com.valvesoftware.Steam -y
            else
                echo -e "${RED}[错误] 脚本无法在此系统上自动安装。请访问 steamstatic.com 手动下载。${NC}"
                exit 1
            fi
            ;;
    esac
}

# --- 核心功能 3: 智能清理与启动 ---
launch_steam() {
    echo -e "${YELLOW}[清理] 正在结束残留的 Steam 进程以防止“Already Running”报错...${NC}"
    pkill -9 -u "$REAL_USER" steam 2>/dev/null
    rm -f "$USER_HOME/.steam/steam.pid"

    echo -e "${GREEN}[操作] 正在以用户 $REAL_USER 身份在新窗口启动 Steam...${NC}"
    TERMS=("gnome-terminal" "konsole" "xfce4-terminal" "qterminal" "xterm")
    for term in "${TERMS[@]}"; do
        if command -v "$term" &> /dev/null; then
            sudo -u "$REAL_USER" "$term" -- bash -c "echo 'Steam 正在自更新，请耐心等待窗口弹出...'; steam; exec bash" &
            return
        fi
    done
    sudo -u "$REAL_USER" steam & 
}

# 执行流程
install_logic
echo -e "${YELLOW}[询问] 是否安装显卡 32bit 兼容库（解决闪退的核心）？(y/n)${NC}"
read -p "> " gpu_ans
[[ "$gpu_ans" == "y" ]] && install_gpu_libs

echo -e "${YELLOW}[询问] 是否立即启动 Steam？(y/n)${NC}"
read -p "> " start_ans
[[ "$start_ans" == "y" ]] && launch_steam

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}        脚本执行完毕，祝游戏愉快！       ${NC}"
echo -e "${GREEN}=========================================${NC}"