#!/usr/bin/env python3
"""Native messaging host: receives {"url": ...} from the Omarchy Link Router
extension and opens it with xdg-open (i.e. the system default browser)."""
import json
import struct
import subprocess
import sys


def main():
    raw_len = sys.stdin.buffer.read(4)
    if len(raw_len) != 4:
        return
    msg_len = struct.unpack('<I', raw_len)[0]
    msg = json.loads(sys.stdin.buffer.read(msg_len))
    url = msg.get('url', '')
    ok = False
    if url.startswith(('http://', 'https://')):
        subprocess.Popen(
            ['xdg-open', url],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        ok = True
    resp = json.dumps({'ok': ok}).encode()
    sys.stdout.buffer.write(struct.pack('<I', len(resp)) + resp)
    sys.stdout.buffer.flush()


if __name__ == '__main__':
    main()
