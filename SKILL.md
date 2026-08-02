---
name: root-android
description: "Menu-driven Android skill: detailed device inspection, BL lock status, guided rooting, Magisk module creation and recommendations, brick rescue, unroot and stock restore, root hiding and integrity checks, module security audit, wireless ADB, external version lookup, and operation audit logging. Use when the user wants to root an Android phone, view device data or BL status, create or recommend Magisk modules, rescue a bricked device, unroot, hide root, audit module safety, connect via wireless ADB, or check latest tool versions."
---

# Root Android

菜单式 skill，覆盖 Android root 及相关操作（iOS 越狱不在范围内）。调用后先检测 adb 连接，确认可控后再展示菜单，等用户选择后执行对应流程。

## 安全与合规（先读）

- 仅处理用户本人拥有的设备，且所在地区法律允许相关操作。
- root/解锁/刷写/安装模块都可能清空数据、使保修失效、导致设备异常，操作前必须备份。
- 优先参考该品牌/机型的官方指南；任何失败都不盲目重试。
- 每次执行写入/刷写/安装类操作前，先调用 `scripts/log_operation.sh` 记录审计日志。

## 资源导航

### scripts/（可直接执行）

- `check_environment.sh`：检测宿主系统与 adb/fastboot 环境。
- `collect_device_info.sh`：一键采集设备详细信息。
- `backup_images.sh`：备份 boot/recovery 原镜像（需 root）。
- `restore_images.sh`：回滚刷入原版镜像（boot/recovery）。
- `build_magisk_module.sh`：生成 Magisk 模块骨架并打包 zip。
- `check_latest_versions.sh`：查询 Magisk/KernelSU 最新版本。
- `log_operation.sh`：追加一条操作审计日志。

### references/（按需读取）

- `vendors.md`：品牌解锁政策与注意事项。
- `rescue.md`：救砖与恢复（fastboot/EDL/MTK/Odin）。
- `unroot.md`：卸载 root 与恢复原厂。
- `root-hiding.md`：完整性检测与 root 隐藏。
- `module-security.md`：模块安全审计清单。
- `module-api.md`：Magisk 模块 API 参考。
- `wireless-adb.md`：无线 adb 连接。
- `external-info.md`：固件下载源与机型方案查询。

### assets/module-template/

最小可用 Magisk 模块模板（module.prop、customize.sh、service.sh、post-fs-data.sh、META-INF 安装器）。

## 调用后先检测 adb 连接

用户触发本 skill 后，不要直接展示菜单，先确认能否控制手机：

### 第一步：判断当前系统

运行 `scripts/check_environment.sh`，确认 Windows/macOS 与 adb/fastboot 可用。

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
6. 救砖与恢复
7. 卸载 root / 恢复原厂
8. root 隐藏与完整性检测
9. 模块安全审计
10. 无线 adb 连接
11. 外部信息与版本查询
12. 操作审计日志

根据用户选择执行对应部分；完成一个选项后，询问用户是否需要返回菜单选择其他操作。

## 选项 1：查看手机详细数据

只读操作。直接运行 `scripts/collect_device_info.sh`，用输出结果整理成清单展示：品牌/型号/设备代号、Android 版本、SDK、安全补丁、A/B 分区、CPU 架构、内核、内存、存储、电池、root 状态、Magisk 是否安装。

安全验证：

- [ ] 全程只读，未执行任何写入/刷写命令。
- [ ] 已向用户确认设备信息展示完整。

## 选项 2：BL 锁状态

只读检查 bootloader 锁状态，不执行解锁。

```bash
adb shell getprop ro.boot.vbmeta.device_state
adb shell getprop ro.boot.flash.locked
adb shell getprop ro.boot.verifiedbootstate
adb shell getprop ro.boot.warranty_bit
```

如需二次确认（会短暂进入 bootloader，不写入数据）：

```bash
adb reboot bootloader
fastboot getvar unlocked
fastboot oem device-info
fastboot reboot
```

结果解释：`ro.boot.vbmeta.device_state` 为 `locked`/`unlocked`；`verifiedbootstate` 为 `green`（锁定且验证通过）/`orange`（已解锁）/`red`（验证失败或被篡改）；fastboot 输出 `unlocked: yes` 表示已解锁。

安全验证：

