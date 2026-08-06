#!/usr/bin/env python
"""Reasonix Continuity — 新建长任务"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
from continuity import create_task, root_path, ContinuityError

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("用法: python new-task.py <task-id> <total-steps> <title> [model]")
        sys.exit(1)
    task_id = sys.argv[1]
    total_steps = int(sys.argv[2])
    title = sys.argv[3]
    model = sys.argv[4] if len(sys.argv) > 4 else ""
    try:
        state = create_task(root_path(), task_id, title, total_steps, model)
        print(f"任务已创建: {state['task_id']} | 共 {state['total_steps']} 步 | next_step={state['next_step']}")
    except ContinuityError as e:
        print(f"错误 [{e.code}]: {e}")
        sys.exit(1)
