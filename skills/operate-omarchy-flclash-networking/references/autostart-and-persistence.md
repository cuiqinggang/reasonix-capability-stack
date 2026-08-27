# Autostart and persistence

## Desired behavior

After the user logs into the Omarchy graphical session:

1. Start exactly one FlClash GUI/core instance.
2. Restore the last selected profile and node.
3. Restore `System proxy=on`, `TUN=off`, and `Rule` mode.
4. Expose `127.0.0.1:7890` before proxy-dependent applications need it.
5. Give newly opened terminal sessions the required HTTP/HTTPS proxy variables.

This is application autostart after graphical login, not unattended operating-system login.

## Discovery before writing

```bash
pgrep -af 'FlClash|flclash'
command -v FlClash flclash 2>/dev/null
getent passwd "$(id -un)" | cut -d: -f7
printf 'current_shell=%s\n' "$SHELL"
find ~/.local/share/applications /usr/share/applications \
  -maxdepth 1 -type f -iname '*flclash*.desktop' -print 2>/dev/null
rg -n -i 'flclash|127\.0\.0\.1:7890|http_proxy|https_proxy' \
  ~/.config/autostart ~/.config/systemd/user ~/.config/hypr \
  ~/.bashrc ~/.bash_profile ~/.profile ~/.zshrc ~/.config/fish/config.fish \
  2>/dev/null || true
```

Inspect Omarchy's active user entry points without editing distributed defaults. Current releases may use `~/.config/hypr/autostart.lua`; older releases use sourced `.conf` files.

## Terminal proxy persistence

Determine the actual interactive shell and the startup file it reads. Back up that file with a timestamp before modification. Preserve unrelated lines and use one marked, idempotent block.

For Bash/Zsh-compatible files, the intended values are:

```bash
# >>> omarchy-flclash-terminal-proxy >>>
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
export no_proxy="localhost,127.0.0.1,::1"
export NO_PROXY="localhost,127.0.0.1,::1"
# <<< omarchy-flclash-terminal-proxy <<<
```

For Fish, use Fish syntax rather than copying Bash syntax. Do not add the same variables to multiple files merely to make a test pass.

After editing, start a genuinely new interactive shell that does not inherit the old temporary exports. Verify the variables, a proxied request, and any target CLI. Do not claim reboot persistence without a real new-session or login-cycle test.

When FlClash is intentionally stopped, proxy-dependent terminal commands will fail until it restarts. Report this limitation; do not silently route around it.

## FlClash state persistence

First use FlClash itself:

- select the intended profile/node;
- set System proxy on;
- set TUN off;
- select Rule;
- close FlClash cleanly once.

Do not edit an application database blindly. If state does not survive a clean restart, locate and back up the active data directory, inspect schema and logs, and prefer supported app settings or APIs.

## Startup mechanism selection

Use one mechanism only, in this priority order:

1. FlClash's supported launch-at-startup option when it works.
2. A user-owned XDG autostart desktop entry when the session imports it.
3. Current Omarchy user autostart (`autostart.lua` or sourced user `.conf`).
4. A user systemd service tied to the graphical session only when Wayland environment variables are correctly imported.

Rules:

- Use the discovered absolute executable path.
- Confirm silent/minimized support before using it.
- Add a readiness delay only when the graphical session or network is demonstrably not ready.
- Guard against duplicate processes.
- Never edit `~/.local/share/omarchy/default/**`.
- Never configure several startup mechanisms for the same process.

## Chromium persistence

For Arch Chromium, preserve the normal profile and maintain exactly one proxy flag in:

```text
~/.config/chromium-flags.conf
```

Required line:

```text
--proxy-server=http://127.0.0.1:7890
```

Back up the file, preserve unrelated flags, and remove contradictory proxy flags. Do not point the normal browser at a temporary test profile.

## Acceptance and failure handling

Before adding startup, check FlClash's internal setting, XDG autostart, systemd user units, and Hyprland configuration. Confirm only one GUI/core pair is expected.

After configuration, normally check one login cycle. If that is intentionally skipped, report configuration rather than claiming startup passed.

If startup fails, confirm executable path, graphical environment, process duplication, and readiness ordering. Fall back to the next single supported mechanism rather than stacking mechanisms.
