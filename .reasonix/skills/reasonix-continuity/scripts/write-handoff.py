#!/usr/bin/env python
"""Reasonix Continuity — 写入交接包"""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
from continuity import write_handoff, root_path, ContinuityError

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python write-handoff.py <task-id>")
        sys.exit(1)
    try:
        handoff = write_handoff(root_path(), sys.argv[1])
        print(f"Handoff 已写入: next_step={handoff['next_step']} | completed_steps={handoff['completed_steps']}")
    except ContinuityError as e:
        print(f"错误 [{e.code}]: {e}")
        sys.exit(1)
