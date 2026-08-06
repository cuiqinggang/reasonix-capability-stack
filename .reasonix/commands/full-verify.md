# Full Verify 命令

## 命令名

`/full-verify [scope]` — 执行完整生态站验证(结构/规则/命令/证据/技能索引/安全扫描 + 四项冒烟)。

## 触发时机

- 生态站部署或大变更后;
- 宣称「完成/上线」之前;
- 周期性健康检查。

## 执行步骤

1. **结构验证**:检查 `.reasonix/` 下必需目录与文件(commands、reports、evidence、state、registry、skills、rules)是否存在。
2. **规则验证**:检查 `.reasonix/rules/` 规则文件全部可读。
3. **命令验证**:检查 `.reasonix/commands/` 命令文件全部可读且格式完整(命令名/触发时机/执行步骤/输入要求/输出证据要求/失败处理)。
4. **证据验证**:检查 `.reasonix/evidence/` 非空,证据清单可生成。
5. **技能索引验证**:检查 `.reasonix/registry/SKILLS_INDEX.md` 存在,且与 `.reasonix/skills/` 实际技能一致。
6. **安全扫描**:对 `.reasonix/` 目录扫描禁止模式(密钥形式、旧配置文件名、旧路径、外部模型路由字样、敏感词),无命中才 PASS。
7. **Gate Review 小型验证**:对一个小目标执行 gate-review。
8. **Repair Loop 模拟验证**:模拟 失败 → 修复 → 回归 流程。
9. **Multi-Agent 冒烟**:至少 2 个只读子智能体真实调用(reasonix-review-audit + reasonix-test-verify)。
10. **Checkpoint/Resume 验证**:写入 checkpoint → 读回 → 校验 → 继续。
11. **汇总判定**:全部 PASS → overall PASS;存在 FAIL → overall PARTIAL 或 FAIL,列出 failed_checks。
12. **产出报告**:`.reasonix/reports/FULL_VERIFY_REPORT.md` + `.reasonix/reports/full-verify-{timestamp}.json`。

## 输入要求

- 无必填参数;可选 `scope`(structure|rules|commands|evidence|index|security|smoke)单跑部分项。

## 输出/证据要求

- 报告:`.reasonix/reports/FULL_VERIFY_REPORT.md`(每项 PASS/FAIL、overall、blockers)。
- 机器可读:`.reasonix/reports/full-verify-{timestamp}.json`(checks 明细 + overall)。
- 各项检查证据保留在 `.reasonix/evidence/`。

## 失败处理

- 任一项 FAIL → 不宣称通过;将该检查转交 repair-loop 修复后重跑 full-verify。
- 安全扫描命中 → 立即标记 FAIL,定位并清除敏感内容后再继续。
- 冒烟项因子智能体不可用而无法执行 → 标记 PARTIAL 并说明,不静默跳过。

---

适配自 Kilo commands/full-verify.md(已验证流程,已剥离模型路由与旧路径)