- [ ] 只读检查，未执行 `fastboot flashing unlock` / `oem unlock` 等命令。
- [ ] fastboot 检查结束后已通过 `fastboot reboot` 正常回到系统。

## 选项 3：root

执行固定四步流程，每一步都有强制安全验证；未通过验证不得进入下一步。

### 第一步：判断当前系统

运行 `scripts/check_environment.sh`；macOS 未装 adb 用 `brew install android-platform-tools`，Windows 从 Google 官方 platform-tools 下载并加入 PATH。

安全验证：

- [ ] 检测结果与用户实际使用的系统一致。
- [ ] `adb` 命令可用并能输出版本信息。

### 第二步：检测 adb 能否控制手机

执行 `adb devices`，设备状态必须为 `device`；问题排查同上表。

安全验证：

- [ ] `adb devices` 稳定显示设备且状态为 `device`。
- [ ] 设备为用户本人所有，数据已备份，电量 ≥ 50%。

### 第三步：采集手机信息并给出三套方案

运行 `scripts/collect_device_info.sh`，展示品牌/型号、Android 版本与安全补丁、bootloader 状态、是否 A/B 设备、是否已 root。品牌解锁政策不确定时读取 `references/vendors.md`。

三套方案：

- **方案一：Magisk 修补 boot image**（最通用，推荐）：获取原厂 boot.img → Magisk App 修补 → fastboot 刷入 boot 分区；可回滚，模块化支持好。
- **方案二：自定义 Recovery（TWRP）刷入 Magisk**：刷入匹配机型的 recovery → 进入 recovery 刷入 Magisk zip；适合老机型或不便 fastboot 刷入的场景。
- **方案三：KernelSU（内核级 root）**：用匹配的 boot.img 修补/集成内核后刷入；适合 GKI 设备，root 更隐蔽但内核不匹配风险高。

展示后必须停下来等待用户明确选择（回复「方案一/二/三」）；用户未选择前不进入第四步，不执行任何刷写操作。

安全验证：

- [ ] 手机信息已完整采集并展示。
- [ ] 三套方案已按设备实际情况说明差异。
- [ ] 用户已明确选择其中一套方案。
- [ ] 已确认官方固件/镜像下载渠道（参考 `references/external-info.md`）。

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

兜底方案：操作前用 `scripts/backup_images.sh`（或固件包原文件）保留原版 boot/recovery 镜像，回滚用 `scripts/restore_images.sh`。

最终安全验证（全部通过才允许执行）：

- [ ] 用户已逐条确认理解风险并同意继续。
- [ ] 数据已完成备份，电量 ≥ 50%，USB 连接稳定。
- [ ] 已下载与机型、版本完全匹配的官方固件与镜像。
- [ ] 已确认目标分区名称（boot / recovery）正确。
- [ ] 已调用 `scripts/log_operation.sh` 记录本次操作。

全部通过后才开始执行所选方案；执行过程中的每一步仍要暂停并向用户确认。

## 选项 4：自定义模块制作

用 `scripts/build_magisk_module.sh <module-id> [模块名] [作者] [输出目录]` 从 `assets/module-template/` 生成骨架并打包；详细 API 读取 `references/module-api.md`。

### 制作步骤

1. 确定模块功能（替换系统文件、开机脚本、注入配置等）。
2. 生成骨架，填写 module.prop（id/name/version/versionCode/author/description）。
3. 需要脚本时编写 customize.sh / service.sh / post-fs-data.sh，避免写死设备专属路径。
4. 用脚本重新打包 zip（zip 根目录即模块内容）。
5. 安装：Magisk App → 模块 → 从本地安装，或 `adb push` 到手机后安装。

### 安全验证

- [ ] 模块仅用于用户自己的设备，不含恶意或窃取数据逻辑。
- [ ] 安装前已备份数据，并确认知道如何卸载模块（Magisk 安全模式）。
- [ ] 涉及 system 文件替换时，已保留原文件或提供还原方案。
- [ ] 已确认模块与 Magisk 版本、机型兼容后再测试。
- [ ] 安装前已调用 `scripts/log_operation.sh` 记录。

## 选项 5：模块推荐

### 推荐流程

