# 卸载 root / 恢复原厂

## 卸载 Magisk

方式一（推荐，最简单）：Magisk App → 设置 → 卸载 Magisk → 选择「还原原厂镜像」→ 自动重启完成。

方式二（手动）：刷回原版 boot 镜像：

```bash
adb reboot bootloader
fastboot flash boot boot-backup.img
fastboot reboot
```

方式三（Magisk 卸载包）：从 Magisk GitHub Releases 下载 `Magisk-uninstaller-*.zip`，在 recovery 或 Magisk App 中刷入。

## 移除自定义模块

- 若模块导致问题，先卸载模块再卸载 root：Magisk App → 模块 → 逐个卸载。
- 进不了系统时：Magisk 安全模式（按住音量减开机）会临时禁用全部模块。

## 恢复官方 recovery

- 若刷过 TWRP，用官方固件包里的 recovery 镜像刷回：

```bash
fastboot flash recovery recovery.img
```

## 恢复原厂系统（可选）

- 下载官方全量固件（factory image / 全量包），用厂商官方工具或 fastboot/Odin 刷回。
- 恢复后不要立即重锁 BL，先确认系统正常。

## 重新锁定 bootloader（仅恢复原厂后）

```bash
adb reboot bootloader
fastboot flashing lock
```

重锁会再次清空全部数据，且必须在**完全原厂状态**下执行，否则可能无法开机。

## 验证卸载成功

```bash
adb shell "su -c id" 2>&1          # 应报错或 not found
adb shell getprop ro.boot.verifiedbootstate   # 期望 green
adb shell "ls /data/adb/magisk" 2>&1          # 应不存在
```

## 注意事项

- 卸载前确认用户已接受「root 相关数据/设置会丢失」。
- 三星等机型 Knox 熔断不可逆，卸载 root 不会恢复保修状态，提前告知。
- 重锁 BL 是高风险操作，必须确认系统为官方原厂且镜像匹配。
