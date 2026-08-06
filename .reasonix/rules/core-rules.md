# Core Rules — Reasonix 成熟生态站

> 适配自 `cursor-kilo-supertool-mature-stack/references/rules/core-rules.md`（原 Kilo 主路由架构已剥离：不复制任何外部模型路由、Provider ID、API Key）。

## 主路由（Reasonix 原生）

```
Reasonix 原生能力栈 → 内置工具（review / security_review / test / explore / research /
task / parallel_tasks / fleet / web_fetch / bash / todo_write / run_skill / slash_command）
+ 原生技能（mature-core / review-audit / test-verify / research / gate-controller /
executor-repair / vision-review）
```

外部模型控制器角色由 Reasonix 原生子智能体承接（gate-controller、executor-repair、vision-review），
不绑定任何外部模型；视觉类在未配置视觉能力前标注 `READY_PENDING_PROVIDER_CONFIG`，不得伪造真实调用。

## 任务路由

| 任务类型 | Reasonix 落位 | 入口 |
|---------|--------------|------|
| 代码编写/调试/文件编辑 | 主代理直接执行 | 内置工具 |
| Gate Review / Repair Loop / 强指令 / 边界检查 | reasonix-gate-controller / reasonix-executor-repair | `run_skill` / `/gate-review` / `/repair-loop` |
| 截图/图像类证据核验 | reasonix-vision-review（待视觉能力配置） | `run_skill` |
| 只读代码审查 + 安全审计 | reasonix-review-audit | `run_skill` |
| 测试执行与验证 | reasonix-test-verify | `run_skill` |
| 资料研究 | reasonix-research | `run_skill` |
| 轻量任务 | 主代理直接执行（不引入外部模型） | 内置工具 |

## 不可妥协的安全边界

1. 不打印完整 API Key / token / 敏感凭证；报告中仅脱敏片段（前缀 4 位 + 后缀 4 位）。
2. 不修改 Windows 系统/网络/代理；不安装/卸载系统级软件。
3. 不修改其他工具的默认模型配置；不复制、不接入被禁止的宿主配置（含外部宿主目录、其配置文件与路由）。
4. 不保存明文密钥到任何项目配置、技能文件或证据文件。
5. 不把未经验证的视觉/外部能力设为默认执行路径。
6. 项目配置与 `.reasonix` 内不出现外部 API 密钥字面量。
7. 不做用户未明确要求的破坏性操作；有疑问先询问。
8. 只处理授权范围内的工作；不读取、连接、修改或迁移被禁止的系统。

## 证据优先验收（Evidence-First Acceptance）

- `live_call_verified=true` 仅在真实 API/工具调用返回非空内容时设置。
- 证据类型区分：config / report / user_decision / catalog / live_call。
- 不接受纯配置证据作为最终验收。
- 不接受仅脚本输出或文件存在作为最终验收。
- 自动化操作造成用户惊扰时立刻停止并如实报告。

## 上下文规则

- 运行上下文保持轻量；重资料放 `.reasonix/references/`、`.reasonix/registry/`、`.reasonix/reports/`。
- 阶段细节记录在 `.reasonix/reports/` 和 `.reasonix/evidence/`。
- 启动时先读 `.reasonix/ENTRY.md`（轻入口）与最近 handoff 摘要。
- 上下文不足/任务卡住 → 按 `context-fallback-rules.md` 升级处理链（checkpoint → 压缩/收敛 → handoff → 新会话接续），不空转。
