# Magisk 模块 API 参考

## module.prop 字段

```properties
id=模块唯一ID（小写字母数字下划线）
name=显示名称
version=显示版本
versionCode=整数版本号（用于更新比较）
author=作者
description=描述
minMagisk=最低 Magisk 版本（可选）
updateJson=更新通道 JSON 地址（可选）
```

## 目录与脚本

```
module/
├── module.prop          # 必填
├── customize.sh         # 安装时执行；可写安装逻辑
├── service.sh           # 开机 late_start service 阶段执行
├── post-fs-data.sh      # post-fs-data 阶段执行（更早）
├── sepolicy.rule        # 可选，SELinux 规则
├── system/              # 需要注入系统的文件，按 system 目录结构放
└── META-INF/com/google/android/
    ├── update-binary    # Magisk 安装器（模板已带）
    └── updater-script   # 通常为空
```

## 常用变量（脚本内可用）

- `MODPATH`：模块安装目录。
- `MODID` / `MODNAME` / `MODVERSION`：来自 module.prop。
- `OUTFD` / `ZIPFILE`：安装器输出与 zip 路径。
- `ui_print`：打印安装信息。

## systemless 挂载说明

- `system/` 下的文件会被 Magisk 以 overlay 方式挂载，**不会真正修改 system 分区**。
- 想替换 `/system/xxx`，就把文件放到 `module/system/xxx`。
- 想追加可执行文件，放到 `module/system/bin/` 并注意架构（arm64 设备只执行 arm64 二进制）。

## 常用函数

```sh
set_perm $MODPATH/system/bin/my_tool 0 0 0755   # 属主/属组/权限
ui_print "Installing $MODNAME"                  # 安装日志
```

## 更新通道（updateJson）

JSON 指向一个托管文件：

```json
{
  "version": "v1.1",
  "versionCode": 2,
  "zipUrl": "https://example.com/module-v1.1.zip",
  "changelog": "https://example.com/changelog.md"
}
```

## 安装与卸载

- 安装：Magisk App → 模块 → 从本地安装；或 `adb push module.zip /sdcard/` 后 App 内选择。
- 卸载：Magisk App → 模块 → 卸载；或删除模块目录后重启（`/data/adb/modules/<id>`）。
- 命令行：`magisk --install-module <zip>`（需 root shell）。

## 推荐开发流程

1. 用 `scripts/build_magisk_module.sh` 生成骨架。
2. 写 module.prop 与脚本。
3. 先本地语法检查（`sh -n customize.sh`）。
4. 真机安装测试，出问题用 Magisk 安全模式移除。
