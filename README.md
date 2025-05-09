# 🧰 Dotfiles Setup Guide

Set up your system with my dotfiles and preferred tools using the steps below.

---

## ✅ Prerequisites: Install `yay` (AUR Helper)

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

---

## 📦 Install Required Packages

```bash
yay -Syu \
  zsh alacritty bibata-cursor-git brave-bin brightnessctl \
  chezmoi git hypridle hyprland hyprlock hyprpaper \
  mako nautilus nvim nsxiv papyrus-icon-theme-git \
  python-pywal16 rofi sddm starship waybar zsh
```

---

## 🛠️ Apply Dotfiles

```bash
chezmoi init --apply https://github.com/Vidhyotha/dotfiles.git
```

---

## ⚙️ Enable SDDM Theme Color Updates (No Password Required)

My `update-sddm-colors.sh` script requires sudo access. To allow it without prompting for a password:

### 1. Open the sudoers file with nvim:

```bash
sudo EDITOR=nvim visudo
```

### 2. Scroll to the bottom (Ctrl + G), enter insert mode (`i`), and add:

```bash
your_username ALL=(ALL) NOPASSWD: /home/your_username/.local/bin/update-sddm-colors.sh
```

Replace `your_username` with **your actual username**.

---
