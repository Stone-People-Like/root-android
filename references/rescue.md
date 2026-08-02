# 救砖与恢复

救砖第一原则：**先判断设备处于什么状态，再选择工具，绝不盲目刷写。**

## 状态判断

| 状态 | 特征 | 可行方向 |
| --- | --- | --- |
| 正常系统 | 能开机进桌面 | 无需救砖 |
| bootloop | 反复重启/卡 logo | fastboot 或 recovery 重刷 |
| fastboot 模式 | 能进 bootloader（`fastboot devices` 可见） | fastboot 刷写 |
| recovery 模式 | 能进 TWRP/官方 recovery | 刷 zip / 恢复出厂 |
| EDL/9008（高通） | 黑屏但电脑识别 COM 口 | QFIL/QPST 深度刷机 |
| MTK 模式 | 黑屏，需短接测试点 | SP Flash Tool |
| 完全无反应 | 插电无任何指示灯 | 先充电 30 分钟再判断；确认不是电池耗尽 |

## 通用安全规则

- 电量充足或边充边刷；刷写中绝对不要拔线。
- 每个刷写命令前确认：镜像来源官方、型号与版本完全匹配、分区名正确。
- 刷写失败先读错误输出，不重复盲目执行。
- 除非必要（如重锁），不要 wipe userdata，减少数据损失。

## fastboot 救砖（最常见）

1. 进入 bootloader：`adb reboot bootloader`（或按键组合）。
2. 确认可见：`fastboot devices`。
3. 刷入官方镜像（以 Pixel 为例）：

```bash
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_boot vendor_boot.img
fastboot reboot
```

4. 通用厂包（如 Pixel factory image）解压后有 `flash-all.sh`，直接执行可完整恢复。

## 高通 EDL / 9008 深度救砖

- 适用：高通机型黑屏、fastboot 都进不去、电脑出现 `Qualcomm HS-USB QDLoader 9008` 端口。
- 工具：QFIL（QPST 套件）、小米官方 Mi Flash（需授权账号）、厂商售后工具。
- 需要对应机型的 `prog_emmc_firehose` 与 rawprogram/patch XML（通常来自官方固件包或社区）。
- 很多新机型 EDL 需要授权/认证，普通用户无法刷；这种情况直接建议走官方售后。

## MTK 救砖

- 工具：SP Flash Tool（MTK）。
- 需要机型 scatter 文件与固件；部分机型需要短接主板测试点进入 BROM 模式。
- 操作比高通 EDL 更依赖正确固件，务必确认版本。

## 三星 Odin 救砖

- 下载模式：关机后 `Vol Down + Bixby/侧键 + Power`。
- 用 Odin 刷官方五件套（BL/AP/CP/CSC）；CSC 选 CSC_OXM 保留数据、HOME_CSC 会清数据，按需选择。
- Knox 熔断后无法通过刷机恢复保修状态。

## 救砖后的验证

```bash
adb shell getprop ro.boot.verifiedbootstate   # green 表示验证通过
adb shell "su -c id"                          # 确认 root 是否按预期存在/移除
adb reboot bootloader && fastboot getvar unlocked
```

## 何时交给售后

- 需要厂商授权的深度刷写（EDL 认证、三星熔断后硬件故障）。
- 自己判断风险过高、镜像无法找到时，及时止损交给官方售后。
