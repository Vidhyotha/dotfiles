#!/bin/bash
# filepath: /home/vidhyotha/.local/bin/update-sddm-colors.sh

# Source the pywal colors file to get the wallpaper path and colors
source /home/vidhyotha/.cache/wal/colors.sh

# Check if wallpaper variable exists and file exists
if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
    echo "Error: Wallpaper not found!"
    exit 1
fi

# Add debug output
echo "Setting wallpaper to: $wallpaper" > /tmp/sddm-update.log

# Copy the wallpaper to the theme directory
THEME_DIR="/usr/share/sddm/themes/pywal-theme"
WALLPAPER_NAME=$(basename "$wallpaper")
sudo cp -f "$wallpaper" "$THEME_DIR/Assets/$WALLPAPER_NAME"
RELATIVE_PATH="Assets/$WALLPAPER_NAME"

# Update the wallpaper path in metadata.desktop (with absolute path for Screenshot)
sed -i "s|^Screenshot=.*|Screenshot=$wallpaper|" $THEME_DIR/metadata.desktop

# Update the wallpaper path in theme.conf (with relative path for Background)
sed -i "s|^Background=.*|Background=$RELATIVE_PATH|" $THEME_DIR/theme.conf

# Enable blur and form background for better text visibility
sed -i "s|^PartialBlur=.*|PartialBlur=\"true\"|" $THEME_DIR/theme.conf
sed -i "s|^HaveFormBackground=.*|HaveFormBackground=\"true\"|" $THEME_DIR/theme.conf
sed -i "s|^FormPosition=.*|FormPosition=\"center\"|" $THEME_DIR/theme.conf
sed -i "s|^BlurMax=.*|BlurMax=\"170\"|" $THEME_DIR/theme.conf
sed -i "s|^Blur=.*|Blur=\"0.8\"|" $THEME_DIR/theme.conf

# Set form background to be semi-transparent (adjust opacity in the QML)
sed -i "s|^FormBackgroundColor=.*|FormBackgroundColor=\"$color0\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

# Update the rest of your colors
sed -i "s|^HeaderTextColor=.*|HeaderTextColor=\"$color4\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^DateTextColor=.*|DateTextColor=\"$color4\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^TimeTextColor=.*|TimeTextColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

sed -i "s|^BackgroundColor=.*|BackgroundColor=\"$color0\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^DimBackgroundColor=.*|DimBackgroundColor=\"$color0\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

sed -i "s|^LoginFieldBackgroundColor=.*|LoginFieldBackgroundColor=\"$color0\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^PasswordFieldBackgroundColor=.*|PasswordFieldBackgroundColor=\"$color0\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^LoginFieldTextColor=.*|LoginFieldTextColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^PasswordFieldTextColor=.*|PasswordFieldTextColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^UserIconColor=.*|UserIconColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^PasswordIconColor=.*|PasswordIconColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

sed -i "s|^LoginButtonTextColor=.*|LoginButtonTextColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^LoginButtonBackgroundColor=.*|LoginButtonBackgroundColor=\"$color4\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^SystemButtonsIconsColor=.*|SystemButtonsIconsColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

sed -i "s|^HighlightTextColor=.*|HighlightTextColor=\"$color0\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^HighlightBackgroundColor=.*|HighlightBackgroundColor=\"$color7\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^HighlightBorderColor=.*|HighlightBorderColor=\"$color4\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

sed -i "s|^HoverSystemButtonsIconsColor=.*|HoverSystemButtonsIconsColor=\"$color4\"|" /usr/share/sddm/themes/pywal-theme/theme.conf
sed -i "s|^HoverSessionButtonTextColor=.*|HoverSessionButtonTextColor=\"$color4\"|" /usr/share/sddm/themes/pywal-theme/theme.conf

echo "SDDM theme updated with wallpaper: $wallpaper" | tee -a /tmp/sddm-update.log