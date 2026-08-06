# /memory propose — 候选记忆提交

> 轻量入口：仅路由说明，完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

任务完成后，将可能有长期价值的内容提交为候选记忆。

## 提交流程

1. 确认任务已完成（有验收证据）
2. 对照准入条件检查（至少满足两项）
3. 对照拒绝条件检查（全部为否）
4. 使用模板 `C:\Users\A\.codex\knowledge-brain\incoming\reasonix-memory-candidates\MEMORY_CANDIDATE_TEMPLATE.md`
5. 写入 `C:\Users\A\.codex\knowledge-brain\incoming\reasonix-memory-candidates\`
6. 文件名格式：`CAND-YYYYMMDD-NNN.md`

## 硬约束

- 每任务最多生成 3 条候选
- 候选池上限 30 条
- 达到 30 条后必须先审核、合并、归档或拒绝，禁止继续累积
- 候选不能直接变成 active
- 候选默认 30 天未审核即 expired

## 准入条件（至少满足两项）

1. 用户明确要求"以后记住"
2. 同类偏好、错误或规则重复出现
3. 有验收报告、测试结果或用户确认
4. 对未来多个任务有长期价值
5. 不记录就很难重新获得
6. 能明确写出适用范围和失效条件

## 拒绝条件（必须全部为否）

- 普通闲聊 / 原始对话全文 / 模型猜测 / 未验证结论
- 临时文件路径 / 一次性草稿 / 重复规则
- 密钥、账号、Cookie、Token
- Hermes 任何内部信息

## 输出格式

```markdown
## 候选记忆提交报告
- 任务ID：[ID]
- 生成候选数：[N]（上限 3）
- 候选清单：
  1. CAND-YYYYMMDD-NNN: [title] — 满足条件：[条件列表]
  2. ...
- 当前候选池用量：[N]/30
- 被拒绝的条目及原因：[如适用]
```
