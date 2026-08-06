# Gate Review 命令

## 命令名

`/gate-review <目标>` — 对指定目标(文件/报告/产物/任务声明)执行结构化门禁审查。

## 触发时机

- 任何「完成/通过/上线」声明之前必须执行;
- 阶段交付物产出后、报告发布前;
- 由 multi-agent 合并结果、repair-loop 回归验证或 full-verify 冒烟环节调用。

## 执行步骤

1. **读取目标**:确定审查对象(文件/报告/产物路径,相对路径)。
2. **提取 claims**:逐条列出目标中的声称项(声称完成了什么、实现了什么、验证了什么)。
3. **收集证据**:对每条 claim 到 `.reasonix/evidence/` 及目标产物中寻找可核验证据;必要时调用证据收集流程更新 `.reasonix/evidence/evidence-manifest.json`。
4. **双向评分**:
   - 成功信号:execution_real(+3) routing_correct(+2) tool_invoked(+2) output_generated(+3)
   - 失败信号:mock_detected(-4) missing_execution(-5) routing_bypass(-5)
5. **逐条分类**:每条 claim 标记 `ACCEPTED` / `REJECTED` / `PENDING_EVIDENCE`。
6. **汇总判定**:
   - 全部 claim 为 ACCEPTED 且总分 >=5 → 总体 `ACCEPTED`;
   - 存在 PENDING_EVIDENCE 或证据不足 → 总体 `PENDING_EVIDENCE`(不通过,补证据后重评);
   - 存在 REJECTED claim 或总分 <=0 → 总体 `REJECTED`(不通过)。
7. **产出报告**:写入 `.reasonix/reports/gate-review-{timestamp}.md`(含 claims 表、证据路径、总体判定、未决阻塞项),同时写机器可读 JSON 版本。
8. **REJECTED 处理**:将失败项转交 repair-loop 命令,在修复完成前阻塞 PASS。

## 输入要求

- `review_target`:目标路径或名称(必填)。
- 活跃 claims:从目标中提取的声称项列表。
- 证据来源:`.reasonix/evidence/` 下的证据文件;缺失时对应 claim 标记 PENDING_EVIDENCE。

## 输出/证据要求

- 审查报告:`.reasonix/reports/gate-review-{timestamp}.md`(+ 同名 `.json`)。
- 每条 claim 附证据路径(相对路径,指向 `.reasonix/evidence/` 或产物文件)。
- 审查过程不修改被审查文件。

## 失败处理

- 证据缺失 → 标记 PENDING_EVIDENCE,不判定通过;可经 repair-loop 补齐证据后重评。
- 总体 REJECTED → 转交 repair-loop;3 轮后仍 REJECTED → 升级人工决策。
- 审查中发现密钥/凭据泄露或敏感内容 → 立即标记 REJECTED 并提示清除,不写入报告正文。

---

适配自 Kilo commands/gate-review.md(已验证流程,已剥离模型路由与旧路径)
