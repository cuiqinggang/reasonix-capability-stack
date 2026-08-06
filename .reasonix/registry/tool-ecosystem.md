# Reasonix 工具生态资料

> 生成时间:2026-08-03T23:40+08:00
> 维护方:Reasonix 生态站 · 技能索引与工具生态写入智能体
> 配套文件:`tool-registry.json`(机器可读注册表)、`SKILLS_INDEX.md`(技能索引)
> 说明:本文档描述 Reasonix 内置审查/测试/研究/并行/命令类工具的定位与选择指引;全部为 Reasonix 原生能力,不涉及外部模型配置或任何密钥配置。

---

## 一、生态分层总览

Reasonix 工具生态分三层,选择工具时按「内置优先 → 技能增强 → 外部生态」递进:

| 层级 | 内容 | 用途 |
|------|------|------|
| L1 · Reasonix 内置 | `review` / `security_review` / `test` / `explore` / `research` / `task` / `parallel_tasks` / `fleet` / `web_fetch` / `bash` / `todo_write` / `slash_command` / `run_skill` | 日常开发、审查、测试、研究、并行调度的直接入口 |
| L2 · 原生技能 | `reasonix-mature-core`、`reasonix-review-audit`、`reasonix-test-verify`、`reasonix-research`、`reasonix-gate-controller`、`reasonix-executor-repair`、`reasonix-vision-review` | 可组合的成熟工作流(审查/测试/研究/关卡/修复/视觉) |
| L3 · 用户技能生态 | baoyu 系列(内容创作与发布)、firecrawl 系列(网页抓取与研究)、hyperframes 系列(视频与动效)、workflow 系列(规划/执行/验证)、design 系列(UI/UX/Figma) | 面向具体场景的能力扩展,经 `/命令` 或 `run_skill` 调用 |

---

## 二、审查类工具(review / security_review)

### review — 代码审查

- **定位**:通用只读代码质量审查,检查正确性、安全性、性能、可维护性、兼容性。
- **入口**:内置工具 `review`(也可经 `reasonix-review-audit` 技能获得完整 JSON 结论)。
- **适用**:提交前自查、需求完成后验收前、合并前把关。
- **选择指引**:
  - 需要标准五维检查 → `review` 或 `reasonix-review-audit`(模式 `review`)。
  - 需要安全专项(密钥/权限/依赖/泄露)→ `security_review` 或 `reasonix-review-audit`(模式 `audit`)。
  - 两者都要 → `reasonix-review-audit`(模式 `review+audit`)。
  - 需要视觉类证据核验(截图/图像)→ `reasonix-vision-review`。

### security_review — 安全审计

- **定位**:只读安全审计,检测硬编码密钥、敏感路径、不安全配置、依赖漏洞、数据泄露风险。
- **入口**:内置工具 `security_review`(斜杠 `/security-review`)。
- **输出**:按严重度分级的 findings 清单 + 结论(PASS / WARNING / FAIL),密钥仅显示脱敏片段。

### 审查类原则

1. 全程只读,不修改任何文件。
2. 证据优先:发现必须给出行列号或路径引用;不确定项标 `UNVERIFIED`。
3. 审查结论须过 Gate Review 验收,被拒 claim 进入 Repair Loop。

---

## 三、测试类工具(test / reasonix-test-verify)

- **定位**:执行测试命令、收集输出、分析结果,输出结构化测试报告(PASS / PASS_WITH_KNOWN_ISSUES / PARTIAL / FAIL)。
- **入口**:内置 `/test`(测试流程)或 `reasonix-test-verify` 技能(子智能体独立执行)。
- **支持范围**:unit / integration / smoke;命令如 `npm test`、`pytest`、`go test ./...`、`node --test`。
- **报告要素**:命令、通过/失败/错误/跳过数、耗时、失败项明细(含 `is_known_failure`)。

### 选择指引

| 场景 | 工具 |
|------|------|
| 快速跑测试并看结果 | `/test` |
| 需要独立子智能体做深度验证、产出完整 JSON 报告 | `run_skill: reasonix-test-verify` |
| 测试驱动开发(先写测试再实现) | `/test-driven-development` |
| 修复后回归验证 | `run_skill: reasonix-test-verify` + `reasonix-executor-repair` |

### 测试类原则

1. 测试运行不修改源码;不执行需外部服务连接的真实集成测试(除非已确认安全并授权)。
2. 新失败 ≠ 自动 PASS:状态标记必须区分「仅已知失败」与「新失败」。
3. 超时或命令不存在时如实报 FAIL 并附原因,禁止编造结果。

---

## 四、研究类工具(explore / research / web_fetch)

### explore — 目录与结构探索

- **定位**:快速理解项目结构,按模式定位文件。
- **入口**:`/explore`。

### research — 资料研究

- **定位**:跨文件检索、引用追踪、目录分析、Web 检索,输出带来源引用的结构化发现。
- **入口**:`/research` 或 `run_skill: reasonix-research`(子智能体独立研究)。
- **搜索优先级**:工作区 → 全局技能/已索引技能库 → 知识索引 → 互联网(仅本地不足时)。

### web_fetch — 网页抓取

