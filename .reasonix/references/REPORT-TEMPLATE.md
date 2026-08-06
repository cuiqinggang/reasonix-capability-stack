# 生态站阶段报告模板

> 用法:每完成一个阶段,按本模板产出报告,存 `.reasonix/reports/`。
> 模板语义参考 Kilo REPORT-TEMPLATE.md,已改造成 Reasonix 生态站适用。
> 配套:`VERIFICATION-LOGIC.md`(三级状态标记)、`FAILURE-MODES.md`(known_failures 依据)、`long-task-checkpoint-handoff.md`(handoff)。

## 证据引用格式(先读)

报告内所有证据用统一引用格式,必须可独立复查:

| 证据类型 | 格式 | 示例 |
|----------|------|------|
| 文档证据 | `<相对路径>:<行号>` | `references/ASSET-SEARCH-PATHS.md:41` |
| 命令证据 | `$ <命令>` + 结果摘要 | `$ grep -n "CYCLE-07" state/checkpoints/` → 1 处命中 |
| 测试证据 | 命令 + 通过/失败/错误/跳过 + 断言数 + 耗时 | `$ go test ./...` → ok,12 断言,3.2s |
| 状态证据 | 状态标记词表内的显式值 | `status: PASS_WITH_KNOWN_ISSUES` |

规则:

- 证据路径一律工作区相对路径,禁止旧绝对路径。
- 命令必须是实际运行过的;不写计划中的命令。
- 声明类型区分:`active_config_confirmed` / `local_report_confirmed` / `user_decision_confirmed` / `live_call_verified`(仅真实调用返回非空结果才可置 true)。

## 模板

```markdown
# <阶段名> 报告

- 生成时间:<ISO8601>
- 最终结论:<EXACT_STATUS>(PASS / PARTIAL / FAIL / PASS_WITH_KNOWN_ISSUES)
- Gate Review:<verdict>(PASS / BLOCKED),见 `.reasonix/state/gate-reviews/GATE-<n>.json`

## 范围

本阶段做什么、不做什么。

## 现有状态

- 工作区结构:<`.reasonix/` 下各目录现状>
- 索引状态:<registry 扫描时间、与磁盘是否一致>
- 技能包:<涉及技能包与状态>
- 检查点:<最近 checkpoint 时间与 stage>

## 行动(仅事实,不是计划)

- 动作 1:<做了什么 + 证据引用>
- 动作 2:<做了什么 + 证据引用>

## 证据

- 报告:`reports/<file>.md`
- 日志:`evidence/<file>.log`
- 命令输出:`evidence/<file>.txt`(附运行命令)
- 测试结果:`evidence/<file>.json`
- 截图/文件快照:`evidence/<file>.png`(若有)

## 验证

- 验证轮次:
  - Round 1:<命令 / 状态标记 / 评分>
  - Round 2:<...>
- 已知失败:known_failures 清单(每条须对应 FAILURE-MODES.md 条目)
- Caveats / 未做项:如实列出

## Gate Review 摘要

- 活跃 claim 数:<n>
- ACCEPTED / REJECTED / PENDING_EVIDENCE:<a> / <b> / <c>
- Repair Loop 轮次:<n 轮 / 已解决 / 已升级>
- 未解决阻塞:<是/否>

## 安全

- 完整密钥/凭证打印:NO
- 完整密钥/凭证修改:NO
- 系统/网络/代理配置修改:NO
- IDE 或运行时安装/卸载:NO
- 其他工具默认配置修改:NO
- 破坏性操作(未授权):NO
- 额外工具安装:NO

## 下一步

- 阶段名:
- 理由:
- 恢复入口:最近 checkpoint 路径

## 资产同步

- references/ 变更:已更新(列出变更文件)
- registry 索引:已重跑扫描
- evidence/ 新增:<列表>
- state/ 更新:<checkpoint / gate-review / repair-loop>
- handoff 摘要:已更新
```
