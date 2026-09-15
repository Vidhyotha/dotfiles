# vidhyotha dotfiles, CachyOS + Hyprland + Noctalia

Backup of the user-owned config for this machine (see "What this tracks" below).
The repo itself is a bare git repo at `~/.dotfiles` with `$HOME` as its working tree.
Nothing is symlinked; every file lives in its normal place.

## What this tracks

- `~/.config/hypr/` the whole Hyprland Lua config (binds, inputs, animations, monitors, decorations, variables, windowrules, workspaces, autostart, colors, xdph.conf). `noctalia.lua` is noctalia-generated, not tracked.
- `~/.config/noctalia/` shell config + the local keybind-cheatsheet plugin fork + `templates/` (the gtk mode template)
- `~/.local/state/noctalia/settings.toml` live noctalia settings written by the settings panel (bar layout, hot corners, shell fonts, lockscreen widgets, theme/palette/wallpaper scheme). This is the file the panel edits, so it is tracked; the other `~/.local/state/noctalia/` contents (plugin caches, community templates, notification/usage history) are regenerated and untracked.
- `~/.config/fish/config.fish`
- `~/.config/environment.d/` locale + TERMINAL
- `~/.config/uwsm/env` BROWSER var
- `~/.config/kitty/` kitty.conf + theme (the `noctalia.conf` theme file is noctalia-generated, not tracked)
- `~/.config/mimeapps.list` default apps
- `~/.config/chromium-flags.conf` + `~/.config/chromium/NativeMessagingHosts/com.omarchy.link_router.json` the link-router `--load-extension` flag and native-messaging manifest
- `~/.local/share/chromium-link-router/` the link-router extension + host (routes web-app links to Zen); only this file lives under `~/.config/chromium/`, the rest of the profile is untracked session data
- `~/.config/noctalia/templates/gtk-settings-{dark,light}.ini` a noctalia user template (registered in `config.toml`) that writes `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` per theme mode, so GTK dialogs (Zen's "Save Image As", portal pickers) follow the noctalia dark/light toggle. Do not edit the settings.ini files manually; noctalia owns them.
- `~/.config/opencode/skills/` webapp + unslop + dotfiles-sync
- `~/.local/bin/` webapp-launch, webapp-install, hypr-refresh-rate
- `~/.config/systemd/user/` hypr-refresh-watch.service (watches the ACPI platform profile and reapplies the refresh rate on change)
- `~/.local/share/applications/` all the `Hidden=true` launcher overrides, WhatsApp entry, btop fix
- `~/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf` keeps Bluetooth headsets in A2DP on (re)connect instead of letting WirePlumber flip them into HFP/HSP and churn transports (HFP still engages on demand for the mic)
- `~/Pictures/Wallpapers/` the wallpaper folder (the noctalia theme derives its palette from the active wallpaper)

Not tracked on purpose: Zen profile (`~/.config/zen/`, contains logins and cookies, restore from backup), `.pki`, `.nv`, `.steam`, `.cargo`, `.cache`, `.npm`, `fish_variables`. Also noctalia-generated outputs (`~/.config/hypr/noctalia.lua`, `~/.config/kitty/themes/noctalia.conf`, `~/.config/gtk-{3,4}.0/settings.ini` and `gtk.css`) — they are rewritten on every theme/mode change, so the templates under `~/.config/noctalia/` are the tracked source of truth.

## Daily usage

The alias is defined during the rebuild steps below:

```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

Daily usage:

```bash
git dotfiles add ~/.config/hypr/config/binds.lua   # or any path under $HOME
git dotfiles status
git dotfiles commit -m "message"
git dotfiles push
```

## Rebuild from a fresh CachyOS install

1. Install, create user `vidhyotha`, log in, run this whole setup as that user.
2. Core system (come with the CachyOS Hyprland/Noctalia imaging):
   `sudo pacman -S git`
3. SSH key for GitHub (or use HTTPS):
   `ssh-keygen -t ed25519`, add `~/.ssh/id_ed25519.pub` to github.com/settings/keys.
4. Create an empty private repo named `dotfiles` on GitHub, then:
   ```bash
   git clone --bare git@github.com:vidhyotha/dotfiles.git ~/.dotfiles
   git config --global alias.dotfiles '!git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   git dotfiles config status.showUntrackedFiles no
   git dotfiles checkout
   ```
   If checkout complains a file already exists (fresh machine after first login has skeleton files), move those out of the way first.
5. Reinstall the extra packages we added:
   `sudo pacman -S chromium nautilus zen-browser-bin paru`
   Remove firefox if you do not want it: `sudo pacman -S firefox` was not present; `sudo pacman -Rns firefox`.
6. First-run housekeeping, in order:
   - Reload kitty config (`Ctrl+Shift+F5`) so the copy/paste maps load.
   - `hyprctl reload` to apply binds/animations. Actually just restart the session once; the Lua config is read at startup.
   - Restart noctalia if fixups are needed: `pkill -x noctalia; sleep 2; nohup uwsm app -- noctalia &`.
7. Everything below that is not in git must be redone. It does not survive a reinstall by itself.

## Not in git, redo after reinstall

- Second SSD (`nvme0n1`, Crucial P3): was wiped and formatted ext4, mounted at `/data` via fstab. Reproduce:
  `sudo mkfs.ext4 /dev/nvme0n1p1` (or reload the old partition), get the UUID with `blkid`, then
  `UUID=<uuid> /data ext4 defaults,noatime 0 2` in `/etc/fstab`, `sudo mkdir /data`, `sudo mount -a`.
  The previous LUKS partition on it was erased on purpose.
- Bluetooth stability fixes (system-level, not in git, mirror omarchy):
  - Kernel cmdline `usbcore.autosuspend=-1` in `/etc/default/limine` (via `KERNEL_CMDLINE[default]+=`), applied by `sudo limine-update`. This is the real fix for USB autosuspend on the built-in `usbcore` (a modprobe.d drop-in does nothing for it on CachyOS kernels). Disables USB autosuspend globally; the Intel AX201 BT radio sits behind an internal USB port and auto-suspending it drops A2DP/HFP transports.
  - `/etc/NetworkManager/conf.d/omarchy-wifi-powersave.conf`: `[connection] wifi.powersave = 2` plus live `sudo iw dev wlan0 set power_save off` (combo radio coexistence stability).
- Integrated camera (`SunplusIT 5986:215f`) black-flash/"keeps turning off" issue is a HARDWARE problem, not software: the webcam module's internal connector works loose; the device then loops USB disconnect/re-enumerate on its own port while nothing else on the xHCI bus misbehaves. Reset by pressing the camera module (reseating the connector). No system config involved; none of the USB/power work above was used to "fix" it.
- Data restore from the USB backup: `~/Documents`, `~/Projects` (idleon_clickers, Trading, qmk_firmware), `~/Pictures`, `~/Videos`, `~/PSP`, SplitFiction saves.
- Zen profile `7onfnvsr.Default (beta)` back to `~/.config/zen/`, repoint `installs.ini` and `profiles.ini` to it and clear the Profile Groups cache if Zen makes a fresh profile the default.
- `paru -S proton-pass-cli` was built but login is blocked for the free Proton account ("account not yet allowed to use our CLI"), so `/pass` in the launcher does nothing until the plan qualifies.

## Current keybindings (binds.lua)

Main mod is `SUPER`.

| Keys | Action |
|---|---|
| `SUPER + W` | close window (moved from Q; Q is now unbound) |
| `SUPER + Shift + Return` | browser (Zen) |
| `SUPER + Return` | terminal (kitty, via uwsm app) |
| `SUPER + E` | file manager (Nautilus) |
| `SUPER + C` | universal copy (Ctrl+Insert to active window) |
| `SUPER + V` | universal paste (Shift+Insert) |
| `SUPER + Shift + C` | calculator (moved) |
| `SUPER + Shift + V` | clipboard manager (moved) |
| `SUPER + K` | keybind cheatsheet |
| `SUPER + Esc` | power menu (`noctalia msg panel-toggle session`) |
| `SUPER + Space` | launcher |
| `SUPER + Shift + W` | wallpaper panel |
| `SUPER + 1-0` | focus workspace 1-10 |
| `SUPER + Shift + 1-0` | move window to workspace |
| `SUPER + Alt + 1-0` | focus monitor |
| `SUPER + Shift + Alt + 1-0` | move window to monitor |
| `SUPER + D` / `SUPER + F` | fullscreen mode 1 / 0 |
| `Ctrl + Shift + Esc` | btop |

Every bind carries a `description` flag (the cheatsheet hides undocumented binds).
Modifiers are ordered SUPER, SHIFT, ALT, CTRL everywhere.

Trackpad gestures (inputs.lua): 4-finger horizontal switches workspace, 3-finger up enters fullscreen, 3-finger down exits. 3-finger left and window-close-gesture were removed. No gesture closes or floats windows; use the keys. `natural_scroll` is touchpad-only, mouse stays normal. `scroll_factor = 0.25`.

Workspace animation speed is 1 and the windows animation uses the `quick` bezier (feels instant).
Display scale is 1.25 (monitors.lua). Rounded corners 0, `gaps_out` 5.

## Launcher (Noctalia)

Shows every non-hidden `.desktop` in `/usr/share/applications` plus `~/.local/share/applications`.
Visibility is controlled with `Hidden=true` override files in `~/.local/share/applications/`.
These persist through updates (we hid the KDE leftovers, avahi, qv4l2, lstopo, dolphin, chromium, winetricks, protontricks, goverlay, nvidia-settings, vim, micro, shelly, uuctl, and CachyOS tools, pavucontrol, qt6ct, nwg-look, noctalia). Net result is about 15 apps. No packages were removed for this, all are just hidden.
After changing override files run `update-desktop-database` and `noctalia msg config-reload`.

`btop.desktop` forces `LANG=en_IN.UTF-8` in its Exec so the launcher can start it (root cause below).

## Webapps (Omarchy-style port)

- `~/.local/bin/webapp-launch <url>` runs `chromium --app=<url>` via uwsm: a frameless single-window app.
- `~/.local/bin/webapp-install <name> <url> [icon-url]` downloads a favicon and writes a `.desktop` entry.
- Windows come up as class `chrome-<host>-Default`. Webapps share Chromium's cookies.
- Example in place: WhatsApp (`~/.local/share/applications/WhatsApp.desktop`).
- Links clicked inside web apps open in Zen, not Chromium, via the link router (`~/.local/share/chromium-link-router/`, a tiny MV3 extension + native host loaded through `~/.config/chromium-flags.conf`). OAuth popups stay in the app; a login that happens in a full new tab bounces to Zen. Reinstall with the omarchy-link-router `install.sh` if the flags file resets after an update.
- What to avoid: installed-PWA windows gain an app toolbar, so the `--app=` wrapper is used instead. We tried PWA install once and reverted.
- opencode skill: `~/.config/opencode/skills/webapp/SKILL.md` automates create/verify/remove.

## Keybind cheatsheet plugin (local fork)

`SUPER + K` opens `noctalia msg panel-toggle vidhyotha/keybind-cheatsheet:cheatsheet`.
Lives at `~/.config/noctalia/plugins/keybind-cheatsheet/`, registered as a `path` plugin source so it is read directly and is immune to `plugins update community`. The community copy is disabled.

Our edits, all in that folder:
- modifier order in `service.luau` (SUPER, SHIFT, ALT, CTRL)
- auto-refresh on open (panel.luau onOpen)
- header buttons removed
- 600px single-column panel, 220px key gutter, color-coded pills, human labels (Left Mouse, Right Mouse, Scroll up/down)
- `plugin.toml:96` width 600, and `columns = 1` in `~/.local/state/noctalia/settings.toml`

No update risk: `plugins update <source>` refreshes git sources by pulling their repo, and `local` is a path source, so there is nothing to fetch. Path-source plugins run straight from this folder; there is no materialized copy in `~/.local/state/noctalia/plugins/materialized/`, which is empty. A community update cannot touch it because the plugin id was renamed to `vidhyotha/` here and the community copy no longer exists. The edits are the source of truth and load on the next noctalia restart.

## Env and locale fixes

- Root cause of btop crashing: session `LANG=en_IN` without `.UTF-8`. Fixes, all user-owned and persistent:
  - `~/.config/environment.d/locale.conf`: `LANG=en_IN.UTF-8`
  - `~/.config/fish/config.fish`: `set -gx LANG en_IN.UTF-8`
  - `~/.local/share/applications/btop.desktop`: Exec wraps with `env LANG=en_IN.UTF-8`
- `~/.config/environment.d/session.conf`: `TERMINAL=kitty` so `Terminal=true` apps launch through kitty.
- `~/.config/uwsm/env`: `BROWSER=zen-browser`.
- Note: environment.d applies only at next login. A running noctalia keeps the old env until restarted.

## Power-aware refresh rate

`~/.local/bin/hypr-refresh-rate` sets the laptop panel to 144 Hz while the ACPI platform profile is `performance` or `max-power` (Noctalia's "performance mode") and 60 Hz for every other profile. The profile lives at `/sys/firmware/acpi/platform_profile`; Noctalia writes it and the laptop's performance-mode LED follows it.

`~/.config/systemd/user/hypr-refresh-watch.service` runs `~/.local/bin/hypr-refresh-watch` (a small python inotify loop) which re-applies `hypr-refresh-rate` whenever the kernel signals a write to `/sys/firmware/acpi/platform_profile`. It applies once at startup and stays live across events. A systemd `PathChanged=` path unit was tried first and turned out unreliable on this sysfs file (missed writes made through power-profiles-daemon), which is why the watcher is a dedicated service instead. If a bare `hyprctl reload` happens mid-session the panel reverts to its preferred 60 Hz until the next mode change or login.

## How updates interact with these files

`cachyos-hypr-noctalia` owns only `/etc/skel/` (the template for new users). Your `~/.config` files are not tracked by any package, so `pacman` never overwrites them. The noctalia cheatsheet plugin is a local path source and is not affected by plugin updates either (see above).

## Known quirks

- Discord on native Wayland and on XWayland both show a stale half-window when the tile shrinks (Hyprland issue #7909, unfixed). Left on XWayland default. Keep other windows out of its workspace.
- Fastfetch greeting is disabled in `fish/config.fish` (empty `fish_greeting`).
- Discord is pinned to the primary monitor via windowrules.
- `SUPER+Q`: unbound by design (close is on `SUPER+W`).