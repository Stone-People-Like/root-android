# 外部信息与版本查询

## 版本检查（GitHub API）

直接运行 `scripts/check_latest_versions.sh`，或手动：

```bash
curl -fsSL https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep tag_name
curl -fsSL https://api.github.com/repos/tiann/KernelSU/releases/latest | grep tag_name
```

## 官方固件下载源

- Pixel：Google Factory Images 页面。
- 小米/Redmi：小米社区对应机型板块、Mi Flash 工具。
- 三星：SamFW / Frija / Odin 固件包。
- 一加：一加社区官方固件。
- 通用：XDA Developers 机型板块置顶帖。

## 机型专属方案查询

搜索建议（可用 Playwright 抓取页面）：

- `site:xdaforums.com <机型> root`
- `site:xdaforums.com <机型> bootloader unlock`
- `<机型> magisk <Android版本>`

优先看：官方公告、XDA 置顶教程、回复数多且近期活跃的帖子。

## 验证外部信息

- 核对机型代号（`ro.product.device`）与教程/固件完全一致。
- 核对 Android 版本与安全补丁；跨大版本刷入是常见变砖原因。
- 固件来源必须是官方域名或可信镜像，不下载来路不明的 `.img/.zip`。
- 下载后校验：官方页面通常提供 SHA-256，用 `shasum -a 256 <文件>` 比对。

## 安全验证

- [ ] 下载源为官方/可信渠道。
- [ ] 镜像版本与设备完全匹配。
- [ ] 大版本、内核、分区方案（A/B、dynamic partitions）确认一致。
