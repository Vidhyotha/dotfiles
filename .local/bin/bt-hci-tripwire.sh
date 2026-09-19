#!/usr/bin/env bash
# WirePlumber-verdict tripwire for PipeWire #5467. Raw HCI is impossible for a
# user uid (EPERM on BTPROTO_HCI bind, proven), but the bug fires entirely
# inside WP's bluez5 layer, whose journal a user can always read. No privileges.
set -u
PRESERVE="$HOME/Projects/BT-fix/preserved"
mkdir -p "$PRESERVE"
on_hit() {
  local ts dst
  ts="$(date +%Y%m%d-%H%M%S)"
  dst="$PRESERVE/FAIL-$ts"; mkdir -p "$dst"
  printf '%s\n' "$1" > "$dst/signature.txt"
  journalctl --user -u wireplumber --since "now -5 min" --no-pager > "$dst/wireplumber.fail.log" 2>/dev/null || :
  { pipewire -v 2>&1 | head -1; wireplumber -v 2>&1 | head -1; pactl info 2>/dev/null | grep -iE "Server Name"; } > "$dst/versions.txt" 2>/dev/null || :
  echo "BT-TRIPWIRE-HIT: $1  → $dst" >> "$HOME/Projects/BT-fix/preserved/tripwire.log"
  echo "BT-TRIPWIRE-HIT: $dst"
}
journalctl --user -u wireplumber -f -o short --no-pager 2>/dev/null | while IFS= read -r L; do
  case "$L" in
    *"state changed -1 -> -1"*|*"spa_bt_transport_acquire"*|*"Received error event"*)
      on_hit "$L";;
  esac
done
