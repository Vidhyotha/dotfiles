#!/bin/bash
# Script to display volume notifications with mako using wpctl
# Requires: wpctl, bc, notify-send

# Get current volume and mute status
function get_volume {
    # Get volume as float (0.0-1.5) and multiply by 100
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP '[0-9]+\.[0-9]+' | awk '{print int($1 * 100)}'
}

function is_muted {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "true" || echo "false"
}

# Get current volume and mute status
VOLUME=$(get_volume)
MUTED=$(is_muted)

# Define icons based on volume level (using Papirus style icons)
if [ "$MUTED" = "true" ]; then
    ICON="audio-volume-muted"
elif [ "$VOLUME" -eq 0 ]; then
    ICON="audio-volume-muted"
elif [ "$VOLUME" -lt 30 ]; then
    ICON="audio-volume-low"
elif [ "$VOLUME" -lt 70 ]; then
    ICON="audio-volume-medium"
else
    ICON="audio-volume-high"
fi

# Create the notification
if [ "$MUTED" = "true" ]; then
    notify-send -h string:x-canonical-private-synchronous:volume \
        -h int:value:0 \
        -i "$ICON" \
        "Volume: Muted" \
        -t 2000
else
    notify-send -h string:x-canonical-private-synchronous:volume \
        -h int:value:"$VOLUME" \
        -i "$ICON" \
        "Volume: ${VOLUME}%" \
        -t 2000
fi