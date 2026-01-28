#!/usr/bin/env bash
set -euo pipefail

# 菜单项（可按你习惯改文案/图标）
entries=$(
  cat <<'EOF'
󰐥 关机
󰜉 重启
󰤄 挂起
󰒲 休眠
󰍃 注销
󰗼 锁屏
EOF
)

choice=$(printf "%s\n" "$entries" | rofi -dmenu -i -p "Power" -no-custom)

case "$choice" in
"󰐥 关机")
  systemctl poweroff
  ;;
"󰜉 重启")
  systemctl reboot
  ;;
"󰤄 挂起")
  systemctl suspend
  ;;
"󰒲 休眠")
  systemctl hibernate
  ;;
"󰍃 注销")
  # Hyprland 注销
  hyprctl dispatch exit
  ;;
"󰗼 锁屏")
  # 你若用 hyprlock/swaylock 任选其一
  if command -v hyprlock >/dev/null 2>&1; then
    hyprlock
  elif command -v swaylock >/dev/null 2>&1; then
    swaylock
  else
    notify-send "Lock" "未找到 hyprlock/swaylock"
  fi
  ;;
*)
  exit 0
  ;;
esac
