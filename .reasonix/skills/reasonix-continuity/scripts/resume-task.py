#!/usr/bin/env python
"""Reasonix Continuity — 恢复任务"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
from continuity import resume_task, root_path, ContinuityError

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python resume-task.py <task-id>")
        sys.exit(1)
    try:
        result = resume_task(root_path(), sys.argv[1])
        print(f"任务恢复: {result['result']} | next_step={result['next_step']} | completed={result['completed_steps']}")
        if result.get("waiting_for"):
            print(f"等待用户: {result['waiting_for']}")
        if result.get("handoff_loaded"):
            print("Handoff 已加载")
        if result.get("recovery", {}).get("fallback_used"):
            print(f"⚠️ 使用了损坏恢复: {result['recovery']}")
    except ContinuityError as e:
        print(f"错误 [{e.code}]: {e}")
        sys.exit(1)
