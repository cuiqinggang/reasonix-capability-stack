# Maturity Postflight 命令

## 命令名

`/maturity:postflight` — 成熟度后检：在成熟度升级任务完成后运行，对比 preflight 基线，验证变更合规性与成熟度提升。

## 触发时机

- 成熟度升级任务的**完成后**（生成最终评估）；
- 任何对 `.reasonix/` 目录的批量修改后；
- 作为最终审计的前置步骤。

## 执行步骤

1. **读取 preflight 基线**：
   - 定位最近一次 `.reasonix/evidence/maturity-validation/preflight-*.json`
   - 若无基线，标记 `NO_BASELINE`，仍执行当前快照检查

2. **重新执行当前快照**（同 preflight 步骤 2-6）：
   - 交叉验证 A：技能与磁盘一致性
   - 交叉验证 B：命令完整性
   - 交叉验证 C：能力矩阵状态 vs 证据
   - 交叉验证 D：目录契约 vs 实际目录
   - 状态四分类输出

3. **对比变更**（有基线时）：
   - 逐项对比 preflight 基线 vs 当前快照
   - 列出状态升级项（如 STRUCTURE_ONLY → PASS_REAL）
   - 列出状态降级项（如 PASS → FAIL）
   - 列出新增/消失的文件
   - 验证：变更是否仅发生在 `.reasonix/` 内

4. **合规性检查**：
   - 确认无文件被删除（除非显式允许）
   - 确认无 `.reasonix/` 外写入
   - 确认无密钥/凭据暴露
   - 确认能力声明未被夸大（STRUCTURE_ONLY 不能写成 PASS_REAL）

5. **成熟度评分**：
   - 基于四分类状态计算评分（PASS_REAL=10, STRUCTURE_ONLY=6, FAIL=0, PENDING=3）
   - 输出：执行前评分 vs 执行后评分

6. **生成 postflight 报告**：
   - 写入 `.reasonix/evidence/maturity-validation/postflight-{timestamp}.json`
   - 包含：基线时间戳、当前快照、变更清单、评分变化、合规结论

## 输入要求

- 无必填参数。可选 `--baseline <path>` 指定特定 preflight 文件。

## 输出/证据要求

- 报告：`.reasonix/evidence/maturity-validation/postflight-{timestamp}.json`
- 控制台输出：变更摘要（N 项升级 / M 项降级 / 评分变化）
- 与 `/maturity:preflight` 配对使用

## 失败处理

- 无基线 → 标记 NO_BASELINE，仍输出当前快照
- 状态降级 → 标记 REGRESSION，列出降级项
- 合规失败 → 标记 COMPLIANCE_FAIL，阻塞最终 PASS
- 能力夸大 → 标记 OVERCLAIM，自动降级对应状态

## 安全约束

- 不读取 `.env`、`.create_token`、任何 Key 或凭据
- 不调用任何模型
- 不修改非 `.reasonix/` 文件
- 不访问 Hermes 或任何外部宿主系统

---

Reasonix 原生，2026-08-06 成熟度升级阶段2创建。
