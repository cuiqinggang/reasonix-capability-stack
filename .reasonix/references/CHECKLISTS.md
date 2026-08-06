# 生态站运维检查清单

> 用法:在对应阶段开始前逐条核对;勾选后如在验证中发现不符,回改并记录。
> 配套:`VERIFICATION-LOGIC.md`(验证逻辑)、`FAILURE-MODES.md`(陷阱)、`long-task-checkpoint-handoff.md`(handoff)。
> 语义参考 Kilo CHECKLISTS.md,已全部改造成 Reasonix 生态站适用,不含旧工具链内容。

## 一、部署前检查清单

(生态站首次建立 / 新增技能包 / 重资料库落位)

- [ ] 目录结构就位:`rules/ commands/ registry/ references/ scripts/ skills/ evidence/ state/ reports/`(均在 `.reasonix/` 下)
- [ ] `references/` 重资料文件存在且非空,与技能包内精简版呼应
- [ ] `registry/` 索引与实际文件一一对应(可重跑索引扫描核对)
- [ ] 每个技能包有 `SKILL.md`,frontmatter 的 name/description 完整
- [ ] 轻入口(命令、索引)指向的重资料路径真实有效
- [ ] 全文未引用任何旧绝对路径(如带盘符的 Windows 用户路径)
- [ ] 无明文密钥/凭证写入任何配置文件或技能文件
- [ ] 迁移场景下:迁移报告与清单(manifest)存在
- [ ] 一致性校验:索引扫描结果 = 磁盘实际文件

## 二、迁移后检查清单

(从旧资料库 / 旧技能包迁移之后)

- [ ] 旧资料全部迁移,源位置无残留(或已明确归档标记)
- [ ] 文件内相对路径改写为工作区相对路径(`.reasonix/...`)
- [ ] 重跑索引扫描,注册表已指向新路径
- [ ] 技能包引用的 references 文件逐个可打开
- [ ] 报告与证据路径引用已重定向
- [ ] 迁移后 smoke:实际读一个重资料文件 + 实际跑一个入口命令
- [ ] checkpoint/状态文件时间戳与内容一致,无「迁移前的旧状态混入」

## 三、验证前检查清单

(运行双向验证之前)

- [ ] 已列出本阶段全部活跃 claim,并给每条 claim 指定证据路径
- [ ] 确认成功信号的收集方法存在(不只是搜异常字符串)
- [ ] 确认测试含真实断言(非 always-pass)
- [ ] mock 已隔离或被显式标记,验证目标走真实执行
- [ ] 已定义「输出有效」的内容断言(文件存在 ≠ 内容正确)
- [ ] 状态标记词表已统一(三级:OK/DEGRADED/FAIL、ACCEPTED/REJECTED/PENDING_EVIDENCE、PASS/PARTIAL/FAIL/PASS_WITH_KNOWN_ISSUES)
- [ ] 确认不会把「未知」当 FAIL
- [ ] 验证命令只读,或写入已授权路径(`.reasonix/evidence/`、`.reasonix/state/`)

## 四、打包前检查清单

(生成阶段报告 / 交付物之前)

- [ ] 报告存在且最终结论显式(EXACT_STATUS)
- [ ] 报告引用的每条证据文件真实存在、可复查
- [ ] 压缩/打包产物含真实文件,不是「仅目录」
- [ ] 已排除缓存、临时文件、日志垃圾、大体积中间产物
- [ ] 密钥/凭证扫描通过(无明文落盘)
- [ ] 产物内含 README/清单,说明包内内容与验证状态
- [ ] 产物路径在最终答复中给出
- [ ] 大体积证据只引用路径,不重复复制

## 五、安全检查清单

- [ ] 未打印、未修改任何完整密钥/凭证(展示仅脱敏片段)
- [ ] 未修改系统/网络/代理配置
- [ ] 未安装、卸载、重装 IDE 或运行时
- [ ] 未改动其他工具/技能的默认配置
- [ ] 未做用户未明确要求的破坏性操作(卸载/回滚/删除备份)
- [ ] 未继续用户已表示意外的自动化(改用文件/CLI 证据或先征得同意)
- [ ] 无明文密钥落盘(配置/技能/checkpoint)
- [ ] 只处理授权范围内内容;检测到「静默替换/漂移」标记并升级,不自行绕过

## 六、验证逻辑检查清单

(呼应 VERIFICATION-LOGIC.md)

- [ ] 成功信号已计算
- [ ] 失败信号已计算
- [ ] 加权/平衡状态已使用(未用非黑即白)
- [ ] 未知未自动判 FAIL
- [ ] 假成功陷阱已排查(mock/缓存/无断言/配置-only/空内容)
- [ ] 假失败陷阱已排查(stderr 误读/超时/截断)
- [ ] 被拒 claim 已进入 Repair Loop 或显式列为阻塞
- [ ] 存在未解决拒绝项时未声明 PASS

## 七、handoff 检查清单

(呼应 long-task-checkpoint-handoff)

- [ ] checkpoint JSON 已写入 `.reasonix/state/checkpoints/`
- [ ] `integrity` 字段真实(写后可读回验证)
- [ ] `completed_steps` 与 `next_step` 严格一致
- [ ] HANDOFF-SUMMARY.md 已更新(当前状态/已完成/待办/恢复步骤)
- [ ] 恢复步骤为 3-5 步,明确下一步动作
- [ ] 证据路径引用已写入 handoff
