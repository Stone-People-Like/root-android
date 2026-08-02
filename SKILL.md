---
name: root-android
description: "Menu-driven Android skill covering detailed device inspection, bootloader (BL) lock status, guided rooting with mandatory safety checks, Magisk custom module creation, and Magisk module recommendations. Use when the user wants to root an Android phone or tablet, view detailed phone data, check BL lock status, create a custom Magisk module, or get module recommendations."
---

# Root Android

菜单式 skill：调用后先展示 5 个选项，等用户选择后再执行对应流程。覆盖 Android 设备信息查看、BL 锁状态、root、Magisk 模块制作与推荐（iOS 越狱不在范围内）。

## 安全与合规（先读）

开始任何操作前，向用户说明并确认：

- 仅处理用户本人拥有的设备，且所在地区法律允许相关操作。
- root/解锁/安装模块都可能清空数据、使保修失效、导致设备异常，操作前必须备份。
- 优先参考该品牌/机型的官方指南；任何失败都不盲目重试。

## 调用后先检测 adb 连接

用户触发本 skill 后，不要直接展示菜单，先确认能否控制手机：

### 第一步：判断当前系统

- macOS：执行 `uname -s`，输出为 `Darwin`；未安装 adb 时用 `brew install android-platform-tools`。
- Windows：执行 PowerShell `$env:OS`，输出为 `Windows_NT`；从 Google 官方 platform-tools 下载并加入 PATH。

安全验证：

- [ ] 检测结果与用户实际使用的系统一致。
- [ ] `adb` 命令可用并能输出版本信息。

### 第二步：检测 adb 能否控制手机

开启「开发者选项」→「USB 调试」，连接手机并执行 `adb devices`，设备状态必须为 `device`。

| 现象 | 原因 | 解决方案 |
| --- | --- | --- |
| 无设备输出 | USB 调试未开启、线材不支持数据传输 | 开启 USB 调试；换原装数据线；检查 USB 连接模式 |
| `unauthorized` | 未在手机上确认授权弹窗 | 解锁屏幕，点击「允许 USB 调试」 |
| `offline` | adb 服务异常 | `adb kill-server` → `adb start-server`，重新插拔设备 |
| macOS 无法识别 | 系统权限未授予 | 检查「隐私与安全性」设置 |
| Windows 无法识别 | 缺少 USB 驱动 | 安装手机品牌官方 OEM 驱动 |

### 结果分支

- 状态为 `device` → 进入下方菜单。
- 无法控制手机 → 按上表排查，解决后重新执行 `adb devices`；确认可控后才展示菜单。
- 手机未连接时，先指导用户开启 USB 调试并完成连接，不要跳过此步骤。

## 菜单（adb 可控后展示）

确认手机可控后，展示以下选项并等待选择：

1. 查看手机详细数据
2. BL 锁状态
3. root
4. 自定义模块制作
5. 模块推荐

根据用户选择执行对应部分；完成一个选项后，询问用户是否需要返回菜单选择其他操作。

## 选项 1：查看手机详细数据

只读操作，不修改设备。

### 前置检查

- `adb devices` 显示设备状态为 `device`。
- 确认设备为用户本人所有。

### 采集数据

```bash
adb shell getprop ro.product.brand
adb shell getprop ro.product.model
adb shell getprop ro.product.device
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.security_patch
adb shell getprop ro.build.version.sdk
adb shell getprop ro.build.ab_update
adb shell getprop ro.product.cpu.abi
adb shell uname -r
adb shell cat /proc/meminfo | head -5
adb shell df -h /data | tail -1
adb shell dumpsys battery | grep -E "level|status|temperature"
adb shell "su -c id" 2>&1
```

### 输出

以清单形式展示：品牌/型号/设备代号、Android 版本、SDK、安全补丁、A/B 分区、CPU 架构、内核版本、内存、存储剩余、电池电量与温度、root 状态。

### 安全验证

- [ ] 全程只读，未执行任何写入/刷写命令。
- [ ] 已向用户确认设备信息展示完整。

## 选项 2：BL 锁状态

