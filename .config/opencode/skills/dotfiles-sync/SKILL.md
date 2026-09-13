---
name: dotfiles-sync
description: Use after any customization to this CachyOS/Hyprland/Noctalia system. Also use when the user says "save my dots", "commit my config", "back up my changes", "push to dotfiles", or "save this to the repo". After editing tracked files such as ~/.config/hypr, ~/.config/noctalia, ~/.local/bin, ~/.local/share/applications, or any other dotfile listed below, commit the changes to the bare dotfiles repo and push to GitHub.
---

# Dotfiles sync

After finishing a customization on this system, save it to the dotfiles repo.
Run these steps as the last action of the customization task, even if the user
did not ask in that moment. Skip only if the change is clearly temporary or
experimental, and say why you are skipping it.

## The repo

This machine uses a bare git repo at `~/.dotfiles` with `$HOME` as its working
tree. Files are never symlinked or moved; `git dotfiles` commits them in place.

```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

The alias is defined in `~/.gitconfig`. If it is missing, set it globally:
`git config --global alias.dotfiles '!git --git-dir=$HOME/.dotfiles --work-tree=$HOME'`
and re-enable `git dotfiles config status.showUntrackedFiles no`.

## Tracked paths (whitelist)

These locations are eligible for commits. This list grows as the user
customizes more of the system, so it is not exhaustive. Any file added via the
flow below becomes part of it and must be listed in the README's "What this
tracks" section.

- `~/.config/hypr/` (the whole Lua config)
- `~/.config/noctalia/` (config.toml + the local cheatsheet plugin)
- `~/.config/fish/config.fish`
- `~/.config/environment.d/`
- `~/.config/uwsm/env`
- `~/.config/kitty/` (kitty.conf and themes)
- `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini` (dark GTK theme for dialogs)
- `~/.config/mimeapps.list`
- `~/.config/opencode/skills/` (skill definitions only)
- `~/.local/bin/`
- `~/.local/share/applications/` (the .desktop files and overrides)
- `~/Pictures/Wallpapers/` (the whole folder, they feed the noctalia theme)
- `~/README.md` (the reinstate guide)

## Customizations outside the whitelist

A customization can land anywhere, not just in the tracked list. On every sync,
scan for untracked files (the command in step 1 shows them) and check whether
any belong to a path the user just customized, even if it is new. They belong
in the repo if they are config, a dotfile, a small script, or a settings file.
They stay out if they match the never-commit list or are big binaries, session
data, caches, or files that only make sense on this machine.

If a new path qualifies:

1. Stage it: `git dotfiles add <new path>`.
2. Add a matching bullet under the README's "What this tracks" section.
3. Mention the path explicitly in the commit message body so it is clear the
   whitelist grew.

Then going forward it is a normal tracked path. If the path does not qualify,
do not add it, and if it is machine-specific explain why it was skipped rather
than silently dropping it.

## Never commit these

- `~/.config/zen/` (contains logins, cookies, session data)
- `~/.config/fish/fish_variables` (runtime universal variables)
- `~/.local/share/applications/mimeinfo.cache` (generated cache)
- `~/.ssh/`, `~/.pki/`, `~/.nv/`, `~/.steam/`, `~/.cargo/`, `~/.npm/`, `~/.cache/`
- `~/.local/share/opencode/` (opencode session database)
- `~/.config/opencode/` except `skills/` (node_modules, bin, package files)
- `~/.dotfiles/` itself
- scratch files like `~/luac.out`
- anything still mounted under `/data`

## Workflow

1. Inspect changes:
   ```bash
   cd ~ && git dotfiles status --short
   ```
   `status.showUntrackedFiles no` hides untracked files, so also list the
   untracked files across `$HOME` (limited to dotfiles and config dirs, skip
   ~/.cache, ~/.steam, ~/.local/share/opencode, and other noisy trees):
   ```bash
   git dotfiles -c status.showUntrackedFiles=all status --short -- .config .local .bash* .zsh* .gitconfig README.md
   ```
   Filter the results to the whitelist above and drop the never-commit list
   before adding anything, then run the flow under "Customizations outside the
   whitelist" for any new paths.

2. Keep the README (`~/README.md`) accurate. Before committing, check whether
   this change touches anything the README documents, and update it in the same
   commit if so:
   - tracked paths list (new dirs, removed dirs)
   - keybindings table or gestures
   - launcher overrides / visible apps
   - installed or removed packages
   - new skills under `~/.config/opencode/skills/`
   - new system-level setup (mounts, services, hardware)
   - new known quirks
   If the change is not a documented fact in the README, leave the README alone.

3. Stage explicitly. Never run `git dotfiles add .` or `git add -A` from the
   working tree, that would sweep in the whole home directory.
   ```bash
   git dotfiles add ~/.config/hypr ~/.config/noctalia ... <specific paths>
   ```
   If the README changed, add it too: `git dotfiles add ~/README.md`.

4. Review what is staged, and check nothing sensitive slipped in:
   ```bash
   git dotfiles diff --cached --stat
   git dotfiles diff --cached
   ```

5. Commit with a message that names the change, not the location:
   `git dotfiles commit -m "<what changed>: <short summary>"`

6. Push:
   ```bash
   git dotfiles push
   ```
   If push fails on auth, stop and tell the user rather than guessing.

7. Confirm the commit landed: `git dotfiles log --oneline -1`.

## When a change does not live in a tracked path

System-level changes (installed packages, `/etc/fstab`, new services, hardware)
cannot be committed. If the change matters when reinstalling, add a line to
`~/README.md` under the relevant section and commit that instead. Keep the
README the single source of truth for reinstate steps.

## Patching the cheatsheet plugin

Edits under `~/.config/noctalia/plugins/keybind-cheatsheet/` are normal tracked
files, so commit them like anything else. The plugin is a local `path` source
and is immune to `noctalia msg plugins update`: updates only pull the git
sources, and path plugins run directly from this folder. No reapply step is
needed after an update. Restart noctalia to load path-source edits:
`pkill -x noctalia; sleep 2; nohup uwsm app -- noctalia &`.