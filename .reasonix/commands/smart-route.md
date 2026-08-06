# Smart Route 命令

## 命令名

`/smart-route <任务类型> <任务描述>` — 按复杂度自动分流到 Reasonix 执行机制(不绑定任何外部模型)。

## 触发时机

- 收到新任务时先做分流决策;
- 任务执行方式不确定时;
- 需要在 gate-review / repair-loop / 并行只读 / 长任务协议之间选择时。

## 路由决策树(按复杂度分流到 Reasonix 机制)

```text
任务输入
  ├─ 含 Gate Review / 门禁审查 / 故障修复 / 审计 关键词 → gate-review 或 repair-loop 命令
  ├─ 简单任务(简单查询/分类/少于30字/单文件读取) → 直接执行(当前会话直做)
  ├─ 中等任务(需多视角/交叉验证/代码+安全+测试) → 并行只读(parallel_tasks / read_only_task,只读子智能体)
  ├─ 复杂任务(多阶段/长上下文/30步以上/预计超时) → 长任务协议(todo_write 任务清单 + checkpoint + 阶段 gate-review + handoff 收尾)
  └─ 其他 → 中等并行只读(默认)
```

## 执行步骤

1. **分析任务类型**:手动指定 TaskType 或自动分类(简单 / 中等 / 复杂 / 门禁 / 修复)。
2. **匹配路由决策树**,选择 Reasonix 执行机制。
3. **分流执行**:
   - 简单 → 当前会话直接完成,产出按需进 gate-review;
   - 中等 → 拆分为非重叠子任务,并行只读子智能体执行,合并后 gate-review;
   - 复杂 → 建立 todo_write 任务清单,分阶段执行,每阶段 checkpoint,阶段间 gate-review,结束 handoff。
4. **记录路由日志**:追加一行到 `.reasonix/state/routing-log.jsonl`(字段:task、route、mechanism、status、evidence_paths)。
5. **按机制收尾**:按所选机制走 gate-review / repair-loop / checkpoint / handoff。

## 输入要求

- task_type(可选;缺省自动分类)与 task_description(必填)。
- 复杂任务需先产出阶段拆分与验收标准。

## 输出/证据要求

- 路由日志:`.reasonix/state/routing-log.jsonl`(每任务一行,JSONL 追加)。
- 证据与产物:由所选机制落位 `.reasonix/evidence/`、`.reasonix/reports/`、`.reasonix/state/checkpoints/`。

## 失败处理

- 简单任务执行失败 → 升级为中等(并行只读复核)。
- 中等任务结果冲突无法合并 → 升级为复杂(长任务协议,分阶段重做)。
- 复杂任务某阶段 REJECTED → 转 repair-loop;3 轮后仍失败 → 人工决策。
- 外部能力(如视觉类)未配置 → 不在本命令内降级,记录到 routing-log.jsonl 的 notes 并提示用户配置。

---

适配自 Kilo commands/smart-route.md(已验证流程,已剥离模型路由与旧路径)
