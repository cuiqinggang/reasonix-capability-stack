# Testing Rules — Reasonix 成熟生态站

> 适配自 `cursor-kilo-supertool-mature-stack/references/rules/testing-rules.md`；10 层测试体系与状态标记原样保留。

## 测试原则

1. 小型真实验收优先于大规模假测试。
2. 低成本、小范围验证优于空跑大型项目。
3. 不因大型真实项目未执行而否定整个生态站。

## 测试层级

| 层级 | 说明 | 要求 |
|------|------|------|
| Smoke | 冒烟验证：配置加载、命令可见、入口可运行 | 必须通过 |
| Gate | 门禁审查：结构化结论、双向评分 | 必须通过 |
| Repair | 修复循环：失败→修复→回归检查→停止 | 必须通过 |
| Multi-Agent | 多智能体验证：至少 2 个代理真实调用 | 必须通过 |
| Checkpoint | 断点续跑：写入→读回→继续 | 必须通过 |
| Handoff | 交接：机器可读状态 + 中文摘要 | 必须通过 |
| LongTask | 长文本分段 + checkpoint | 必须通过 |
| Skills | 全部 skills 路径可读、无重复加载 | 必须通过 |
| Security | 敏感信息扫描通过 | 必须通过 |
| Recovery | 从备份完整恢复 | 必须通过 |

## 状态标记

```
CORE_PASS                      — 经当前会话实际验证通过
RESERVE_READY                  — 配置就绪但待外部凭证
CURRENT_REVALIDATION_PENDING   — 历史 PASS，当前未重新验证
BLOCKED_EXTERNAL_DEPENDENCY    — 缺乏外部凭证无法完成
FAIL                           — 验证失败
READY_PENDING_PROVIDER_CONFIG  — 能力已就位，等待 Provider 配置（如视觉模型）
```

## 不测试的内容

- 大型真实项目端到端测试（保留为最终阶段）。
- 需要外部付费凭证的实时 API 调用（标记 RESERVE_READY / READY_PENDING_PROVIDER_CONFIG）。
- 未配置视觉模型时的真实视觉调用（不得伪造成功）。

## Reasonix 落位

- 测试执行：`reasonix-test-verify`（子智能体，执行测试命令 + 收集输出 + 结构化报告）。
- 状态判定：PASS / PASS_WITH_KNOWN_ISSUES / PARTIAL / FAIL，按 `execution-verification.md` 细则。