- **定位**:HTTPS 内容获取(HTML 转文本、JSON 原样返回),研究/资料收集的补充通道。
- **入口**:内置工具 `web_fetch`。
- **进阶**:网页交互、整站爬取、深度研究等复杂抓取 → firecrawl 系列技能(见 L3)。

### 研究类原则

1. 本地信息足够时不访问外网,控制外部依赖。
2. 所有发现必须给出 `exact_location`(文件:行号 或 URL),引用可回溯。
3. 不索引、不暴露用户私人数据。

---

## 五、并行类工具(parallel_tasks / fleet / task)

### task — 子任务执行

- **定位**:派发单个带工具白名单的子智能体(可写/可执行,取决于授权)。
- **适用**:独立成块的实现、测试、修复任务。

### parallel_tasks — 并行子任务

- **定位**:同时派发多个独立只读子智能体,互不共享状态,各自返回结论。
- **适用**:2+ 个无依赖的独立调查/审查任务同时进行。
- **原则**:并行子智能体默认只读;结果汇总后必须过 Gate Review。

### fleet — 舰队模式

- **定位**:大规模并行子智能体编排(超过 parallel_tasks 常规规模时使用)。
- **适用**:批量审查、批量抓取、多目标验证等规模化并行场景。

### 并行类选择指引

| 场景 | 工具 |
|------|------|
| 单个独立子任务 | `task` |
| 2–8 个独立只读调查 | `parallel_tasks`(或 `/dispatching-parallel-agents`) |
| 大规模并行编排 | `fleet` |
| 需要隔离上下文的只读研究 | `read_only_task` |

---

## 六、命令类工具(slash_command / run_skill)

### slash_command — 斜杠命令

- **定位**:调用项目/内置命令模板,把常用工作流固化为可复用入口。
- **入口**:`tool: slash_command`(交互会话中直接 `/命令`)。
- **内置命令示例**:`/explore`、`/test`、`/research`、`/review`、`/security-review`、`/todo`、`/skills`、`/memory`、`/help`。
- **技能类命令**:baoyu 系列(`/baoyu-translate`、`/baoyu-diagram`…)、firecrawl 系列(`/firecrawl-search`、`/firecrawl-scrape`…)、hyperframes 系列(`/hyperframes`、`/motion-graphics`…)等均经斜杠命令直达。

### run_skill — 技能运行

- **定位**:按名称加载并执行 Skills 索引内的技能(含原生技能与用户技能)。
- **入口**:`tool: run_skill`(或子代理型技能经 `read_only_skill` 只读执行)。

### 命令类选择指引

| 场景 | 入口 |
|------|------|
| 内置流程(审查/测试/研究/探索) | `/review`、`/test`、`/research`、`/explore` |
| 成熟工作流(关卡/修复/视觉) | `run_skill: reasonix-gate-controller` 等 |
| 内容创作/发布/抓取/视频等具体任务 | `/baoyu-*`、`/firecrawl-*`、`/hyperframes` 系列 |
| 查看全部可用命令 | `/help` 或 `slash_command`(空参数) |

---

## 七、端到端选择矩阵(按任务场景)

| 任务场景 | 推荐路径 |
|----------|----------|
| 完成一段代码后自查 | `review` → `security_review` → 修问题 |
| 合并/提交前验收 | `reasonix-gate-controller`(claim 对比证据、加权评分)→ 通过则完成 |
| 功能开发(严格流程) | `/test-driven-development` → `/test` → `review` |
| 发现 bug 需定位 | `/systematic-debugging` → 修复 → 回归 `/test` |
| 多模块并行调研 | `parallel_tasks` / `fleet` → `reasonix-research` → 结果过 Gate Review |
| 验证被拒需修复 | `reasonix-executor-repair`(最小修复 → 重跑验证 → 重提 Gate Review) |
| 视觉证据(截图)核验 | `reasonix-vision-review`(需先配置视觉能力) |
| 长任务(≥30 步或 ≥5 分钟) | 分段执行 + checkpoint/handoff(`reasonix-mature-core` 长任务协议) |

---

## 八、安全与使用边界

1. 所有审查/研究类子智能体一律只读,除非任务明确要求执行测试/修复且已授权。
2. 本生态不保存、不引用任何密钥/令牌明文;报告中仅显示脱敏片段(前缀 4 位 + 后缀 4 位)。
3. 不修改系统/网络/代理配置,不做用户未明确要求的破坏性操作。
4. 外部能力(firecrawl、图像生成、浏览器自动化等)涉及外部服务时,需用户明确授权且不得用于验证码绕过、反检测、未授权采集等场景。
5. 禁止把任何外部模型或厂商密钥配置写入本注册表;本文件不登记任何外部密钥。

---

## 九、变更与维护

- 工具/技能增减时同步更新:`tool-registry.json`(机器可读)→ `SKILLS_INDEX.md`(技能索引)→ 本文档(定位与指引)。
- 新增原生技能:在 `.reasonix/skills/<name>/SKILL.md` 编写,并在 `SKILLS_INDEX.md`、`skills-index.json` 登记。
- 视觉类技能(vision-review)保持 `READY_PENDING_PROVIDER_CONFIG`,待用户配置视觉能力后切换为 `READY`。
