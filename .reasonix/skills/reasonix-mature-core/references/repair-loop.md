# Repair Loop 完整协议

来源：`cursor-kilo-supertool-mature-stack/SKILL.md`（Repair Loop 工作流）+ `references/VERIFICATION-LOGIC.md`（验收规则）。

## 触发条件

- Gate Review 中被 REJECTED 的 claim。
- 验证失败（双向评分 <= 0 或出现新失败）。

## 流程（5 步，每 claim 最多 3 轮）

1. **识别缺口**：定位被拒 claim 与其证据缺口 / 故障根因。
2. **最小修复**：只做最小改动 —— 重跑验证、补证据、修配置；不扩大改动面。
3. **回归确认**：修复后重新执行相关验证，确认无回归。
4. **重新提交**：把修复结果重新提交 Gate Review。
5. **升级**：同一 claim 超过 3 轮仍未通过 → 停止并升级为人工决策（报告给用户，说明尝试与失败原因）。

## 铁律

- **绝不改变验收标准来迎合证据。**
- 每个修复轮次都要有证据记录（命令输出、diff、测试结果）。
- 修复失败如实报告，不得以"修好了"掩盖。

## 输出格式（JSON）

```json
{
  "claim_id": "C-01",
  "rounds": [
    {"round": 1, "root_cause": "...", "fix": "...", "verification": "...", "result": "FAIL|PASS"}
  ],
  "final_status": "RESOLVED|ESCALATED",
  "escalated_to": "human"
}
```

## 落地方式（Reasonix）

- 修复记录写入 `.reasonix/state/repair-loops/`。
- 升级人工决策时用 ask 工具，或明确报告阻塞原因。
