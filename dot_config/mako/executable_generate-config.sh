#!/bin/bash
# Script to generate mako config with pywal colors
# Save this as ~/.config/mako/generate-config.sh and make it executable
# Run: chmod +x ~/.config/mako/generate-config.sh

# Path to the mako config file
MAKO_CONFIG=~/.config/mako/config

# Get colors from pywal
source ~/.cache/wal/colors.sh

# Create mako config
cat > $MAKO_CONFIG << EOF
# ~/.config/mako/config

# Import pywal colors
# colors from pywal (added by script)
background-color=${background}
text-color=${foreground}
border-color=${color1}
progress-color=over ${color2}

# Font
font=JetBrainsMono Nerd Font 11

# General styling
width=350
height=100
margin=20
padding=15
border-size=2
border-radius=4
max-icon-size=64
icon-path=/usr/share/icons/Papirus-Dark:/usr/share/icons/Papirus

# Display settings
layer=overlay
anchor=top-center

# Behavior
default-timeout=5000
ignore-timeout=0
group-by=app-name

# Styling for different urgency levels
[urgency=low]
border-color=${color3}

[urgency=normal]
border-color=${color4}

[urgency=high]
border-color=${color1}
background-color=${color1}
text-color=${background}
default-timeout=0
ignore-timeout=1
EOF

echo "Mako config generated with pywal colors at $MAKO_CONFIG"

# Reload mako if it's running
if pgrep mako >/dev/null; then
    pkill -SIGUSR2 mako
    echo "Mako reloaded with new configuration"
else
    echo "Mako is not running. Start it with 'mako'"
fi