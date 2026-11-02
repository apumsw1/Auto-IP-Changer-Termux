#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

TORRC="$HOME/.tor/torrc"
PIDFILE="$HOME/.tor/tor.pid"
SOCKS="127.0.0.1:9050"
CONTROL="127.0.0.1 9051"

is_running() {
  pgrep -x tor >/dev/null 2>&1
}

start_tor() {
  if is_running; then
    echo "Tor is already running."
    return
  fi
  mkdir -p "$HOME/.tor/data"
  tor -f "$TORRC" --PidFile "$PIDFILE" >/dev/null 2>&1 &
  echo "Starting Tor..."
  for _ in $(seq 1 30); do
    if curl --silent --socks5-hostname "$SOCKS" --max-time 3 https://check.torproject.org/api/ip >/dev/null; then
      echo "Tor is ready."
      return
    fi
    sleep 1
  done
  echo "Tor did not become ready. Check: tor -f $TORRC"
  exit 1
}

show_ip() {
  curl --fail --silent --show-error --socks5-hostname "$SOCKS" --max-time 20 https://api.ipify.org
  echo
}

rotate() {
  if ! is_running; then
    echo "Tor is not running. Run: ./autoip.sh start"
    exit 1
  fi
  reply="$(printf 'AUTHENTICATE\r\nSIGNAL NEWNYM\r\nQUIT\r\n' | nc -w 3 127.0.0.1 9051 || true)"
  if ! grep -q '250 OK' <<<"$reply"; then
    echo "Tor did not accept the NEWNYM request:"
    echo "$reply"
    exit 1
  fi
  echo "New Tor circuit requested. Waiting briefly..."
  sleep 5
  show_ip
}

stop_tor() {
  if is_running; then
    pkill -x tor || true
    echo "Tor stopped."
  else
    echo "Tor is not running."
  fi
}

case "${1:-help}" in
  start) start_tor ;;
  ip) show_ip ;;
  rotate) rotate ;;
  loop)
    interval="${2:-5}"
    if ! [[ "$interval" =~ ^[1-9][0-9]*$ ]]; then
      echo "Interval must be a positive whole number of minutes."
      exit 2
    fi
    start_tor
    while true; do
      echo "[$(date)] Requesting new Tor circuit..."
      rotate
      sleep "$((interval * 60))"
    done
    ;;
  stop) stop_tor ;;
  help|*)
    echo "Usage: $0 {start|ip|rotate|loop [minutes]|stop}"
    ;;
esac
