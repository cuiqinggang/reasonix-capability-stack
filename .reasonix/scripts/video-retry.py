#!/usr/bin/env python
"""多模态视频理解重试 — 统一 qwen3-vl-235b，指数退避 60s/120s/240s，最多3次（GLM-4.6v 已弃用）"""
import base64, json, os, sys, time, hashlib
from datetime import datetime, timezone, timedelta
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

API_KEY = os.environ["OPENROUTER_API_KEY"]
MODEL = "qwen/qwen3-vl-235b-a22b-instruct"  # 统一多模态模型：阿里千问 3.0 235B
VIDEO_PATH = sys.argv[1] if len(sys.argv) > 1 else None
REMOTE_URL = "https://cdn.bigmodel.cn/agent-demos/lark/113123.mov"
BACKOFFS = [60, 120, 240]
EVIDENCE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "evidence")

def tz8():
    return datetime.now(timezone(timedelta(hours=8)))

def log(msg):
    print(f"[{tz8().strftime('%H:%M:%S')}] {msg}")

def api_call(payload, attempt):
    """单次 OpenRouter 调用"""
    body = json.dumps(payload).encode("utf-8")
    req = Request(
        "https://openrouter.ai/api/v1/chat/completions",
        data=body,
        headers={
            "Authorization": f"Bearer {API_KEY}",
            "Content-Type": "application/json",
            "HTTP-Referer": "https://reasonix.local",
            "X-Title": "Reasonix Video Retry"
        }
    )
    try:
        resp = urlopen(req, timeout=120)
        return {"http_status": resp.status, "body": json.loads(resp.read())}
    except HTTPError as e:
        err_body = e.read().decode("utf-8", errors="replace")
        return {"http_status": e.code, "error": err_body}
    except URLError as e:
        return {"http_status": 0, "error": str(e.reason)}

def build_local_video_payload(video_path):
    """构建本地视频 base64 请求"""
    log(f"读取视频: {video_path}")
    with open(video_path, "rb") as f:
        video_bytes = f.read()
    b64 = base64.b64encode(video_bytes).decode("ascii")
    log(f"视频大小: {len(video_bytes)} bytes, base64: {len(b64)} chars")
    
    return {
        "model": MODEL,
        "messages": [{
            "role": "user",
            "content": [
                {"type": "text", "text": "请用中文描述这个视频的内容：视频中发生了什么？有什么关键画面、动作或文字？请尽可能详细地描述。"},
                {"type": "video_url", "video_url": {"url": f"data:video/mp4;base64,{b64}"}}
            ]
        }],
        "max_tokens": 1000
    }

def build_remote_video_payload(url):
    """构建远程视频 URL 请求"""
    return {
        "model": MODEL,
        "messages": [{
            "role": "user",
            "content": [
                {"type": "text", "text": "请用中文描述这个视频的内容：视频中发生了什么？有什么关键画面、动作或文字？请尽可能详细地描述。"},
                {"type": "video_url", "video_url": {"url": url}}
            ]
        }],
        "max_tokens": 1000
    }

def main():
    os.makedirs(EVIDENCE_DIR, exist_ok=True)
    ts = datetime.now(timezone(timedelta(hours=8))).strftime("%Y%m%d-%H%M%S")
    
    # 选择视频源
    if VIDEO_PATH and os.path.exists(VIDEO_PATH):
        log(f"使用本地视频: {VIDEO_PATH}")
        payload = build_local_video_payload(VIDEO_PATH)
        video_source = VIDEO_PATH
        video_type = "local_mp4"
    else:
        log(f"使用远程视频: {REMOTE_URL}")
        payload = build_remote_video_payload(REMOTE_URL)
        video_source = REMOTE_URL
        video_type = "remote_url"
    
    attempts = []
    final_verdict = "FAIL_PERMANENT_429"
    
    for i, wait in enumerate(BACKOFFS):
        attempt_no = i + 1
        log(f"=== 第 {attempt_no}/{len(BACKOFFS)} 次尝试 ===")
        
        if i > 0:
            log(f"等待 {wait} 秒（指数退避）...")
            time.sleep(wait)
        
        result = api_call(payload, attempt_no)
        attempts.append(result)
        
        http_status = result.get("http_status", 0)
        log(f"HTTP {http_status}")
        
        if http_status == 200:
            body = result.get("body", {})
            choices = body.get("choices", [])
            if choices:
                content = choices[0].get("message", {}).get("content", "")
                log(f"✅ 成功！响应: {content[:300]}...")
                final_verdict = "PASS"
            else:
                log(f"⚠️ 200 但无内容")
                final_verdict = "PASS_NO_CONTENT"
            break
        elif http_status == 429:
            err = result.get("error", "")[:200]
            log(f"⏳ 429 限流: {err}")
            if attempt_no == len(BACKOFFS):
                final_verdict = "FAIL_PERMANENT_429"
        else:
            err = result.get("error", "")[:200]
            log(f"❌ 非预期错误 HTTP {http_status}: {err}")
            final_verdict = f"FAIL_HTTP_{http_status}"
            break
    
    # 写证据
    evidence = {
        "video_retry_verification": {
            "time": datetime.now(timezone(timedelta(hours=8))).isoformat(),
            "provider": "openrouter",
            "model": MODEL,
            "video_source": video_source,
            "video_type": video_type,
            "retry_strategy": "exponential_backoff",
            "backoff_seconds": BACKOFFS,
            "total_attempts": len(attempts),
            "attempts": [],
            "verdict": final_verdict
        }
    }
    
    for a in attempts:
        record = {"http_status": a.get("http_status")}
        if "error" in a:
            record["error"] = str(a["error"])[:500]
        if "body" in a and "choices" in a["body"]:
            content = a["body"]["choices"][0].get("message", {}).get("content", "")
            record["response_preview"] = content[:500]
        evidence["video_retry_verification"]["attempts"].append(record)
    
    ev_path = os.path.join(EVIDENCE_DIR, f"video-retry-evidence-{ts}.json")
    with open(ev_path, "w", encoding="utf-8") as f:
        json.dump(evidence, f, ensure_ascii=False, indent=2)
    
    log(f"证据已保存: {ev_path}")
    log(f"最终结论: {final_verdict}")
    
    return 0 if final_verdict == "PASS" else 1

if __name__ == "__main__":
    sys.exit(main())
