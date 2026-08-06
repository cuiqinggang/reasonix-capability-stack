from __future__ import annotations

import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

TASK_ID_RE = re.compile(r"^[a-z0-9][a-z0-9-]{2,63}$")
STEP_STATES = {"DONE", "IN_PROGRESS", "WAITING_USER", "BLOCKED"}
CLOSE_STATES = {"PASS", "DEGRADED", "FAIL"}


class ContinuityError(RuntimeError):
    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code


def now() -> str:
    return datetime.now(timezone.utc).isoformat()


def root_path(value: str | None = None) -> Path:
    # 从 lib/continuity.py 向上 5 层到工作区根：lib → reasonix-continuity → skills → .reasonix → workspace
    workspace = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
    root = Path(value or os.environ.get("REASONIX_CONTINUITY_ROOT") or os.path.join(workspace, ".reasonix", "state", "continuity"))
    resolved = root.resolve()
    # Reasonix adaptation: removed C: drive restriction — workspace-relative paths accepted
    return resolved


def validate_task_id(task_id: str) -> str:
    task_id = task_id.strip().lower()
    if not TASK_ID_RE.fullmatch(task_id):
        raise ContinuityError("INVALID_TASK_ID", "task-id 仅允许 3-64 位小写字母、数字和连字符。")
    return task_id


def task_dir(root: Path, task_id: str) -> Path:
    return root / "tasks" / validate_task_id(task_id)


def canonical_hash(value: dict[str, Any]) -> str:
    raw = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(raw).hexdigest().upper()


def checkpoint_hash(value: dict[str, Any]) -> str:
    unsigned = json.loads(json.dumps(value, ensure_ascii=False))
    unsigned.pop("checkpoint_sha256", None)
    state_after = unsigned.get("state_after")
    if isinstance(state_after, dict):
        state_after["latest_checkpoint_sha256"] = None
    return canonical_hash(unsigned)


def atomic_json(path: Path, value: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + f".{os.getpid()}.tmp")
    temp.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    os.replace(temp, path)


def append_event(directory: Path, event: str, details: dict[str, Any]) -> None:
    safe = {k: v for k, v in details.items() if k not in {"token", "key", "secret", "command_line", "message_id"}}
    record = {"timestamp": now(), "event": event, **safe}
    with (directory / "events.jsonl").open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(record, ensure_ascii=False, separators=(",", ":")) + "\n")


def validate_state(state: dict[str, Any]) -> None:
    required = {"schema_version", "task_id", "title", "status", "total_steps", "current_step", "next_step", "completed_steps", "revision"}
    if not required.issubset(state):
        raise ContinuityError("STATE_INVALID", "任务状态缺少必填字段。")
    if not isinstance(state["completed_steps"], list) or int(state["total_steps"]) < 1:
        raise ContinuityError("STATE_INVALID", "任务步骤字段无效。")


def create_task(root: Path, task_id: str, title: str, total_steps: int, model: str = "") -> dict[str, Any]:
    directory = task_dir(root, task_id)
    state_path = directory / "task-state.json"
    if state_path.exists():
        raise ContinuityError("TASK_ALREADY_EXISTS", "任务已存在；请使用 resume/status。")
    if total_steps < 1:
        raise ContinuityError("INVALID_TOTAL_STEPS", "total_steps 必须大于 0。")
    stamp = now()
    state = {
        "schema_version": "1.0",
        "task_id": validate_task_id(task_id),
        "title": title.strip() or task_id,
        "status": "ACTIVE",
        "status_reason": "created",
        "total_steps": total_steps,
        "current_step": 0,
        "next_step": 1,
        "completed_steps": [],
        "waiting_for": "",
        "model_at_checkpoint": model.strip(),
        "model_history": [model.strip()] if model.strip() else [],
        "latest_checkpoint": None,
        "latest_checkpoint_sha256": None,
        "last_handoff": None,
        "created_at": stamp,
        "updated_at": stamp,
        "revision": 0,
    }
    atomic_json(state_path, state)
    append_event(directory, "TASK_CREATED", {"task_id": task_id, "total_steps": total_steps})
    return state


def _read_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8-sig"))
    except Exception as exc:
        raise ContinuityError("JSON_CORRUPT", f"无法解析 {path.name}: {exc}") from exc
    if not isinstance(value, dict):
        raise ContinuityError("JSON_CORRUPT", f"{path.name} 不是 JSON 对象。")
    return value


