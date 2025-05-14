# 🧰 Dotfiles Setup Guide

A complete guide to set up your system with my customized environment using dotfiles and preferred tools.

## 📋 Table of Contents
- [Prerequisites](#-prerequisites-install-yay-aur-helper)
- [Installation](#-install-required-packages)
- [Configuration](#-apply-dotfiles)
- [Post-Installation Tasks](#-post-installation-tasks)
  - [Enable Bluetooth](#enable-bluetooth)
  - [Set Default Shell](#set-zsh-as-default-shell)
  - [SDDM Theme Setup](#-enable-sddm-theme-color-updates)

---

## ✅ Prerequisites: Install `yay` (AUR Helper)

```bash
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## 📦 Install Required Packages

```bash
yay -Syu alacritty bibata-cursor-git bluez bluezutils brave-bin brightnessctl \
    chezmoi git hypridle hyprland hyprlock hyprpaper mako nautilus nvim nsxiv \
    papyrus-icon-theme-git pavucontrol python-pywal16 rofi sddm starship \
    ttf-jetbrains-mono-nerd ttf-twmoji unzip waybar zsh
```

## 🛠️ Apply Dotfiles

```bash
chezmoi init --apply https://github.com/Vidhyotha/dotfiles.git
```

## 🚀 Post-Installation Tasks

### Enable Bluetooth

```bash
systemctl start bluetooth.service
systemctl enable bluetooth.service
```

### Set ZSH as Default Shell

```bash
chsh -s $(which zsh)
```

> **Note**: Reboot your system for changes to take effect

### ⚙️ Enable SDDM Theme Color Updates

Two files will be downloaded to your Downloads folder:
- `sddm.conf`
- `pywal-theme.zip`

These need to be moved to the correct locations:

```bash
# Move and extract theme files
sudo mv ~/Downloads/pywal-theme.zip /usr/share/sddm/themes/
sudo unzip /usr/share/sddm/themes/pywal-theme.zip
sudo mv ~/Downloads/sddm.conf /etc/sddm.conf
```

#### Configure Passwordless SDDM Theme Updates

The `update-sddm-colors.sh` script requires sudo access without password:

1. **Open the sudoers file**:
   ```bash
   sudo EDITOR=nvim visudo
   ```

2. **Add the following line** at the bottom of the file (`SHIFT + G` then `i` to enter insert mode):
   ```bash
   your_username ALL=(ALL) NOPASSWD: /home/your_username/.local/bin/update-sddm-colors.sh
   ```
   
   > **Important**: Replace `your_username` with your actual username

---

## 💡 Additional Resources

- [Project GitHub Repository](https://github.com/Vidhyotha/dotfiles)
- [Report Issues](https://github.com/Vidhyotha/dotfiles/issues)