#!/bin/bash
# 操作审计日志：追加一条带时间戳的记录
# 用法: log_operation.sh "操作描述" [附加信息]
set -u

LOG_DIR="${ROOT_ANDROID_LOG_DIR:-$HOME/.root-android}"
LOG_FILE="$LOG_DIR/audit.log"
mkdir -p "$LOG_DIR"

DESC="${1:-未命名操作}"
EXTRA="${2:-}"
printf '%s | %s | %s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$(whoami)" "$DESC" "$EXTRA" >> "$LOG_FILE"
echo "已记录: $LOG_FILE"