def _valid_checkpoint(path: Path) -> dict[str, Any]:
    data = _read_json(path)
    claimed = data.get("checkpoint_sha256")
    if not claimed or checkpoint_hash(data) != claimed:
        raise ContinuityError("CHECKPOINT_HASH_INVALID", f"{path.name} 哈希不匹配。")
    state = data.get("state_after")
    if not isinstance(state, dict):
        raise ContinuityError("CHECKPOINT_STATE_MISSING", f"{path.name} 缺少 state_after。")
    validate_state(state)
    return data


def load_with_recovery(root: Path, task_id: str) -> tuple[dict[str, Any], dict[str, Any]]:
    directory = task_dir(root, task_id)
    state_path = directory / "task-state.json"
    skipped: list[str] = []
    try:
        state = _read_json(state_path)
        validate_state(state)
        return state, {"fallback_used": False, "skipped_corrupt": []}
    except ContinuityError:
        pass
    checkpoints = sorted((directory / "checkpoints").glob("checkpoint-*.json"), reverse=True)
    for path in checkpoints:
        try:
            checkpoint = _valid_checkpoint(path)
            return checkpoint["state_after"], {
                "fallback_used": True,
                "fallback_checkpoint": path.name,
                "skipped_corrupt": skipped,
                "recovery_code": "CHECKPOINT_CORRUPT_FALLBACK" if skipped else "STATE_CORRUPT_FALLBACK",
            }
        except ContinuityError:
            skipped.append(path.name)
    raise ContinuityError("STATE_MISSING", "状态文件不可用且没有有效 checkpoint。")


def save_checkpoint(root: Path, task_id: str, step: int, status: str, summary: str, model: str = "", waiting_for: str = "", required_files: list[str] | None = None) -> dict[str, Any]:
    directory = task_dir(root, task_id)
    state, recovery = load_with_recovery(root, task_id)
    if str(state["status"]).startswith("CLOSED_"):
        raise ContinuityError("CLOSED_TASK_REJECTED", "任务已闭账，拒绝新增 checkpoint。")
    status = status.upper()
    if status not in STEP_STATES:
        raise ContinuityError("INVALID_STEP_STATUS", "步骤状态无效。")
    if step < 1 or step > int(state["total_steps"]):
        raise ContinuityError("INVALID_STEP", "步骤超出任务范围。")
    completed = [int(x) for x in state["completed_steps"]]
    if step in completed:
        raise ContinuityError("DUPLICATE_STEP_REJECTED", "该步骤已完成，禁止重复执行。")
    if status == "DONE" and step != int(state["next_step"]):
        raise ContinuityError("OUT_OF_ORDER_STEP_REJECTED", f"下一步应为 {state['next_step']}，拒绝跳步。")
    missing = []
    for item in required_files or []:
        path = Path(item).resolve()
        if path.drive.upper() != "C:" or not path.is_file():
            missing.append(str(path))
    if missing:
        raise ContinuityError("MISSING_REQUIRED_FILE", "必需文件缺失：" + ", ".join(missing))
    if status == "WAITING_USER" and not waiting_for.strip():
        waiting_for = summary.strip()
    next_state = dict(state)
    if status == "DONE":
        completed.append(step)
        completed.sort()
        next_state["current_step"] = step
        next_state["next_step"] = step + 1 if step < int(state["total_steps"]) else None
        next_state["status"] = "ACTIVE" if next_state["next_step"] else "READY_TO_CLOSE"
        next_state["waiting_for"] = ""
    else:
        next_state["current_step"] = step
        next_state["status"] = status
        next_state["waiting_for"] = waiting_for.strip() if status == "WAITING_USER" else ""
    next_state["completed_steps"] = completed
    next_state["status_reason"] = summary.strip()
    if model.strip() and model.strip() != next_state.get("model_at_checkpoint", ""):
        history = list(next_state.get("model_history") or [])
        history.append(model.strip())
        next_state["model_history"] = history
        next_state["model_at_checkpoint"] = model.strip()
    next_state["updated_at"] = now()
    next_state["revision"] = int(next_state.get("revision", 0)) + 1
    sequence = next_state["revision"]
    filename = f"checkpoint-{sequence:04d}.json"
    next_state["latest_checkpoint"] = filename
    checkpoint = {
        "schema_version": "1.0",
        "task_id": task_id,
        "sequence": sequence,
        "step": step,
        "step_status": status,
        "summary": summary.strip(),
        "required_files": required_files or [],
        "previous_checkpoint_sha256": state.get("latest_checkpoint_sha256"),
        "created_at": now(),
        "state_after": next_state,
    }
    checkpoint["checkpoint_sha256"] = checkpoint_hash(checkpoint)
    next_state["latest_checkpoint_sha256"] = checkpoint["checkpoint_sha256"]
    checkpoint["state_after"] = next_state
    atomic_json(directory / "checkpoints" / filename, checkpoint)
    atomic_json(directory / "task-state.json", next_state)
    append_event(directory, "CHECKPOINT_SAVED", {"task_id": task_id, "step": step, "status": status, "sequence": sequence, "recovery": recovery})
    return {"result": "CHECKPOINT_SAVED", "state": next_state, "checkpoint": filename, "recovery": recovery}


