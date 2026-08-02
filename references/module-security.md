# 模块安全审计

模块以 root 权限运行，等于把设备控制权交给模块作者。安装前必须审计。

## 审计清单

- 来源：官方仓库 / XDA 验证帖 / 知名开发者；优先有 GitHub 源码与 Release 的项目。
- 活跃度：近期有提交/发布，issue 区有人维护。
- 代码可读：模块内脚本应可读，不存在大量混淆、二进制 blob。
- 网络行为：检查脚本中是否出现 `curl`、`wget`、`nc`、`iptables`、外网域名。
- 数据行为：检查是否读取 `/data` 敏感文件、联系人、短信、账户信息并外传。
- 权限：是否请求多余权限、是否替换系统关键文件。
- 体积：模块体积异常大（几十 MB 且无说明）需要警惕。
- 评论：社区反馈是否有偷数据、弹广告、后门历史。

## 常见恶意特征（红旗）

- `curl ... | sh` 或从陌生域名下载执行。
- base64 编码的大段 payload。
- 静默收集设备信息并上传（出现遥测域名）。
- 请求设备管理员/无障碍权限。
- 安装后修改 hosts 注入广告或劫持流量。
- 与模块功能无关的持久化机制（自启、篡改 init）。

## 审计命令示例

```bash
# 解压到临时目录检查
unzip -l suspicious-module.zip
unzip -o suspicious-module.zip -d /tmp/mod_audit

# 搜索可疑网络/执行行为
grep -rniE "curl|wget|nc |iptables|http://|https://|base64|eval|chmod 777" /tmp/mod_audit

# 查看安装/开机脚本内容
cat /tmp/mod_audit/customize.sh /tmp/mod_audit/service.sh /tmp/mod_audit/post-fs-data.sh
```

## 安全安装原则

- 一次只装一个模块，出问题好定位。
- 安装前备份；保留模块 zip。
- 使用 Magisk 安全模式应急（音量减开机）。
- 不安装来源不明、无源码、无社区验证的模块。
