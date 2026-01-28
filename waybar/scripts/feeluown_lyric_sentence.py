#!/usr/bin/env python3
import socket
import re

HOST = "127.0.0.1"
PORT = 23333


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
        with socket.create_connection((HOST, PORT), timeout=1.5) as s:
            s.settimeout(1.5)

            # greeting: "OK rpc 2.0\n"
            _ = recv_line(s)

            # request
            s.sendall(b"status\n")

            # ack line, e.g. "ACK OK 223\n"
            ack = recv_line(s).decode("utf-8", "ignore").strip()
            m = re.match(r"ACK\s+OK\s+(\d+)", ack, re.IGNORECASE)
            if not m:
                print("")
                return

            length = int(m.group(1))
            body = recv_exact(s, length).decode("utf-8", "ignore")

            # extract lyric-s
            lyric = ""
            for line in body.splitlines():
                # 支持 "lyric-s:" 或带缩进的 "  lyric-s:"
                if "lyric-s:" in line:
                    lyric = line.split("lyric-s:", 1)[1].strip()
                    break

            print(lyric if lyric else "")

    except Exception:
        # FeelUOwn 未启动/瞬断时不输出，避免 Waybar 报错闪烁
        print("")


if __name__ == "__main__":
    main()
