#!/usr/bin/env python
"""Reasonix Continuity — 保存检查点"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
from continuity import save_checkpoint, root_path, ContinuityError

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("用法: python save-checkpoint.py <task-id> <step> <DONE|IN_PROGRESS|WAITING_USER|BLOCKED> <summary> [model]")
        sys.exit(1)
    try:
        result = save_checkpoint(root_path(), sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5] if len(sys.argv) > 5 else "")
        print(f"Checkpoint 已保存: {result['checkpoint']} | step={result['state']['current_step']} | next_step={result['state']['next_step']}")
    except ContinuityError as e:
        print(f"错误 [{e.code}]: {e}")
        sys.exit(1)
