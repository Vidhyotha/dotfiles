---
name: webapp
description: Create a standalone web app on this system. Use when the user asks to turn a website into an app, add a web app, or says something like "make WhatsApp an app" or "I want a webapp for X". Also use when they ask how web apps work here or to list/remove them.
---

# Web apps

This system runs web apps the Omarchy way: each site opens in its own frameless, single-window Chromium app-mode instance. Chromium (`chromium`) is the dedicated web-app runtime; the daily browser (Zen) is untouched. Web apps share Chromium's cookies, so a login in one web app carries to the others and to the runtime browser.

## Tooling

- `~/.local/bin/webapp-launch <url>` launches a URL as a frameless app window. Used in `.desktop` files, rarely called directly.
- `~/.local/bin/webapp-install <name> <url> [icon-url]` creates the launcher entry and downloads the icon.
- Entries land in `~/.local/share/applications/<name>.desktop`, icons in `~/.local/share/applications/icons/<name>.png`.
- Both files are user-owned. CachyOS updates do not touch `~/.local/bin` or `~/.local/share/applications`.

## To add a web app

1. Pick a short display name and the site URL. Prefer the web variant that fits a window (for example `web.whatsapp.com`, not `whatsapp.com`).
2. Run `webapp-install <name> <url>`. It fetches the favicon from Google's favicon service, so no icon URL is usually needed.
3. If favicon fetch fails, ask the user for a PNG icon URL, or suggest Dashboard Icons (`https://dashboardicons.com`), and run `webapp-install <name> <url> <icon-url>`.
4. Verify the result: read the `.desktop` file, confirm the icon PNG exists, and confirm the URL starts with a scheme.

## To launch or verify an app

Run `webapp-launch <url>` to test one in the current session. Give Chromium a few seconds to start.

## First run notes

- The first time Chromium ever runs it shows a Terms of Service page. Accept it once; the app window follows.
- A web app window reports its Hyprland class as `chrome-<host>-Default` (for example `chrome-web.whatsapp.com__-Default`). Useful for window rules, not needed for basic use.

## To remove a web app

Delete `~/.local/share/applications/<name>.desktop` and `~/.local/share/applications/icons/<name>.png`.

## What not to do

Do not install another browser for the runtime, do not edit the system-level Chromium config, and do not add per-app Hyprland window rules unless the user asks. Apps show up in the launcher (`Super + Space`) with no extra setup.