def write_handoff(root: Path, task_id: str) -> dict[str, Any]:
    directory = task_dir(root, task_id)
    state, recovery = load_with_recovery(root, task_id)
    handoff = {
        "schema_version": "1.0",
        "task_id": task_id,
        "title": state["title"],
        "status": state["status"],
        "completed_steps": state["completed_steps"],
        "current_step": state["current_step"],
        "next_step": state["next_step"],
        "waiting_for": state.get("waiting_for", ""),
        "model_at_checkpoint": state.get("model_at_checkpoint", ""),
        "model_history": state.get("model_history", []),
        "latest_checkpoint": state.get("latest_checkpoint"),
        "latest_checkpoint_sha256": state.get("latest_checkpoint_sha256"),
        "resume_rule": "从 next_step 继续；completed_steps 禁止重复。",
        "created_at": now(),
        "recovery": recovery,
    }
    unsigned = dict(handoff)
    handoff["handoff_sha256"] = canonical_hash(unsigned)
    atomic_json(directory / "handoff.json", handoff)
    state["last_handoff"] = handoff["created_at"]
    state["updated_at"] = now()
    atomic_json(directory / "task-state.json", state)
    append_event(directory, "HANDOFF_WRITTEN", {"task_id": task_id, "next_step": state["next_step"]})
    return handoff


def resume_task(root: Path, task_id: str) -> dict[str, Any]:
    directory = task_dir(root, task_id)
    state, recovery = load_with_recovery(root, task_id)
    handoff = None
    handoff_path = directory / "handoff.json"
    if handoff_path.is_file():
        try:
            candidate = _read_json(handoff_path)
            claimed = candidate.get("handoff_sha256")
            unsigned = dict(candidate)
            unsigned.pop("handoff_sha256", None)
            if claimed == canonical_hash(unsigned):
                handoff = candidate
        except ContinuityError:
            handoff = None
    code = "WAITING_USER" if state["status"] == "WAITING_USER" else ("MODEL_SWITCH_RESTORED" if len(state.get("model_history", [])) > 1 else "TASK_RESUMED")
    result = {
        "result": code,
        "task_id": task_id,
        "title": state["title"],
        "status": state["status"],
        "completed_steps": state["completed_steps"],
        "current_step": state["current_step"],
        "next_step": state["next_step"],
        "waiting_for": state.get("waiting_for", ""),
        "model_at_checkpoint": state.get("model_at_checkpoint", ""),
        "model_history": state.get("model_history", []),
        "do_not_repeat": state["completed_steps"],
        "handoff_loaded": handoff is not None,
        "recovery": recovery,
    }
    append_event(directory, "TASK_RESUMED", {"task_id": task_id, "next_step": state["next_step"], "fallback_used": recovery["fallback_used"]})
    return result


def close_task(root: Path, task_id: str, verdict: str, summary: str) -> dict[str, Any]:
    directory = task_dir(root, task_id)
    state, recovery = load_with_recovery(root, task_id)
    verdict = verdict.upper()
    if verdict not in CLOSE_STATES:
        raise ContinuityError("INVALID_CLOSE_STATUS", "闭账状态必须为 PASS、DEGRADED 或 FAIL。")
    if verdict == "PASS" and len(state["completed_steps"]) != int(state["total_steps"]):
        raise ContinuityError("INCOMPLETE_TASK_PASS_REJECTED", "步骤未全部完成，禁止 PASS 闭账。")
    stamp = now()
    closeout = {
        "schema_version": "1.0",
        "task_id": task_id,
        "verdict": verdict,
        "summary": summary.strip(),
        "completed_steps": state["completed_steps"],
        "total_steps": state["total_steps"],
        "closed_at": stamp,
        "recovery": recovery,
    }
    closeout["closeout_sha256"] = canonical_hash(closeout)
    state["status"] = f"CLOSED_{verdict}"
    state["status_reason"] = summary.strip()
    state["updated_at"] = stamp
    atomic_json(directory / "closeout.json", closeout)
    atomic_json(directory / "task-state.json", state)
    append_event(directory, "TASK_CLOSED", {"task_id": task_id, "verdict": verdict})
    return {"result": "TASK_CLOSED", "state": state, "closeout": closeout}


def cli_result(action):
    try:
        return {"ok": True, **action()}
    except ContinuityError as exc:
        return {"ok": False, "code": exc.code, "message": str(exc)}