只读检查 bootloader 锁状态，不执行解锁。

### 操作

```bash
adb shell getprop ro.boot.vbmeta.device_state
adb shell getprop ro.boot.flash.locked
adb shell getprop ro.boot.verifiedbootstate
adb shell getprop ro.boot.warranty_bit
```

如需二次确认（会短暂进入 bootloader，但不写入数据）：

```bash
adb reboot bootloader
fastboot getvar unlocked
fastboot oem device-info
fastboot reboot
```

### 结果解释

- `ro.boot.vbmeta.device_state`：`locked` / `unlocked`。
- `ro.boot.verifiedbootstate`：`green`（锁定且验证通过）/ `orange`（已解锁）/ `red`（验证失败或系统被篡改）。
- fastboot 输出 `unlocked: yes` 或 `Device unlocked: true` 表示已解锁。

### 安全验证

- [ ] 只读检查，未执行 `fastboot flashing unlock` / `oem unlock` 等命令。
- [ ] fastboot 检查结束后已通过 `fastboot reboot` 正常回到系统。

## 选项 3：root

初始 adb 连接检测已完成；进入 root 流程时仍需复检连接状态，每一步都有强制安全验证，未通过验证不得进入下一步。

### 第一步：判断当前系统

- macOS：执行 `uname -s`，输出为 `Darwin`；未安装 adb 时用 `brew install android-platform-tools`。
- Windows：执行 PowerShell `$env:OS`，输出为 `Windows_NT`；从 Google 官方 platform-tools 下载并加入 PATH。

安全验证：

- [ ] 检测结果与用户实际使用的系统一致。
- [ ] `adb` 命令可用并能输出版本信息。

### 第二步：检测 adb 能否控制手机

开启「开发者选项」→「USB 调试」，执行 `adb devices`，设备状态必须为 `device`。

| 现象 | 原因 | 解决方案 |
| --- | --- | --- |
| 无设备输出 | USB 调试未开启、线材不支持数据传输 | 开启 USB 调试；换原装数据线；检查 USB 连接模式 |
| `unauthorized` | 未在手机上确认授权弹窗 | 解锁屏幕，点击「允许 USB 调试」 |
| `offline` | adb 服务异常 | `adb kill-server` → `adb start-server`，重新插拔设备 |
| macOS 无法识别 | 系统权限未授予 | 检查「隐私与安全性」设置 |
| Windows 无法识别 | 缺少 USB 驱动 | 安装手机品牌官方 OEM 驱动 |

安全验证：

- [ ] `adb devices` 稳定显示设备且状态为 `device`。
- [ ] 设备为用户本人所有，数据已备份，电量 ≥ 50%。

### 第三步：采集手机信息并给出三套方案

采集信息：

```bash
adb shell getprop ro.product.brand
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.security_patch
adb shell getprop ro.boot.vbmeta.device_state
adb shell getprop ro.build.ab_update
adb shell "su -c id" 2>&1
```

向用户展示：品牌/型号、Android 版本与安全补丁、bootloader 状态、是否 A/B 设备、是否已 root。

三套方案：

- **方案一：Magisk 修补 boot image**（最通用，推荐）：获取原厂 boot.img → Magisk App 修补 → fastboot 刷入 boot 分区；可回滚，模块化支持好。
- **方案二：自定义 Recovery（TWRP）刷入 Magisk**：刷入匹配机型的 recovery → 进入 recovery 刷入 Magisk zip；适合老机型或不便 fastboot 刷入的场景。
- **方案三：KernelSU（内核级 root）**：用匹配的 boot.img 修补/集成内核后刷入；适合 GKI 设备，root 更隐蔽但内核不匹配风险高。

展示后必须停下来等待用户明确选择（回复「方案一/二/三」）；用户未选择前不进入第四步，不执行任何刷写操作。

安全验证：

- [ ] 手机信息已完整采集并展示。
- [ ] 三套方案已按设备实际情况说明差异。
- [ ] 用户已明确选择其中一套方案。
- [ ] 已确认官方固件/镜像下载渠道。

### 第四步：告知所选方案的风险与后果

