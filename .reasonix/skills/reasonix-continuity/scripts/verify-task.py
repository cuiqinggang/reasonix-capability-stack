#!/usr/bin/env python
"""验证 absorb-10step 任务完整性（10步链路 readback）"""
import sys, json, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib"))
from continuity import root_path, load_with_recovery, checkpoint_hash, canonical_hash

root = root_path()
task_dir = root / "tasks" / "absorb-10step"

print("=== checkpoint SHA256 链验证（新位置） ===")
checkpoints = sorted((task_dir / "checkpoints").glob("checkpoint-*.json"))
prev_hash = None
chain_ok = True
for cp in checkpoints:
    data = json.loads(cp.read_text(encoding="utf-8-sig"))
    ok = data.get("checkpoint_sha256") == checkpoint_hash(data)
    prev_ok = (data.get("previous_checkpoint_sha256") == prev_hash) if prev_hash else True
    if not ok or not prev_ok:
        chain_ok = False
    print(f"{cp.name}: hash={'OK' if ok else 'FAIL'} prev={'OK' if prev_ok else 'FAIL'}")
    prev_hash = data.get("checkpoint_sha256")
print(f"链: {'PASS' if chain_ok else 'FAIL'} ({len(checkpoints)} checkpoints)")

print("\n=== handoff/closeout 验证 ===")
handoff = json.loads((task_dir / "handoff.json").read_text(encoding="utf-8-sig"))
ho_ok = handoff.get("handoff_sha256") == canonical_hash({k: v for k, v in handoff.items() if k != "handoff_sha256"})
print(f"handoff: {'OK' if ho_ok else 'FAIL'} next_step={handoff['next_step']}")
closeout = json.loads((task_dir / "closeout.json").read_text(encoding="utf-8-sig"))
co_ok = closeout.get("closeout_sha256") == canonical_hash({k: v for k, v in closeout.items() if k != "closeout_sha256"})
print(f"closeout: {'OK' if co_ok else 'FAIL'} verdict={closeout['verdict']} total={closeout['total_steps']}")

state, recovery = load_with_recovery(root, "absorb-10step")
print(f"task-state: {state['status']} completed={len(state['completed_steps'])}/10")
verdict = "ALL_PASS" if chain_ok and len(checkpoints) == 10 and state["status"] == "CLOSED_PASS" else "FAIL"
print(f"VERDICT: {verdict}")
