#!/bin/bash
# 备份 boot/recovery 分区镜像（需要 root）
# 用法: backup_images.sh boot|recovery [输出目录]
set -u

PART="${1:-boot}"
OUT="${2:-./backup}"

case "$PART" in
  boot|recovery) ;;
  *) echo "用法: $0 boot|recovery [输出目录]"; exit 1 ;;
esac

if ! adb shell "su -c id" 2>/dev/null | grep -q 'uid=0'; then
  echo "错误: 需要 root 权限才能读取分区" >&2
  exit 1
fi

mkdir -p "$OUT"
adb shell "su -c 'dd if=/dev/block/by-name/${PART} of=/sdcard/${PART}-backup.img bs=4M'" >/dev/null 2>&1 || {
  echo "错误: 读取分区失败（分区路径可能不同）" >&2
  exit 1
}
adb pull "/sdcard/${PART}-backup.img" "$OUT/" && echo "已备份: $OUT/${PART}-backup.img"