针对所选方案逐条告知：

通用后果：

- 解锁 bootloader 会清空全部数据（方案一、二通常需要解锁）。
- 保修失效，厂商可能拒绝后续售后。
- OTA 系统更新可能失败或被拦截。
- 银行、支付、部分游戏与安全应用可能检测 root 并拒绝运行。

方案特有风险：

- 方案一：boot 镜像版本不匹配 → 卡开机循环；可用原 boot.img 回滚。
- 方案二：recovery 不匹配 → 无法进系统或 recovery 异常；需重刷官方 recovery。
- 方案三：内核与设备不匹配 → 无法开机或硬件异常；需重刷官方 boot.img。

兜底方案：操作前保留原版 boot.img / recovery 镜像，并准备好对应回滚命令（如 `fastboot flash boot <原镜像>`）。

最终安全验证（全部通过才允许执行）：

- [ ] 用户已逐条确认理解风险并同意继续。
- [ ] 数据已完成备份，电量 ≥ 50%，USB 连接稳定。
- [ ] 已下载与机型、版本完全匹配的官方固件与镜像。
- [ ] 已确认目标分区名称（boot / recovery）正确。

全部通过后才开始执行所选方案；执行过程中的每一步仍要暂停并向用户确认。

## 选项 4：自定义模块制作

引导用户制作自己的 Magisk 模块。

### 模块结构

```
module-name/
├── module.prop              # 必填，模块元信息
├── customize.sh             # 可选，安装时执行的脚本
├── service.sh               # 可选，开机后执行的脚本
├── post-fs-data.sh          # 可选，early 阶段脚本
├── system/                  # 需要注入/替换的系统文件（systemless 挂载）
└── META-INF/com/google/android/
    └── update-binary        # Magisk 安装器，从官方模板复制
```

### module.prop 模板

```properties
id=my_module
name=My Module
version=v1.0
versionCode=1
author=user
description=自定义模块示例
```

### 制作步骤

1. 确定模块功能（替换系统文件、开机脚本、注入配置等）。
2. 创建上述目录结构并填写 module.prop。
3. 需要脚本时编写 customize.sh / service.sh / post-fs-data.sh，避免写死设备专属路径。
4. 打包成 zip（zip 根目录即模块内容）。
5. 安装：Magisk App → 模块 → 从本地安装，或 `adb push` 到手机后安装。

### 安全验证

- [ ] 模块仅用于用户自己的设备，不含恶意或窃取数据逻辑。
- [ ] 安装前已备份数据，并确认知道如何卸载模块（Magisk 安全模式）。
- [ ] 涉及 system 文件替换时，已保留原文件或提供还原方案。
- [ ] 已确认模块与 Magisk 版本、机型兼容后再测试。

## 选项 5：模块推荐

根据设备信息与用户需求推荐 Magisk 模块。

### 推荐流程

1. 询问用户用途（音效、相机、广告拦截、续航、性能、隐私等）。
2. 如尚未获取设备信息，先执行选项 1 的信息采集（Android 版本、CPU 架构、Magisk 版本），保证兼容性。
3. 只推荐可信来源：Magisk 官方示例、GitHub 知名开源项目、XDA 验证过的模块。
4. 每条推荐注明：功能、适用版本、安装方式、已知风险、卸载方式。

### 常见类别（示例，推荐时按实际情况展开）

- 音效：ViPER4Android 等
- 相机：GCam 相关模块
- 广告拦截：systemless hosts 类模块
- 续航/性能：CPU 调度、省电类模块
- 隐私/安全：Zygisk + DenyList 等隐藏 root 方案

### 安全验证

- [ ] 推荐前已确认模块与设备 Android 版本/架构兼容。
- [ ] 已提示用户备份与回滚方式。
- [ ] 未推荐来源不明、闭源可疑或含推广内容的模块。

## 通用规则

- 任何选项开始前，如设备未连接，先解决 adb 连接问题。
- 任何操作失败，立即停止并诊断原因，不盲目重试。
- 任何涉及写入/刷写/安装的操作，安全验证未通过不得执行。
