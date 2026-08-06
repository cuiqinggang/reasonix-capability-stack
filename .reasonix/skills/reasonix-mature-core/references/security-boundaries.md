# 安全边界与审计细则

来源：`cursor-kilo-supertool-mature-stack/SKILL.md`（Non-Negotiable Safety Boundaries）+ `agents/security-auditor.md`。本文件为主 SKILL.md §安全边界的展开细则。

## 硬性边界（违反即停止并报告）

1. 不打印完整 API 密钥、token、身份证号、地址、电话号码；展示时仅前缀 4 位 + 后缀 4 位脱敏。
2. 不修改系统/网络/代理配置；不安装、卸载、重装 IDE 或运行时。
3. 不改变其他工具/模型的默认配置，不把未经验证的模型设为默认执行器。
4. 不保存明文密钥到项目配置、技能文件或 checkpoint。
5. 不做用户未明确要求的破坏性操作（卸载、回滚、删除备份）；有疑问先询问（ask）。
6. 不继续用户已表示意外的自动化；改用文件/CLI 证据，或先征得同意。
7. 不读取、复制、接入被明确禁止的系统或目录；只处理授权范围内的内容。
8. 检测到"模型漂移"式静默替换（默认执行器被未授权对象顶替）→ 标记并升级审查，不自行绕过。

## 证据边界

- 证据不完整时如实说明，不得声称完整 PASS。
- 区分声明类型：`active_config_confirmed` / `local_report_confirmed` / `user_decision_confirmed` / `live_call_verified`（仅当真实调用返回非空结果）。
- UI/外部系统证据缺失时，明说"未做可见 UI 验证"，不得虚报。

## 安全审计要点（供 reasonix-review-audit 模式 audit 使用）

审计维度：密钥/凭证、文件权限、依赖安全、数据泄露、配置安全（CORS/CSP/HTTPS）。

### 扫描模式

```
/api[_-]?key\s*[:=]\s*['"][A-Za-z0-9_\-]{8,}['"]/i
/sk-[A-Za-z0-9]{32,}/
/(OPENROUTER|ANTHROPIC|OPENAI|GEMINI)_API_KEY\s*[:=]\s*['"][A-Za-z0-9_\-]{8,}['"]/i
```

### 敏感路径

```
/\.env$/
/\.git\/credentials$/
/key\.pem$/
/id_rsa$/
```

### 审计输出要求

- findings 的 description 不得包含完整密钥（脱敏展示）。
- 输出 verdict：`PASS` / `WARNING` / `FAIL`。
