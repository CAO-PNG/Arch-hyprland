#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="$HOME/.cache/waybar"
CACHE="$CACHE_DIR/lyric_sentence.txt"
PIDFILE="$CACHE_DIR/lyric_agent.pid"
LOCKFILE="$CACHE_DIR/lyric_agent.lock"
PY="/usr/bin/python3"
ONCE="$HOME/.config/waybar/scripts/feeluown_lyric_once.py"

mkdir -p "$CACHE_DIR"

agent_loop() {
  # 0.2s 刷一次缓存；Waybar 仍按 1s 读文件，但内容几乎实时
  while :; do
    lyric="$("$PY" "$ONCE" 2>/dev/null || true)"
    # 原子写，避免读到半行
    tmp="${CACHE}.tmp"
    printf "%s" "$lyric" >"$tmp"
    mv -f "$tmp" "$CACHE"
    sleep 0.2
  done
}

start_agent_if_needed() {
  # 避免并发启动：用 flock（util-linux 提供，Arch 默认有）
  exec 9>"$LOCKFILE"
  flock -n 9 || return 0

  if [[ -f "$PIDFILE" ]]; then
    pid="$(cat "$PIDFILE" 2>/dev/null || true)"
    if [[ -n "${pid:-}" ]] && kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi

  # 用 setsid + 后台，脱离 Waybar 进程组；不依赖 systemd
  setsid bash -lc "$(declare -f agent_loop); agent_loop" \
    >/dev/null 2>&1 &

  echo $! >"$PIDFILE"
}

# 主流程：先确保 agent 在跑，再输出缓存给 Waybar
start_agent_if_needed

if [[ -f "$CACHE" ]]; then
  cat "$CACHE"
else
  echo ""
fi
