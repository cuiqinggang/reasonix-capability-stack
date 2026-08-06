# 资产搜索路径架构(Reasonix 4 层模型)

> 用途:防止 AI 会话评估/恢复 Reasonix 生态站时发生搜索范围误判。
> 本文件给出所有权威资产位置与定位;任何会话做成熟度扫描或状态恢复都必须扫全 4 层。
> 全部路径为工作区相对路径(`.reasonix/...`),不引用任何用户绝对路径。

## 架构总览:4 层资产模型

```
Layer 1  工作区入口   →  .reasonix/ 根(rules/、commands/、README/总览)
Layer 2  技能包       →  .reasonix/skills/
Layer 3  索引注册表   →  .reasonix/registry/
Layer 4  证据与状态   →  .reasonix/evidence/ + .reasonix/state/ + .reasonix/reports/
```

**关键规则:成熟度评估/恢复 MUST 扫全 4 层。漏掉任意一层都会导致严重低估或误判。**

## 目录定位总表(`.reasonix/` 下)

| 目录 | 定位 | 内容 | 必搜 |
|------|------|------|------|
| `rules/` | 轻文本规则 | 行为规则、禁止清单、安全边界摘要 | YES |
| `commands/` | 轻入口 | 斜杠命令定义(把能力暴露为轻入口,指向重资料) | YES |
| `registry/` | 索引注册表 | skills-index、references-index、evidence-index 等 | YES |
| `references/` | 重资料库 | 完整协议/模板/清单/陷阱(本目录) | YES |
| `scripts/` | 可复用脚本 | 索引扫描、验证、打包等脚本 | YES |
| `skills/` | 技能包 | 技能包目录(如 reasonix-mature-core) | YES |
| `evidence/` | 证据 | 命令输出、测试结果、日志、截图 | YES |
| `state/` | 运行状态 | checkpoints/、gate-reviews/、repair-loops/ | YES |
| `reports/` | 阶段报告 | 各阶段最终报告 | YES |

## Layer 1:工作区入口

| 路径 | 内容 | 说明 |
|------|------|------|
| `.reasonix/` 根 | 生态站入口、README、总览 | 轻;重细节在 references/ |
| `.reasonix/rules/` | 行为规则、禁止清单、安全摘要 | 轻文本,适合常驻上下文 |
| `.reasonix/commands/` | 斜杠命令 | 轻入口:一条命令指向一个能力 |

原则:入口只放「去哪找」,重资料放 references/。命令与索引不得承载完整协议正文。

## Layer 2:技能包

| 路径 | 内容 | 说明 |
|------|------|------|
| `.reasonix/skills/<name>/SKILL.md` | 技能包主文件(frontmatter: name/description) | 每技能一个包 |
| `.reasonix/skills/<name>/references/` | 技能包内精简参考 | 与生态站 references/ 呼应 |

已知技能包:reasonix-mature-core(六项能力:安全边界、执行与验证、Gate Review、Repair Loop、长任务 checkpoint/handoff/resume、子智能体调度)、reasonix-research、reasonix-review-audit、reasonix-test-verify。

注意:技能包 references/ 是「精简/内嵌」版;生态站 references/ 是「权威完整」版。两者冲突时以生态站 references/ 为准,并回写同步。

## Layer 3:索引注册表

| 路径 | 内容 |
|------|------|
| `.reasonix/registry/skills-index.md` | 技能清单(名称、入口、能力、状态) |
| `.reasonix/registry/references-index.md` | 重资料库文件清单(路径、主题、配套技能) |
| `.reasonix/registry/evidence-index.md` | 证据登记(时间、来源命令、路径) |

规则:

- 任何 references/ 或 skills/ 增删改后必须重跑索引扫描,索引不过期。
- 索引 = 事实的投影,不是事实本身;以磁盘实际为准,索引提供定位。

## Layer 4:证据与状态

| 路径 | 内容 |
|------|------|
| `.reasonix/evidence/` | 证据本体:命令输出、测试结果、日志、截图 |
| `.reasonix/state/checkpoints/` | checkpoint JSON(长任务分段) |
| `.reasonix/state/gate-reviews/` | Gate Review 报告(GATE-<n>.json + md) |
| `.reasonix/state/repair-loops/` | Repair Loop 记录 |
| `.reasonix/reports/` | 阶段报告(按 REPORT-TEMPLATE.md) |

## 4 层搜索协议

任何会话评估或恢复生态站状态时,MUST:

1. 先读本文件,知道全部层与路径。
2. Layer 1:读 `.reasonix/` 根与 rules/、commands/,确认入口与规则。
3. Layer 2:列 `.reasonix/skills/`,核对 SKILL.md 与 frontmatter。
4. Layer 3:读 `registry/` 索引,核对与磁盘一致性(必要时重跑扫描)。
5. Layer 4:检查 evidence/、state/(checkpoints、gate-reviews、repair-loops)、reports/ 的最新状态。
6. 然后才可给出生态站成熟度或状态结论。

**没有扫全 4 层的任何评估结论无效。**

## 写入与冲突规则

- 生态站唯一可写路径为 `.reasonix/` 下(evidence/、state/、reports/、references/ 按任务授权);其余一律只读。
- 写入冲突规避:state 文件写前先读-合并-再写;每文件带任务标识与时间戳;写入动作留证据。
- references/ 与技能包 references/ 同步时,以生态站 references/ 为权威,避免双源漂移。

## 本文件维护

- 更新时机:生态站目录结构、技能包、索引体系发生变化时。
- 更新人:负责资产架构维护的会话;更新后必须重跑索引扫描并同步技能包引用。
