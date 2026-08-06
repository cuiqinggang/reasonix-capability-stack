# Context Fallback Rules — Reasonix 成熟生态站

> 适配自 `cursor-kilo-supertool-mature-stack/references/rules/context-fallback-rules.md`。
> 原模型的升级链（DeepSeek Flash→Pro→compact→handoff）在 Reasonix 中映射为「上下文管理升级链」：
> 收敛上下文 → checkpoint → handoff → 新会话接续。不涉及任何外部模型路由或模型名。

## 核心原则

**用户任务优先于模型便利。** 任何情况下不得因上下文不足、输出截断或推理卡住而停止推进用户任务。

## 上下文升级链（Reasonix 原生）

| 当前状态 | 问题表现 | 升级动作 |
|----------|----------|----------|
| 普通会话 | 上下文占用升高、频繁截断 | 收敛：合并冗余工具输出、压缩长报告引用、保留结论性摘要 |
| 收敛后仍不足 | 仍无法推进 | 写入 checkpoint + handoff → **新会话接续**（fresh context） |
| 子智能体输出过长 | 主上下文被撑爆 | 用 `read_subagent_result` 分页读取，仅保留结论；大段证据留在文件 |
| 视觉类任务 | 未配置视觉能力 | 标记 `READY_PENDING_PROVIDER_CONFIG`，不伪造调用 |

## 切换/升级依据（满足 2 项以上才动作）

1. 连续 2 次输出被截断或返空。
2. 错误信息包含 `context_length_exceeded` / `token limit` / `max_tokens`。
3. 同一任务在相同条件下超时超过 120 秒。
4. 上下文占用超过当前可感知容量的 80%。

## 升级操作（Reasonix 版本）

```
1. 写入当前 checkpoint + 更新 HANDOFF-SUMMARY.md
2. 记录切换原因到 .reasonix/state/routing-log.jsonl
3. 收敛/压缩上下文（合并输出、去重、摘要化）
4. 若仍不可行 → 新会话，先 /resume 读 checkpoint 继续
```

## 禁止行为

- ❌ 任务卡住时等待/空转。
- ❌ 不记录原因就切换/收敛。
- ❌ 不写 checkpoint 就切换（可能导致丢失进度）。
- ❌ 把视觉/重负载能力用于纯文本任务（浪费能力、引入外部依赖）。

## 压缩触发规则（Reasonix 适配）

| 占用感知 | 动作 |
|-----------|------|
| 低 | 正常继续 |
| 中（60%–70%） | 整理 checkpoint + 准备收敛 |
| 高（≥70%） | 等待原子命令结束 → 写 checkpoint → 收敛上下文 |
| 很高（≥85%）或收敛失败 | 停止扩展 → handoff → 新会话接续 |

**收敛必须可验证**：收敛后上下文占用应显著下降；若下降 < 30%，标记 `COMPACT_DEGRADED` 并升级为 handoff + 新会话。
