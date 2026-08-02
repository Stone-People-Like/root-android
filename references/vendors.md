# 品牌知识库（解锁政策与注意事项）

通用规则：先查官方页面确认当前政策，政策经常变化；运营商定制版（US/CA 等）通常锁得更死。

| 品牌 | 官方解锁 | 主要工具/命令 | 数据清除 | 备注 |
| --- | --- | --- | --- | --- |
| Pixel | 支持 | `fastboot flashing unlock` | 是 | 官方 factory image 完整；部分运营商版锁 BL |
| 小米/Redmi | 支持（受限） | Mi Unlock 工具 | 是 | 需账号+解锁资格+等待（7 天常见）；HyperOS 部分机型收紧 |
| 一加 | 部分支持 | `fastboot oem unlock` / 官方申请 | 是 | ColorOS 时代部分机型需资格，某些地区不可解 |
| 三星 | 部分支持 | OEM 开关 + Odin/官方流程 | 是 | 仅部分国际版 Exynos 可解；美/加版基本不可解；Knox 熔断 0x1 永久 |
| OPPO/vivo/realme | 基本不支持 | — | — | 多数机型无官方解锁渠道 |
| 华为/荣耀 | 不支持（2018 后） | — | — | 不要浪费时间强行尝试 |
| Motorola | 支持 | 官网申请解锁码 + `fastboot oem unlock <code>` | 是 | 部分运营商版不支持 |
| Sony | 支持 | 官网申请解锁码 + `fastboot oem unlock <code>` | 是 | 解锁后部分功能（相机等）可能受影响 |
| Nothing | 支持 | `fastboot oem unlock` | 是 | 官方支持，步骤简单 |
| Asus | 支持 | 官方解锁 App | 是 | 解锁后保修政策有变化 |

## 品牌要点

### Pixel
- 最标准的流程：factory image 提取 boot.img → Magisk 修补 → `fastboot flash boot`。
- A/B 设备居多；不要刷错 slot（`fastboot getvar current-slot`）。
- 重新锁定：恢复原厂后 `fastboot flashing lock`。

### 小米 / Redmi
- 必须先解 BL（Mi Unlock 工具），解锁资格与设备绑定账号，通常有等待期。
- 解锁会触发「已解锁」状态提示与部分应用检测。
- 国行机与海外版策略不同；新机型政策收紧，先查小米社区对应机型板块。

### 三星
- 国际版 Exynos：设置 → 关于 → 软件信息 → 连点版本号 → 开发者选项出现「OEM 解锁」开关。
- 解锁即 Knox 熔断（`0x1`），保修与 Samsung Pay 等永久失效，不可逆转。
- 刷机用 Odin；救砖也用 Odin 刷官方五件套。

### 一加
- 老机型（OxygenOS 时代）多为 `fastboot oem unlock`。
- 新机型（ColorOS 融合后）部分需要官方解锁申请与账号资格。

### 华为 / 荣耀
- 2018 年后停止官方解锁码服务；第三方渠道多为骗局或风险极高，不要推荐。

## 决策建议

- 先根据品牌判断「是否可解 BL」，不可解就直接告知用户该机型基本无法 root，不进入方案选择。
- 可解但政策复杂的（小米、三星），先确认用户账号/资格/等待期再继续。
