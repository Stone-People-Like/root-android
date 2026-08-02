#!/bin/bash
# 回滚刷入原版镜像（boot/recovery）
# 用法: restore_images.sh boot|recovery <镜像文件> [--yes]
set -u

PART="${1:-}"
IMG="${2:-}"

if [ -z "$PART" ] || [ -z "$IMG" ]; then
  echo "用法: $0 boot|recovery <镜像文件> [--yes]"
  exit 1
fi

case "$PART" in
  boot|recovery) ;;
  *) echo "错误: 分区必须是 boot 或 recovery"; exit 1 ;;
esac

[ -f "$IMG" ] || { echo "错误: 镜像文件不存在: $IMG"; exit 1; }

if [ "${3:-}" != "--yes" ]; then
  echo "警告: 即将刷写 $PART 分区，请确认镜像与机型/版本完全匹配。"
  read -r -p "输入 YES 继续: " ans
  [ "$ans" = "YES" ] || { echo "已取消"; exit 1; }
fi

adb reboot bootloader || { echo "错误: 无法进入 bootloader"; exit 1; }
sleep 3
fastboot flash "$PART" "$IMG" || { echo "错误: 刷写失败"; exit 1; }
fastboot reboot
