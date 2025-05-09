#!/bin/bash
# Script to display brightness notifications with mako

# Get current brightness percentage
function get_brightness {
    # Try brightnessctl first
    if command -v brightnessctl &> /dev/null; then
        brightnessctl -m | cut -d',' -f4 | tr -d '%'
        return
    fi

    # Fallback to light if available
    if command -v light &> /dev/null; then
        light -G | xargs printf "%.0f"
        return
    fi

    # Last resort - try to read from /sys
    if [ -f /sys/class/backlight/*/brightness ] && [ -f /sys/class/backlight/*/max_brightness ]; then
        cur=$(cat /sys/class/backlight/*/brightness)
        max=$(cat /sys/class/backlight/*/max_brightness)
        echo $(( cur * 100 / max ))
        return
    fi

    # If all else fails
    echo 50
}

BRIGHTNESS=$(get_brightness)

# Define icon based on brightness level (using Papirus style icons)
if [ "$BRIGHTNESS" -lt 30 ]; then
    ICON="display-brightness-low"
elif [ "$BRIGHTNESS" -lt 70 ]; then
    ICON="display-brightness-medium"
else
    ICON="display-brightness-high"
fi

# Create the notification
notify-send -h string:x-canonical-private-synchronous:brightness \
    -h int:value:"$BRIGHTNESS" \
    -i "$ICON" \
    "Brightness: ${BRIGHTNESS}%" \
    -t 2000