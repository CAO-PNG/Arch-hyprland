#!/usr/bin/env python3
import subprocess
import json
import time


def get_lyric():
    try:
        # 获取 Hyprland 窗口列表
        result = subprocess.check_output(["hyprctl", "clients", "-j"])
        clients = json.loads(result)

        for client in clients:
            # 定位歌词窗口
            if (
                client.get("initialClass") == "qqmusic"
                and client.get("initialTitle") == "歌词"
            ):
                title = client.get("title", "")
                # 如果标题还是初始化的“歌词”，说明可能没拿到具体内容，返回空
                if title == "歌词":
                    return ""
                return title
        return ""
    except Exception:
        return ""


while True:
    lyric = get_lyric()
    # 格式化为 Waybar 接收的 JSON
    output = {
        "text": lyric,
        "tooltip": f"QQ音乐实时歌词: {lyric}" if lyric else "未检测到歌词",
    }
    print(json.dumps(output), flush=True)
    time.sleep(1)  # 刷新频率，1秒一次
