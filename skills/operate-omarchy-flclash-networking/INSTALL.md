# 安装到 Omarchy Codex

本包内的 `operate-omarchy-flclash-networking` 文件夹是完整 Codex 技能。

## 安装目标

```text
/home/midao/.codex/skills/operate-omarchy-flclash-networking/
```

## 安装原则

1. 先确认目标目录中是否已有同名技能。
2. 若已存在，先创建带时间戳的完整备份，不直接覆盖。
3. 将技能目录复制到 `~/.codex/skills/`，保持目录层级不变。
4. 赋予诊断脚本执行权限。
5. 重新启动 Codex，让技能索引刷新。
6. 在 Codex 内明确调用 `$operate-omarchy-flclash-networking`，先运行只读诊断，再进行永久代理修复。

## 安装后检查

```bash
test -f ~/.codex/skills/operate-omarchy-flclash-networking/SKILL.md
test -f ~/.codex/skills/operate-omarchy-flclash-networking/references/incident-playbook.md
test -f ~/.codex/skills/operate-omarchy-flclash-networking/references/autostart-and-persistence.md
test -x ~/.codex/skills/operate-omarchy-flclash-networking/scripts/diagnose-flclash.sh
```

不要把压缩包本身放进 `~/.codex/skills` 后就宣称安装完成；Codex需要看到解压后的 `SKILL.md`。
