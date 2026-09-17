#!/usr/bin/env bash
#
# bt-hfp-watcher — event-driven
#
# Watches the PipeWire "bluez_source" node (the HFP microphone path created while
# a Bluetooth headset is in a call). The node reports state "running" during a
# call and drops out of "running" when the call ends.
#
# Known stack bug (btmon-proven, HFP 2nd-call "Failure in Bluetooth audio
# transport"): a stale HFP SCO transport makes the SECOND call fail until
# WirePlumber is restarted. This watcher restarts WirePlumber a few seconds
# after every call ends to flush the stale transport.
#
# Event-driven: instead of polling, we subscribe to PipeWire node events with
# pw-mon. While idle the process simply blocks on the stream — no periodic
# CPU/wakeups.
#
# Install:  systemctl --user enable --now bt-hfp-watcher

set -u

PW_MON="$(command -v pw-mon || echo /usr/bin/pw-mon)"
JQ="$(command -v jq || echo /usr/bin/jq)"
RESTART_DELAY="${BT_HFP_RESTART_DELAY:-3}"

logger -t bt-hfp-watcher "started (event-driven; idle cost ~0)"

# Track the bluez_source state by subscribing to PipeWire node events.
"$PW_MON" -N 2>/dev/null | "$JQ" --unbuffered -r '
  . as $e |
  ($e.object.info.props // empty) as $p |
  select($p["node.name"]? |
          startswith("bluez_source.")) |
  [ $p["node.name"], $e.object.info.state ] | @tsv
' | while IFS=$'\t' read -r node state; do
    # State transitions we care about:
    #   running -> anything-else  = call ended
    if [ "$prev_state" = "running" ] && [ "$state" != "running" ]; then
        logger -t bt-hfp-watcher \
            "HFP call ended ($node left running); restarting WirePlumber in ${RESTART_DELAY}s to flush stale SCO transport"
        sleep "$RESTART_DELAY"
        systemctl --user restart wireplumber
        logger -t bt-hfp-watcher "WirePlumber restarted (flushed stale BT transport)"
    fi
    prev_state="$state"
done
