#!/bin/bash
# 通过 adb 采集设备详细信息，输出 key=value 格式
set -u

if ! adb get-state >/dev/null 2>&1; then
  echo "ERROR: 没有可用 adb 设备，请先检查 USB 调试连接" >&2
  exit 1
fi

gp() { adb shell getprop "$1" 2>/dev/null | tr -d '\r'; }

echo "ro.product.brand=$(gp ro.product.brand)"
echo "ro.product.model=$(gp ro.product.model)"
echo "ro.product.device=$(gp ro.product.device)"
echo "ro.product.name=$(gp ro.product.name)"
echo "ro.build.version.release=$(gp ro.build.version.release)"
echo "ro.build.version.sdk=$(gp ro.build.version.sdk)"
echo "ro.build.version.security_patch=$(gp ro.build.version.security_patch)"
echo "ro.build.ab_update=$(gp ro.build.ab_update)"
echo "ro.product.cpu.abi=$(gp ro.product.cpu.abi)"
echo "ro.boot.vbmeta.device_state=$(gp ro.boot.vbmeta.device_state)"
echo "ro.boot.verifiedbootstate=$(gp ro.boot.verifiedbootstate)"
echo "ro.build.type=$(gp ro.build.type)"
echo "kernel=$(adb shell uname -r 2>/dev/null | tr -d '\r')"
echo "mem_total=$(adb shell cat /proc/meminfo 2>/dev/null | head -1 | tr -d '\r' | awk '{print $2 $3}')"
echo "data_free=$(adb shell df -h /data 2>/dev/null | tail -1 | tr -d '\r' | awk '{print $4}')"
echo "battery=$(adb shell dumpsys battery 2>/dev/null | grep -E 'level|status|temperature' | tr -d '\r' | tr '\n' ';')"

root="$(adb shell "su -c id" 2>/dev/null | tr -d '\r')"
if [ -n "$root" ]; then
  echo "root=$root"
else
  echo "root=NO"
fi

if adb shell "ls -d /data/adb/magisk" >/dev/null 2>&1; then
  echo "magisk_installed=yes"
else
  echo "magisk_installed=no"
fi
