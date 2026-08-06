# SOP:Reasonix 生态站标准操作流程

> 完整顺序:启动准备 → 资产定位 → 任务执行 → 验证 → Gate Review → checkpoint → handoff → 修复与恢复 → 资产同步。
> 参考 Kilo SOP.md 的流程结构,已改造成 Reasonix 生态站;不含模型路由与旧工具链内容。

## 1. 启动准备(Preflight)

1. 确认用户意图:要做什么、输出什么、验收标准是什么(标准先定,后看证据)。
2. 读安全边界(`skills/reasonix-mature-core/references/security-boundaries.md`)与最新 checkpoint(`.reasonix/state/checkpoints/`),确认是否续作。
3. 检查索引状态(`.reasonix/registry/`),确认与磁盘一致(必要时重跑索引扫描)。
4. 明确可写范围:生态站唯一可写路径为 `.reasonix/` 下(evidence/、state/、reports/、references/ 按任务授权);其他一律只读。

## 2. 资产定位(4 层搜索)

按 `references/ASSET-SEARCH-PATHS.md` 的 4 层模型:

- Layer 1 工作区入口:`.reasonix/` 根、`rules/`、`commands/`(轻入口/规则)
- Layer 2 技能包:`.reasonix/skills/`(reasonix-mature-core 等)
- Layer 3 索引注册表:`.reasonix/registry/`
- Layer 4 证据与状态:`.reasonix/evidence/` + `.reasonix/state/` + `.reasonix/reports/`

必须扫全 4 层;漏层会导致对生态站状态的严重误判。

## 3. 任务执行

1. 轻入口起手:从命令/索引找到对应能力入口,再进重资料库取完整协议。
2. 重资料取用:需要完整协议时读 `references/` 对应文件,不在活跃上下文堆细节。
3. 长任务分段:步数 ≥ 30 或预计耗时 ≥ 5 分钟 → 分阶段执行,阶段结束写 checkpoint。
4. 子智能体调度:只读审查/测试验证/资料研究分别用对应技能或只读子代理;汇总结果必须过 Gate Review。
5. 证据即时落盘:每步输出写 `.reasonix/evidence/` 并即时引用,不留「补证据」欠账。

## 4. 验证(双向验证)

1. 每个验证周期同时收集成功信号与失败信号。
2. 按加权评分给出 OK / DEGRADED / FAIL(VERIFICATION-LOGIC.md §3)。
3. 排查假失败陷阱(T-01..T-05)与假成功陷阱(S-01..S-08)。
4. 状态标记用词表:周期级 / claim 级 / 验收级,不混用、不自造词。
5. 未收集到证据的声明不得声称通过。

## 5. Gate Review

1. 收集本阶段全部活跃 claim。
2. 逐条对比 claim 与证据(引用格式见 REPORT-TEMPLATE.md)。
3. 按双向加权评分分类:ACCEPTED / REJECTED / PENDING_EVIDENCE。
4. 产出 Gate Review 报告,写入 `.reasonix/state/gate-reviews/GATE-<n>.json` 与 Markdown 版。
5. REJECTED 全部进 Repair Loop;存在未解决 REJECTED → verdict=BLOCKED,不得 PASS。

## 6. checkpoint

1. 每个阶段完成立即写 checkpoint 到 `.reasonix/state/checkpoints/`。
2. 字段:`task_name / stage / completed_steps / next_step / timestamp / integrity / evidence_paths / pending_decisions`。
3. `integrity` 必须真实(写完读回验证);`completed_steps` 与 `next_step` 严格一致。
4. 用 `todo_write` 维护任务清单,一个阶段 = 一个 todo 项。

## 7. handoff

1. 生成机器可读 `handoff.json`(checkpoint 全字段 + pending_decisions + 恢复命令)。
2. 生成中文摘要 `HANDOFF-SUMMARY.md`:当前状态 / 已完成 / 待办 / 恢复步骤(3-5 步)。
3. 引用证据路径,不复制大体积产物。

## 8. 修复与恢复

1. 被拒 claim 走 Repair Loop:识别缺口 → 最小修复 → 回归确认 → 重新提交 →(同一 claim 超 3 轮)升级人工决策。
2. 绝不为了迎合证据修改验收标准。
3. resume:读 HANDOFF-SUMMARY.md → 读 checkpoint(核对 next_step 与 integrity)→ 验证关键文件在位 → 从「最后已完成 + 1」继续,禁止跳步与重跑已完成步骤。

## 9. 资产同步(每次阶段收尾)

1. references/ 变更写入 `.reasonix/references/`(重资料库),如必要同步技能包内精简版。
2. registry/ 索引重跑扫描,与磁盘一致。
3. evidence/ 新增证据登记。
4. state/ 更新 checkpoint、gate-review、repair-loop。
5. reports/ 写入阶段报告。
6. handoff 摘要更新。

## 10. 禁止清单

- 不引用任何旧绝对路径(如带盘符的 Windows 用户路径)。
- 不打印、不修改完整密钥/凭证。
- 不修改系统/网络/代理配置;不安装/卸载/重装 IDE 或运行时。
- 不改动其他工具/技能默认配置。
- 不做未授权破坏性操作;有疑问先询问。
- 不继续用户已表示意外的自动化。
- 不把「配置存在」当「验证通过」。
- 存在未解决拒绝项时,不声明 PASS。
