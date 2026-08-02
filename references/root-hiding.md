# root 隐藏与完整性检测

## 检测当前完整性状态

常用工具：Play Integrity API Checker、SafetyNet Helper（已过时）。

- **basic integrity**：检测系统被篡改，root/解锁通常会触发失败。
- **device integrity**：检测设备指纹与 Google 认证，刷机/解锁后常失败。
- **strong integrity**：硬件级密钥证明，root 后基本无法通过，**任何方案都不能保证绕过**。

## Magisk 自带隐藏

1. Magisk 设置 → 打开 Zygisk。
2. 配置 DenyList：把需要隐藏的 App（银行、支付、游戏）加入列表。
3. 重启生效。

限制：仅对部分检测有效；App 更新检测手段后可能失效。

## Shamiko（Zygisk 模块）

- 更强力的隐藏方案，需配合 Zygisk 使用，DenyList 勾选目标应用。
- 从可信来源（GitHub 官方仓库）下载；模块安装后重启。
- 不保证 100% 有效，尤其对 strong integrity 与自研检测。

## KernelSU 的隐藏特点

- 内核级实现，对应用层隐藏能力更强，系统改动更小。
- 同样不保证绕过 strong integrity。

## 如实告知用户

- 不要承诺「一定能隐藏」；说明检测在持续升级，隐藏方案可能随时失效。
- 推荐验证方式：安装 Play Integrity API Checker 查看结果。
- 如果应用要求 strong integrity 且必须使用，root 与该应用可能无法共存。
