---
name: operate-omarchy-flclash-networking
description: Diagnose, repair, and persist FlClash networking on Omarchy/Arch Linux, including System proxy versus TUN routing, port 7890 tests, Chromium proxy integration, terminal proxy persistence, startup after graphical login, saved Rule-mode state, and evidence-based fault isolation.
---

# Operate Omarchy FlClash Networking

Treat the network path as separate layers. Never infer end-to-end success from the green status icon or an open GUI.

## Default target state

Unless the user explicitly requires transparent UDP or proxy-unaware applications, preserve this known-good state:

- FlClash core running.
- `System proxy`: on.
- `TUN`: off.
- Outbound mode: `Rule`.
- Mixed proxy listening on `127.0.0.1:7890`.
- New terminal sessions receive HTTP/HTTPS proxy variables for `127.0.0.1:7890`, with localhost excluded through `NO_PROXY` and `no_proxy`.
- Chromium launched with `--proxy-server=http://127.0.0.1:7890` when Omarchy/Hyprland does not propagate desktop proxy settings.
- FlClash starts once after the user's graphical Omarchy login and restores its saved state.

Do not turn on TUN as a generic fix. Do not enable System proxy and TUN together unless a documented requirement justifies both.

## Route the task

1. For diagnosis or repair, read [references/incident-playbook.md](references/incident-playbook.md).
2. For startup, terminal variables, saved state, or direct-open behavior, also read [references/autostart-and-persistence.md](references/autostart-and-persistence.md).
3. For a safe first-pass evidence bundle, run `scripts/diagnose-flclash.sh` as the logged-in desktop user. It is read-only and must not print subscription contents.

## Core workflow

### 1. Resolve the real installation

Discover rather than assume:

- GUI and core process paths.
- Package/AppImage/manual installation origin.
- FlClash version.
- Actual mixed proxy port.
- Active login shell and its user-owned startup files.
- Omarchy generation and whether the user configuration uses Hyprland Lua or legacy `.conf`.
- Chromium executable and launch entry.

The GUI and core may legitimately have different paths. Treat this as suspicious only when their versions or resources conflict.

### 2. Separate proxy, TUN, terminal, and application behavior

Test in this order:

1. Confirm the core process and listener.
2. Force an HTTP request through `127.0.0.1:7890`.
3. Compare direct and proxied public IPs.
4. Test a newly started shell that does not inherit temporary proxy exports.
5. Transfer enough data through the explicit proxy to distinguish an idle speed display from a broken statistics path.
6. Test Chromium independently with a temporary profile and `--proxy-server` only when browser integration is in scope.

Interpret `0 B/s` as instantaneous idle speed unless a transfer is active. Use cumulative bytes and request results as evidence.

### 3. Apply the smallest proven repair

- If explicit port 7890 requests succeed but a normal new terminal fails, persist the proxy variables in the active shell's user-owned startup file. Back it up first and use one marked, idempotent block.
- If explicit port 7890 requests succeed but TUN requests time out, disable TUN and use System proxy.
- If explicit port 7890 requests succeed but Chromium times out, persist the Chromium proxy flag in the current user's supported flags file or user-owned launcher.
- If port 7890 fails, investigate core, selected profile/node, and logs before touching browser or terminal settings.
- Reinstall only after proving binary/resource corruption or a reproducible version defect. Preserve profiles and private credentials.

### 4. Persist the known-good state

Prefer FlClash's own saved settings for `System proxy=on`, `TUN=off`, and `Rule`. Configure them once and close cleanly so the application store commits them.

For terminal proxy variables, discover the actual login shell. Back up the chosen file and maintain exactly one marked block containing HTTP/HTTPS variables and localhost exclusions. Do not add contradictory entries to several shell files.

For startup, use exactly one user-owned mechanism appropriate to the detected Omarchy version. Never create duplicate XDG, Hyprland, and systemd launchers for the same process. Do not edit files under `~/.local/share/omarchy/default`.

Interpret “automatic login” as automatic start after the user's graphical login. Do not weaken disk encryption, enable unattended OS login, store passwords, or bypass the login screen unless the user separately and explicitly requests that security change.

### 5. Acceptance

Normally verify:

- core and listener;
- explicit proxy request;
- proxied public IP;
- proxy variables in a genuinely new shell;
- `https://chatgpt.com` access from that new shell;
- Codex path, version, and a live request when Codex is in scope;
- Chromium path when browser integration is in scope;
- one-start-only behavior when startup persistence is changed.

Record checks actually performed. Never claim an unperformed restart or login-cycle test passed.

## Safety rules

- Back up every user configuration file before modifying it.
- Never print, copy, or commit subscription URLs, proxy credentials, tokens, full profiles, or Codex authentication files.
- Never edit FlClash's SQLite database blindly. Inspect schema and back it up first if direct state repair becomes unavoidable.
- Do not kill a browser with unsaved work. Use a temporary Chromium profile for isolated tests or ask the user to close it normally.
- Do not modify TUN routes, nftables, DNS, or NetworkManager settings after the explicit proxy path is proven unless the user specifically needs TUN.
- Preserve unrelated configuration and existing flags.

## Handoff format

Report only:

- root cause by layer;
- configuration changed and backup location;
- final intended state;
- checks actually performed versus intentionally skipped;
- any remaining limitation, especially that TUN remains disabled.
