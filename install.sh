#!/bin/bash

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}   CAO-PNG 的 Arch-Hyprland 一键部署脚本   ${NC}"
echo -e "${BLUE}==========================================${NC}"

# --- 1. 安装 AUR 助手 (yay) ---
if ! command -v yay &>/dev/null; then
  echo -e "${YELLOW}未检测到 yay，正在安装...${NC}"
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay && makepkg -si --noconfirm && cd ..
  rm -rf yay
else
  echo -e "${GREEN}检测到 yay，跳过安装。${NC}"
fi

# --- 2. 安装核心依赖包 ---
# 这里的列表包含了 Hyprland 运行所需的最常见组件
echo -e "${YELLOW}正在安装核心依赖包...${NC}"
packages=(
  hyprland waybar kitty rofi-wayland
  mako swww swaylock-effects-git
  otf-font-awesome ttf-jetbrains-mono-nerd
  slurp grim wl-copy libnotify
  polkit-gnome qt5-wayland qt6-wayland
  fastfetch thunar
)

yay -S --needed --noconfirm "${packages[@]}"

# --- 3. 自动处理配置文件 (软链接) ---
echo -e "${YELLOW}开始部署配置文件...${NC}"
DOT_CONFIG="$HOME/.config"
REPO_DIR=$(pwd)

# 确保 .config 目录存在
mkdir -p "$DOT_CONFIG"

# 遍历当前仓库下的所有目录（排除 .git 和脚本自身）
for dir in */; do
  # 去掉目录名末尾的斜杠
  dir=${dir%/}

  # 忽略不需要链接的目录
  if [[ "$dir" == ".git" ]]; then
    continue
  fi

  echo -e "${BLUE}处理配置: $dir${NC}"

  # 如果系统 ~/.config 中已存在同名目录或文件，先备份
  if [ -e "$DOT_CONFIG/$dir" ]; then
    if [ -L "$DOT_CONFIG/$dir" ]; then
      echo "删除旧的软链接: $dir"
      rm "$DOT_CONFIG/$dir"
    else
      echo "备份旧配置: $dir -> ${dir}.bak"
      mv "$DOT_CONFIG/$dir" "$DOT_CONFIG/${dir}.bak"
    fi
  fi

  # 创建软链接
  echo -e "${GREEN}链接 $dir 到 $DOT_CONFIG/$dir${NC}"
  ln -sf "$REPO_DIR/$dir" "$DOT_CONFIG/$dir"
done

echo -e "${BLUE}==========================================${NC}"
echo -e "${GREEN}   部署完成！请重启或手动启动 Hyprland。   ${NC}"
echo -e "${BLUE}==========================================${NC}"
