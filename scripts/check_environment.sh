#!/bin/bash
# 检查宿主系统与 adb/fastboot 环境
set -u

case "$(uname -s 2>/dev/null || echo unknown)" in
  Darwin) os="macOS" ;;
  Linux) os="Linux" ;;
  MINGW*|MSYS*|CYGWIN*) os="Windows" ;;
  *) os="unknown" ;;
esac
echo "OS: $os"

for tool in adb fastboot; do
  if command -v "$tool" >/dev/null 2>&1; then
    path="$(command -v "$tool")"
    version="$("$tool" --version 2>/dev/null | head -1)"
    echo "$tool: $path ($version)"
  else
    echo "$tool: NOT FOUND"
    case "$os" in
      macOS) echo "  Fix: brew install android-platform-tools" ;;
      Linux) echo "  Fix: sudo apt install adb fastboot" ;;
      *) echo "  Fix: download platform-tools from https://developer.android.com/tools/releases/platform-tools" ;;
    esac
  fi
done
