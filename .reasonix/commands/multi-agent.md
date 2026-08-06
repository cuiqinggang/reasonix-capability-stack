# Multi-Agent 命令

## 命令名

`/multi-agent <任务>` — 将任务拆分为非重叠子任务,并行或流水线执行,合并结果后送 Gate Review。

## 触发时机

- 任务可拆分为两个及以上互不依赖的子任务时;
- 需要多视角验证(审查 + 安全 + 测试 + 研究)时;
- smart-route 判定为中等复杂度的任务。

## 可用子智能体(Reasonix 原生,不绑定任何外部模型)

| 子智能体 | 角色 | 职责 | 入口 |
|----------|------|------|------|
| reasonix-review-audit | 代码审查 / 安全审计 | 评审代码质量、安全性、硬编码密钥与敏感路径 | `run_skill` 或只读子代理 |
| reasonix-test-verify | 测试验证 | 执行测试命令、收集输出、验证结果 | `run_skill` 或子代理 |
| reasonix-research | 研究探索 | 跨文件搜索、引用追踪、信息收集 | `run_skill` 或只读子代理 |
| reasonix-gate-controller | 关卡控制 | 汇总各子代理结果做门禁审查 | 见 gate-review 命令 |

父级(当前会话)负责拆分、派发与合并,不依赖任何外部编排器。

## 执行模式

- **并行模式**:多个独立只读子智能体同时启动,各自完成后返回结构化结果。
- **流水线模式**:按顺序执行,前一代理输出作为后一代理输入:reasonix-research → 收集上下文 → reasonix-review-audit → 审查代码 → 安全审计 → reasonix-test-verify → 验证最终结果。

## 执行步骤

1. **拆分**:将任务拆为职责互不覆盖的非重叠子任务(每项含子智能体、职责、输入、证据输出路径)。
2. **并行执行**:只读类子任务用 Reasonix 并行只读机制(如 parallel_tasks / read_only_task)同时派发;需写文件的执行类子任务用受限子代理并按需授权。
3. **收集结果**:各子代理返回结构化结果,证据写入 `.reasonix/evidence/<agent>-{timestamp}.json`。
4. **合并**:父级合并各子任务结果,消解冲突,生成合并产物。
5. **Gate Review**:对合并结果执行 gate-review,产出总体判定 ACCEPTED / REJECTED / PENDING_EVIDENCE。
6. **输出**:合并报告写入 `.reasonix/reports/multi-agent-{timestamp}.md`。

## 输入要求

- 任务描述与目标。
- 子任务拆分清单(非重叠;每项含子智能体、职责、输入、证据输出路径)。
- 至少 2 个只读子智能体参与(推荐 reasonix-review-audit + reasonix-test-verify 或 reasonix-research)。

## 输出/证据要求

- 合并报告:`.reasonix/reports/multi-agent-{timestamp}.md`。
- 每个子任务至少一个非空证据文件:`.reasonix/evidence/<agent>-{timestamp}.json`。
- 总体判定:ACCEPTED / PARTIAL / FAIL(经 gate-review 校准)。

## 失败处理

- 单个子代理失败 → 单独重试或重新派发,不阻塞其他子任务。
- 多个子代理失败或结果冲突无法合并 → 标记 PARTIAL,回退 smart-route 走长任务协议,并记录到 `.reasonix/state/routing-log.jsonl`。
- 任一子任务证据为空 → 判定 PARTIAL,补齐证据后重跑 gate-review。

---

适配自 Kilo commands/multi-agent.md(已验证流程,已剥离模型路由与旧路径)
