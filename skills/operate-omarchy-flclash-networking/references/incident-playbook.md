# Incident playbook

## Layered diagnosis

Follow this path and stop guessing:

```text
binary/resources
  -> GUI process
  -> core process
  -> local listener 127.0.0.1:7890
  -> forced proxy request
  -> selected outbound/node
  -> terminal proxy environment
  -> System proxy propagation
  -> application-specific proxy use
  -> optional TUN routing
```

Definitions:

- Green icon: core lifecycle state only.
- `System proxy`: advertises a local proxy to applications that honor desktop/system settings.
- Shell proxy variables: required for command-line programs that ignore desktop proxy settings.
- `TUN`: creates a virtual interface and policy routing to capture traffic transparently.
- `Rule`: routes each request according to the active profile.
- `0 B/s`: current transfer rate, not proof of zero historical traffic.

The proven Omarchy incident behind this skill had a working core on `127.0.0.1:7890`, direct connections timing out, explicit proxy requests succeeding, TUN failing, and Chromium requiring its own proxy flag. The stable state was System proxy on, TUN off, Rule mode, plus explicit application integration. A historical public IP is evidence from that incident, not a permanent invariant.

## Deterministic tests

### Listener

```bash
ss -lntup | grep -E ':(7890|7891|7892|9090)\b'
```

### Forced request

```bash
curl -4 -x http://127.0.0.1:7890 \
  -sS -o /dev/null --connect-timeout 5 --max-time 15 \
  -w 'HTTP_CODE=%{http_code} DOWNLOAD=%{size_download} TIME=%{time_total}\n' \
  https://www.google.com
```

### Direct versus proxied IP

```bash
env -u http_proxy -u https_proxy -u HTTP_PROXY -u HTTPS_PROXY \
  curl --noproxy '*' -4 -sS --connect-timeout 5 --max-time 12 \
  https://api.ipify.org

curl -4 -x http://127.0.0.1:7890 -sS \
  --connect-timeout 5 --max-time 15 https://api.ipify.org
```

Do not call the first request direct while an active TUN route still captures it.

### ChatGPT reachability

```bash
curl -4 -x http://127.0.0.1:7890 \
  -sS -o /dev/null --connect-timeout 5 --max-time 15 \
  -w 'HTTP_CODE=%{http_code} TIME=%{time_total}\n' \
  https://chatgpt.com
```

### Visible transfer

```bash
curl -4 -x http://127.0.0.1:7890 \
  -L --limit-rate 1M --connect-timeout 8 --max-time 40 \
  -o /dev/null \
  -w 'HTTP_CODE=%{http_code} DOWNLOADED=%{size_download} SPEED=%{speed_download} TIME=%{time_total}\n' \
  'https://speed.cloudflare.com/__down?bytes=20000000'
```

### Isolated Chromium test

Resolve the binary first, then use a temporary profile so an already-running process cannot discard the new flag:

```bash
chromium \
  --user-data-dir=/tmp/flclash-chromium-test \
  --proxy-server=http://127.0.0.1:7890 \
  https://www.google.com
```

The temporary profile is intentionally blank. Do not mistake it for the user's normal profile.

For Arch Chromium, preserve the normal profile and use one line in `~/.config/chromium-flags.conf` when required:

```text
--proxy-server=http://127.0.0.1:7890
```

## Decision table

| Evidence | Root layer | Action |
|---|---|---|
| No core or listener | installation/core | Inspect process path, version, permissions, and logs |
| Listener exists, explicit proxy fails | core/profile/node | Inspect selected profile, node, and core errors |
| Explicit proxy succeeds, new terminal fails | shell environment | Persist proxy variables once in the actual shell startup file |
| Explicit proxy succeeds, TUN times out | TUN/policy routing | Disable TUN; use System proxy unless transparent capture is required |
| Explicit proxy succeeds, Chromium fails | application integration | Persist the Chromium proxy flag |
| Transfer succeeds, dashboard returns to zero | none | Explain instantaneous idle speed |
| Transfer succeeds, counters never change | GUI statistics | Treat as display/statistics issue, not proxy failure |

## Failure patterns to avoid

- Repeating isolated edits without an end-to-end acceptance condition.
- Claiming success because the GUI is green.
- Reinstalling before proving corruption.
- Adding proxy exports to several shell files without discovering the active shell.
- Enabling TUN to hide terminal or browser integration failures.
- Treating table 2022 or fake-IP addresses as inherently erroneous.
- Testing direct access while TUN is still capturing it.
- Opening Chromium with a new flag while an old process is running and reuses the old flags.
- Changing localization, DNS, routes, profiles, and proxy integration in the same repair.
