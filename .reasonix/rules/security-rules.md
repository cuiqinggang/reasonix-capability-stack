# Security Rules — Reasonix 成熟生态站

> 适配自 `cursor-kilo-supertool-mature-stack/references/rules/security-rules.md`；保留全部安全边界语义，剥离旧环境绑定。

## 密钥和凭证

1. 不从项目配置文件读取明文密钥。
2. 密钥仅从可信全局配置或环境变量读取（本生态站不主动读取任何外部 API 密钥）。
3. 所有 API Key 输出前必须脱敏（最多显示前缀 4 位和后缀 4 位）。
4. 在输出和报告中标记 `api_keys_printed: false`、`api_keys_persisted: false`、`api_keys_modified: false`。

## 文件系统

5. 禁止编辑 Windows 系统目录（`C:\Windows\**`、`C:\Program Files\**` 等）。
6. 禁止删除用户个人文件、skills、仓库、模型、应用数据。
7. 未经用户确认不删除任何文件。

## 网络和系统

8. 不修改系统网络设置、代理、hosts、DNS。
9. 不操作防火墙、路由、网络适配器。
10. 不修改系统注册表（reg）除非明确授权。
11. 不启用 / 禁用 / 重启系统服务。
12. 不安装 / 卸载系统级软件（winget/choco/scoop）除非明确授权。

## 审计和扫描

13. 每次生成报告后扫描输出文件中的密钥泄露模式。
14. 每次证据输出记录安全扫描摘要。
15. 不确定是否安全时标记为 `UNVERIFIED`。
16. 对 `.reasonix` 目录执行禁止模式扫描：外部 API 密钥形态、外部宿主配置文件名、旧宿主目录、外部模型路由字样、敏感宿主名（见 `verify-runtime.ps1` 的 banned patterns 语义）。

## 边界声明

- 本生态站不读取、不连接、不修改、不迁移任何被禁止的外部宿主系统。
- 不复制外部宿主配置、路由、密钥或旧绝对路径。
- 多模态/视觉能力在未配置视觉模型前一律标注 `READY_PENDING_PROVIDER_CONFIG`，不得伪造真实视觉调用成功。
