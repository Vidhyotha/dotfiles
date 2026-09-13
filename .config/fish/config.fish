source /usr/share/cachyos-fish-config/cachyos-config.fish

# fix UTF-8 locale (btop and others refuse to start without it)
set -gx LANG en_IN.UTF-8

# overwrite greeting (disables fastfetch on terminal start)
function fish_greeting
end

# opencode
fish_add_path /home/vidhyotha/.opencode/bin
