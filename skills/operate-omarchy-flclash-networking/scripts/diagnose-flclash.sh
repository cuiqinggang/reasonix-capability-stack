#!/usr/bin/env bash
set -u

proxy_url="${FLCLASH_PROXY_URL:-http://127.0.0.1:7890}"
test_url="${FLCLASH_TEST_URL:-https://www.google.com}"

section() {
  printf '\n===== %s =====\n' "$1"
}

section "SESSION"
printf 'user=%s\n' "$(id -un)"
printf 'login_shell=%s\n' "$(getent passwd "$(id -un)" | cut -d: -f7)"
printf 'current_shell=%s\n' "${SHELL:-EMPTY}"
printf 'desktop=%s\n' "${XDG_CURRENT_DESKTOP:-EMPTY}"
printf 'session_type=%s\n' "${XDG_SESSION_TYPE:-EMPTY}"

section "PROCESSES"
pgrep -af 'FlClash(Core)?( |$)' || true

section "LISTENERS"
ss -lntup 2>/dev/null | grep -E ':(7890|7891|7892|9090)\b' || true

section "TUN_INTERFACES"
ip -brief address 2>/dev/null | grep -i 'flclash\|mihomo\|tun' || true

section "POLICY_RULES"
ip -4 rule show 2>/dev/null || true

section "TABLE_2022"
ip -4 route show table 2022 2>/dev/null || true

section "PROXY_REQUEST"
curl -4 -x "$proxy_url" -sS -o /dev/null \
  --connect-timeout 5 --max-time 15 \
  -w 'http_code=%{http_code} downloaded=%{size_download} remote_ip=%{remote_ip} total=%{time_total}\n' \
  "$test_url" || true

section "CHATGPT_REQUEST"
curl -4 -x "$proxy_url" -sS -o /dev/null \
  --connect-timeout 5 --max-time 15 \
  -w 'http_code=%{http_code} remote_ip=%{remote_ip} total=%{time_total}\n' \
  https://chatgpt.com || true

section "PROXY_PUBLIC_IP"
curl -4 -x "$proxy_url" -sS \
  --connect-timeout 5 --max-time 15 \
  https://api.ipify.org || true
printf '\n'

section "PROXY_ENVIRONMENT"
env | grep -E '^(http_proxy|https_proxy|HTTP_PROXY|HTTPS_PROXY|no_proxy|NO_PROXY)=' \
  | sed -E 's#(https?://)[^/@]+@#\1REDACTED@#g' || true

section "CHROMIUM_FLAGS"
flags_file="${XDG_CONFIG_HOME:-$HOME/.config}/chromium-flags.conf"
if [[ -f "$flags_file" ]]; then
  grep -E '^--(no-proxy-server|proxy-server=)' "$flags_file" || echo 'no_proxy_flag'
else
  echo 'flags_file_missing'
fi

section "AUTOSTART_REGISTRATIONS"
rg -n -i 'flclash' \
  "${XDG_CONFIG_HOME:-$HOME/.config}/autostart" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/hypr" \
  2>/dev/null || true

section "RESULT"
echo 'Read-only evidence collection finished.'
