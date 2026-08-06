# 第二期 A — 候选记忆审核流水线部署报告

> 报告时间：2026-08-06 06:09 | 文件名：phase-2a-memory-gate-pipeline-20260806-0609.md

---

## 一、第二期 A 状态

**PASS** ✅

---

## 二、实际耗时

约 **22 分钟**（目标 50 分钟，硬上限 60 分钟，在时限内完成）

---

## 三、实际子智能体数量

**4 个**，并行启动：

| 子智能体 | 角色 | 产出 |
|---------|------|------|
| S1 | 候选与去重审查设计者 | capture + dedupe 命令完整设计 |
| S2 | 冲突与证据审查设计者 | conflict + evidence 命令完整设计 |
| S3 | Gate 与激活流程设计者 | gate + activate + trial-status 命令完整设计 |
| S4 | 安全与反膨胀审查者 | 安全报告 + 路径退役确认 + 字段完整性核验 |

---

## 四、流水线命令清单

### 新增 7 个命令

| # | 命令 | 文件 | 职责 |
|---|------|------|------|
| 1 | `/memory capture` | `capture.md` | 真实任务完成后提取最多 3 条候选记忆（6 项准入 + 9 项拒绝检查） |
| 2 | `/memory dedupe` | `dedupe.md` | 四维去重比对（标题/语义/scope/type），6 级重复判定 |
| 3 | `/memory conflict` | `conflict.md` | 三向冲突检查（vs active 记忆 / vs 用户指令 / vs CORE_MEMORY） |
| 4 | `/memory evidence` | `evidence.md` | 四项证据验证（任务ID/证据路径/来源/未来价值） |
| 5 | `/memory gate` | `gate.md` | 串联 capture→dedupe→conflict→evidence，输出 APPROVE_FOR_USER_REVIEW / REJECT / DEFER |
| 6 | `/memory activate` | `activate.md` | 安全激活（6 项硬前置条件 + 用户确认 + 最终冲突检查），每任务最多 1 条，子智能体绝对禁止 |
| 7 | `/memory trial-status` | `trial-status.md` | 试运行仪表盘（3 任务进度 + 候选统计 + 反膨胀状态） |

### 已有命令（保留）

| # | 命令 | 说明 |
|---|------|------|
| — | `/memory recall` | 检索相关记忆（不变） |
| — | `/memory propose` | 旧提交入口（保留，capture 是更严格的替代） |
| — | `/memory review` | 旧审核入口（保留，gate 是更细化的替代） |
| — | `/memory health` | 健康检查（不变） |

### 路由表更新

`reasonix-memory-routing.md` 已更新：
- 第三节命令入口表新增 7 行
- 第六节路径速查表新增 7 行

---

## 五、三项真实任务进度

**0/3**

试运行尚未开始。等待用户在第二期部署后发起真实任务。

三个任务名额保留条件：
- 必须是第二期部署后的新任务
- 真实项目/真实配置/真实分析/真实交付
- 有可验证结果
- 已完成且有确认证据
- 任务本身产生可长期复用经验

排除项：闲聊、简单改写、模拟题、历史回填、无验收草稿、纯测试夹具、为制造记忆设计的伪任务。

---

## 六、当前 active 新增数

**0**

试运行阶段禁止自动激活。

---

## 七、当前 candidate 数

**0**

候选池为空，等待第一个真实任务产生候选。

---

## 八、验证结果（10 项）

| # | 验证项 | 结果 |
|---|--------|:--:|
| V1 | 11 个 memory 命令文件存在 | ✅ PASS |
| V2 | 全部命令指向 `C:\Users\A\.codex\knowledge-brain` | ✅ PASS |
| V3 | activate.md 要求用户明确确认 | ✅ PASS |
| V4 | capture.md 每任务上限 3 条 | ✅ PASS |
| V5 | dedupe.md 覆盖 4 级重复判定 | ✅ PASS |
| V6 | gate.md 串联全部 4 项检查 | ✅ PASS |
| V7 | trial-status.md 初始显示 0/3 | ✅ PASS |
| V8 | 新文件无 Key/Token/.env 泄露（Hermes 仅作为禁止项出现） | ✅ PASS |
| V9 | 不存在自动激活行为（"不得自动激活"禁令在位） | ✅ PASS |
| V10 | 候选池 30 条上限在 capture/gate/trial-status 中引用 | ✅ PASS |

---

## 九、审核流水线总览

```
任务完成
    │
    ▼
/memory capture    → 提取候选（6准入 + 9拒绝，≤3条）
    │
    ▼
/memory dedupe     → 去重（4维 × 6级判定）
    │
    ▼
/memory conflict   → 冲突（A:active B:user C:core）
    │
    ▼
/memory evidence   → 证据（taskID + path + source + 未来价值）
    │
    ▼
/memory gate       → 汇总 → APPROVE_FOR_USER_REVIEW / REJECT / DEFER
    │
    ▼ (仅 APPROVE)
用户确认
    │
    ▼
/memory activate   → candidate → active（≤1条/任务）
    │
    ▼
/memory trial-status  → 全程监控
```

---

## 十、反膨胀规则在位确认

| 规则 | 上限 | 来源 |
|------|------|------|
| 每任务 candidate | ≤ 3 条 | capture.md |
| 候选池总量 | ≤ 30 条 | capture.md + gate.md + trial-status.md |
| 每任务 active 新增 | ≤ 1 条（试运行 = 0） | activate.md |
| 核心摘要 | ≤ 1,200 中文字符 | MEMORY_GOVERNANCE.md |
| 单任务检索 | ≤ 5 条 | recall.md |
| 子智能体激活 | 绝对禁止 | activate.md |

---

## 十一、明确声明

- ✅ 未接触 Hermes
- ✅ 未读取或暴露密钥
- ✅ 未调用付费模型
- ✅ 未安装依赖
- ✅ 未删除/移动/修改任何已有文件
- ✅ 未导入历史聊天、报告或旧任务内容
- ✅ 未自动把 candidate 变为 active
- ✅ 未自动修改技能、规则或脚本
- ✅ `C:\AI\knowledge-brain` 零活跃引用（仅路由文件第 78 行作为退役声明出现）

---

## 十二、第二期 B 的启动条件

第二期 B（试运行验收）只能在以下条件全部满足后启动：

1. 三项真实任务全部完成（3/3）
2. 每项任务有明确验收证据
3. 候选池中有至少 1 条通过完整 Gate 流程的候选
4. 准确率、重复率和膨胀率数据可供复盘
5. 用户明确授权启动第二期 B

当前不可启动：真实任务进度 0/3。

---

> END OF REPORT
