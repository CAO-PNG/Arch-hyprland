#!/usr/bin/env python3
import socket
import re

HOST, PORT = "127.0.0.1", 23333


def recv_line(sock: socket.socket) -> bytes:
    buf = b""
    while True:
        c = sock.recv(1)
        if not c:
            break
        buf += c
        if c == b"\n":
            break
    return buf


def recv_exact(sock: socket.socket, n: int) -> bytes:
    buf = b""
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            break
        buf += chunk
    return buf


def main():
    try:
        # 关键：超时要短，避免任何一次阻塞拖慢整体
        with socket.create_connection((HOST, PORT), timeout=0.25) as s:
            s.settimeout(0.25)

            _ = recv_line(s)  # OK rpc 2.0
            s.sendall(b"status\n")
            ack = recv_line(s).decode("utf-8", "ignore").strip()

            m = re.match(r"ACK\s+OK\s+(\d+)", ack, re.IGNORECASE)
            if not m:
                print("")
                return

            length = int(m.group(1))
            body = recv_exact(s, length).decode("utf-8", "ignore")

            for line in body.splitlines():
                if "lyric-s:" in line:
                    print(line.split("lyric-s:", 1)[1].strip())
                    return

            print("")
    except Exception:
        print("")


if __name__ == "__main__":
    main()