1. 询问用户用途（音效、相机、广告拦截、续航、性能、隐私等）。
2. 如尚未获取设备信息，先运行 `scripts/collect_device_info.sh` 确认 Android 版本、CPU 架构、Magisk 版本。
3. 只推荐可信来源：Magisk 官方示例、GitHub 知名开源项目、XDA 验证过的模块。
4. 每条推荐注明：功能、适用版本、安装方式、已知风险、卸载方式。
5. 推荐前对模块做基础审计，读取 `references/module-security.md`。

### 安全验证

- [ ] 推荐前已确认模块与设备 Android 版本/架构兼容。
- [ ] 已提示用户备份与回滚方式。
- [ ] 未推荐来源不明、闭源可疑或含推广内容的模块。

## 选项 6：救砖与恢复

先判断设备状态（能进系统 / bootloop / fastboot / recovery / EDL-9008 / MTK / 完全无反应），再读取 `references/rescue.md` 按状态执行对应方案。

安全验证：

- [ ] 已明确设备当前状态，未盲目刷写。
- [ ] 镜像来自官方/可信渠道，且与机型、版本完全匹配。
- [ ] 电量充足，刷写中不拔线。
- [ ] 操作前已调用 `scripts/log_operation.sh` 记录。
- [ ] 需要厂商授权或风险过高时，建议用户走官方售后。

## 选项 7：卸载 root / 恢复原厂

读取 `references/unroot.md` 执行：Magisk 卸载（App 内还原 / 刷回原 boot / 卸载包）、移除模块、恢复官方 recovery、可选重锁 BL。

安全验证：

- [ ] 用户已确认接受 root 相关数据/设置丢失。
- [ ] 卸载前保留原镜像；三星等机型已告知 Knox 不可逆。
- [ ] 重锁 BL 仅在完全原厂状态执行。
- [ ] 操作前已调用 `scripts/log_operation.sh` 记录。

## 选项 8：root 隐藏与完整性检测

读取 `references/root-hiding.md`，检测 basic/device/strong integrity，配置 Zygisk + DenyList 或 Shamiko。

安全验证：

- [ ] 已如实告知用户：隐藏不能保证 100% 有效，strong integrity 基本无法绕过。
- [ ] 安装隐藏类模块前已做来源审计与备份。
- [ ] 已记录操作日志。

## 选项 9：模块安全审计

读取 `references/module-security.md`，按审计清单检查模块 zip（解压、搜网络/执行行为、读脚本），输出审计结论与红旗提示。

安全验证：

- [ ] 审计基于模块实际内容，不只看宣传文案。
- [ ] 发现恶意特征时明确建议不要安装。
- [ ] 审计过程只读（临时目录解压），不安装模块。

## 选项 10：无线 adb 连接

读取 `references/wireless-adb.md`，按步骤执行 `adb pair` 与 `adb connect`。

安全验证：

- [ ] 配对码来自用户手机屏幕。
- [ ] 已告知用户：无线 adb 不能用于 fastboot 刷写，刷写必须 USB。
- [ ] 使用完毕提醒用户关闭无线调试。

## 选项 11：外部信息与版本查询

运行 `scripts/check_latest_versions.sh` 查询 Magisk/KernelSU 最新版本；需要固件下载源或机型方案时读取 `references/external-info.md`，必要时用浏览器（Playwright）搜索 XDA/官方页面。

安全验证：

- [ ] 下载源为官方/可信渠道。
- [ ] 镜像与机型、版本、分区方案完全匹配。
- [ ] 已对下载文件做 SHA-256 校验（如官方提供）。

## 选项 12：操作审计日志

查看 `~/.root-android/audit.log`（路径可用 `ROOT_ANDROID_LOG_DIR` 环境变量覆盖）。每次写入/刷写/安装操作前都应调用 `scripts/log_operation.sh "描述"` 追加记录。

安全验证：

- [ ] 日志包含时间、用户、操作描述；信息不足时补记。
- [ ] 涉及敏感信息（账号、序列号）不写入日志。

## 通用规则

- 任何选项开始前，如设备未连接，先解决 adb 连接问题。
- 任何操作失败，立即停止并诊断原因，不盲目重试。
- 任何涉及写入/刷写/安装的操作，安全验证未通过不得执行。
- 每次写入/刷写/安装前调用 `scripts/log_operation.sh` 记录审计日志。
