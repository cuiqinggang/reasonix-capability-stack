# Reasonix 命令协议索引(适配自 Kilo 成熟技能包)

> 位置:`.reasonix/commands/`
> 说明:10 个命令文件保留 Kilo 已验证流程语义,全部落地为 Reasonix 原生机制:
> 证据 → `.reasonix/evidence/`、checkpoint → `.reasonix/state/checkpoints/`、
> handoff → `.reasonix/state/handoffs/`、路由日志 → `.reasonix/state/routing-log.jsonl`、
> 技能索引 → `.reasonix/registry/SKILLS_INDEX.md`、报告 → `.reasonix/reports/`。
> 不包含任何外部模型路由、模型名、密钥或旧路径;外部控制器角色由 Reasonix 原生的 reasonix-gate-controller 子智能体承接(不绑定任何外部模型)。

## 命令索引

| 命令 | 触发时机(一句话) | 关键输出 |
|------|------------------|----------|
| [gate-review](./gate-review.md) | 任何「完成/通过」声明前,对目标做结构化门禁审查(提取 claims → 收集证据 → 双向评分 → 分类 ACCEPTED/REJECTED/PENDING_EVIDENCE → 出报告) | `.reasonix/reports/gate-review-*.md` |
| [repair-loop](./repair-loop.md) | gate-review REJECTED 或验证失败后,最小修复 → 重提交 → 最多 3 轮 → 人工升级(不改验收标准) | `.reasonix/reports/repair-log-*.json` |
| [multi-agent](./multi-agent.md) | 任务可拆为非重叠子任务时,并行/流水线执行后合并,再送 Gate Review | `.reasonix/reports/multi-agent-*.md` |
| [checkpoint](./checkpoint.md) | 长任务每阶段完成、超时前、上下文溢出前,保存可恢复状态 | `.reasonix/state/checkpoints/CHECKPOINT-*.json` |
| [resume](./resume.md) | 会话中断/换会话后,读摘要 → 读 checkpoint → 验证状态 → 从 completed+1 继续 | 恢复摘要 + 续跑记录 |
| [handoff](./handoff.md) | 阶段结束/换环境/交付前,生成机器可读 JSON + 中文交接摘要 | `.reasonix/state/handoffs/HANDOFF-*.json` + `HANDOFF-SUMMARY.md` |
| [full-verify](./full-verify.md) | 部署/大变更后、宣称完成前,执行结构/规则/命令/证据/技能索引/安全扫描 6 类检查 + 4 项冒烟 | `.reasonix/reports/FULL_VERIFY_REPORT.md` |
| [smart-route](./smart-route.md) | 收到新任务先分流:简单直做 / 中等并行只读 / 复杂走长任务协议 | `.reasonix/state/routing-log.jsonl` |
| [maturity-preflight](./maturity-preflight.md) | 成熟度升级前基线快照(交叉验证A-D + 四分类) | `.reasonix/evidence/maturity-validation/preflight-*.json` |
| [maturity-postflight](./maturity-postflight.md) | 成熟度升级后对比验证(变更清单+评分变化+合规检查) | `.reasonix/evidence/maturity-validation/postflight-*.json` |

## 命令间流转关系

```text
smart-route(入口分流)
  ├─ 简单 → 直接执行
  ├─ 中等 → multi-agent(并行只读) → gate-review
  └─ 复杂 → 长任务协议:todo_write + checkpoint(每阶段) + gate-review(阶段闸门) + handoff(收尾)
maturity-preflight(升级前基线) → maturity-postflight(升级后对比)

gate-review 判定 REJECTED → repair-loop(≤3 轮) → 重提交 gate-review
checkpoint / handoff → resume(从 completed+1 继续)
full-verify(全栈收尾验证,FAIL 项回流 repair-loop)
```

- **smart-route** 是入口分流器;**gate-review** 是质量闸门;**repair-loop** 是被拒项修复回路;**multi-agent** 提供并行执行;**checkpoint/resume/handoff** 支撑长任务承载;**full-verify** 是全栈收尾验证。

## 使用方式

- 直接以 `/命令` 调用;复杂任务先 `/smart-route`,再按路由结果走对应命令。
- 各命令输出统一落位 `.reasonix/` 指定目录,全部使用相对路径。

## 适配来源

10 个文件分别适配自 Kilo commands/ 下同名文件(gate-review / repair-loop / multi-agent / checkpoint / resume / handoff / full-verify / smart-route) + 2 个 Reasonix 原生命令(maturity-preflight / maturity-postflight)。已验证流程语义保留,已剥离模型路由与旧路径。
