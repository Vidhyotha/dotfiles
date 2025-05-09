#!/usr/bin/env bash
# pick an image from your wallpapers folder with rofi, then run wal on it

WALLS="$HOME/Pictures/Wallpapers"

# Simple check if directory exists
if [ ! -d "$WALLS" ]; then
    notify-send "Error" "Wallpaper directory not found: $WALLS"
    exit 1
fi

# Check for sxiv first (better image preview)
if command -v sxiv &> /dev/null; then
    # Use sxiv in thumbnail mode to select an image
    cd "$WALLS" || exit
    FILE=$(sxiv -t -o "$WALLS" 2>/dev/null)
    # If multiple files are selected, take the first one
    FILE=$(echo "$FILE" | head -n1)
else
    # Create a temporary file for the menu items
    MENU_ITEMS_FILE=$(mktemp)

    # Find all wallpapers and create menu with just filenames
    find "$WALLS" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort | while read img; do
        FILENAME=$(basename "$img")
        echo -e "${FILENAME}\0icon\0${img}" >> "$MENU_ITEMS_FILE"
    done

    # Use rofi to select a wallpaper
    SELECTED=$(rofi -dmenu -i -p "Wallpaper" < "$MENU_ITEMS_FILE")

    # Remove temporary file
    rm "$MENU_ITEMS_FILE"

    # Check if selection was made
    if [ -z "$SELECTED" ]; then
        exit 0
    fi

    # Get the full path from the selection
    FILE=$(find "$WALLS" -maxdepth 1 -type f -name "$SELECTED")
fi

# Exit if nothing chosen
[ -z "$FILE" ] && exit 0

# Debug output
echo "Selected wallpaper: $FILE" >> /tmp/pywal-debug.log

# Run pywal to set colors
wal -i "$FILE" -n

# Store the path to the wallpaper
echo "$FILE" > "$HOME/.cache/wal/wal"

# Update hyprpaper config
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

# Create/update hyprpaper.conf
cat > "$HYPRPAPER_CONF" << EOF
preload = $FILE
wallpaper = ,$FILE
EOF

# Reload hyprpaper
if pgrep hyprpaper > /dev/null; then
    killall -q hyprpaper
    sleep 0.5
fi
hyprpaper &

# Reload Hyprland config to apply new colors
hyprctl reload

# Reload Mako config
~/.config/mako/generate-config.sh

# Reload SDDM
sudo ~/.local/bin/update-sddm-colors.sh

# Notify user
notify-send "Wallpaper Changed" "Applied: $(basename "$FILE")" -i "$FILE"

exit 0