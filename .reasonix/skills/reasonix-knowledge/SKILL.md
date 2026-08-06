---
name: reasonix-knowledge
description: 访问本机 Knowledge Brain 长期知识库（Hermes/Codex 沉淀，413+ 知识条目、155 技能索引、498 Obsidian 文档）。按 INDEX → ROUTING_MAP → 分类索引 → Top-K 文档的检索路径获取跨会话积累的知识、技能、经验教训。触发词：查询知识库、调用知识库、长期记忆检索、KB 检索、经验查询。
runAs: inline
---

# Reasonix Knowledge Access（本机知识库访问）

> 源：`C:\Users\A\.codex\knowledge-brain`（Hermes/Codex 长期知识库，C 盘权威）
> 能力：直接读取本机知识库，检索跨会话积累的知识/技能/经验

## 知识库结构

| 层 | 路径 | 内容 |
|----|------|------|
| 入口 | `C:\Users\A\.codex\knowledge-brain\INDEX.md` | 总索引：知识 ID、技能、版本、路由 |
| 路由 | `C:\Users\A\.codex\knowledge-brain\ROUTING_MAP.md` | 按任务类型路由到分类索引 |
| 技能索引 | `...\indexes\skills-index.md` | 155 个技能：路径/用途/触发词/ROI |
| 报告索引 | `...\indexes\reports-index.md` | 历史执行报告 |
| 命令索引 | `...\indexes\commands-index.md` | 命令包 |
| Obsidian | `C:\Users\A\.codex\obsidian-vaults\AI-COMPANY-KNOWLEDGE-OS\` | 人类可读长期知识（498 Markdown） |
| 工具 | `...\tools\kb_*.ps1` | health_check / hot_sync / deep_sync / audit |

## 检索流程（Required Route）

1. 读 `INDEX.md` → 2. 读 `ROUTING_MAP.md` → 3. 读相关分类索引 → 4. 检索 Top-K C 盘文档。

## 按任务类型路由

| 任务 | 用 |
|------|----|
| 技能/可复用流程 | `indexes\skills-index.md` → `C:\Users\A\.codex\skills\<skill>` |
| 过去执行结果 | `indexes\reports-index.md` → `C:\Users\A\Documents\Codex` |
| 命令包 | `indexes\commands-index.md` |
| AI 公司 OS / Obsidian | `indexes\obsidian-index.md` → obsidian-vaults |
| 代码库结构 | `indexes\code-reference-index.md` → CodeGraph |
| 知识库/记忆设计 | `openhuman-reference\` |
| 公共 API 发现 | `KB-DEV-PUBLIC-API-CATALOG` → `public-api-discovery` |

## 常用工具

```powershell
# 健康检查（验证知识库完整）
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\A\.codex\knowledge-brain\tools\kb_health_check.ps1

# 热同步（只处理 hot 条目，安全）
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\A\.codex\knowledge-brain\tools\kb_hot_sync.ps1

# 全源审计（只读）
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\A\.codex\knowledge-brain\tools\kb_audit_all_sources.ps1 -MaxSecondsPerSource 20
```

## 硬规则

- **C 盘是唯一权威**；K 盘仅备份；H 盘仅历史。禁止从 K/H 回填缺失的 C 源。
- 禁止默认全量读 Obsidian Vault（只读 Top-K 相关文档）。
- 检索用 grep/glob 精确匹配，不用模糊猜测。
- 知识条目是索引；已安装技能目录是执行权威。
- 不修改 Knowledge Brain 任何文件（只读访问）。

## 防落灰绑定

- 触发词：查询知识库、调用知识库、长期记忆、KB 检索、经验查询、之前做过什么。
- 启动流程：先跑 `kb_health_check.ps1` 确认健康，再按路由检索。
