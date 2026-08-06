#!/usr/bin/env python
"""Reasonix Continuity — 正式闭账"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
from continuity import close_task, root_path, ContinuityError

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("用法: python close-task.py <task-id> <PASS|DEGRADED|FAIL> <summary>")
        sys.exit(1)
    try:
        result = close_task(root_path(), sys.argv[1], sys.argv[2], sys.argv[3])
        print(f"任务已闭账: {result['result']} | verdict={result['closeout']['verdict']}")
    except ContinuityError as e:
        print(f"错误 [{e.code}]: {e}")
        sys.exit(1)
