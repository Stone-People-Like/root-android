#!/bin/bash
# 查询 Magisk / KernelSU 等最新版本（GitHub API）
set -u

latest() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | head -1 | sed 's/.*: "\(.*\)".*/\1/'
}

echo "Magisk: $(latest topjohnwu/Magisk)"
echo "KernelSU: $(latest tiann/KernelSU)"
