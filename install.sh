#!/data/data/com.termux/files/usr/bin/bash
set -e
pkg update -y
pkg install -y tor curl netcat-openbsd
mkdir -p "$HOME/.tor"
TORRC="$HOME/.tor/torrc"
if [ ! -f "$TORRC" ]; then
  cat > "$TORRC" <<'EOF'
SocksPort 9050
ControlPort 9051
CookieAuthentication 0
DataDirectory /data/data/com.termux/files/home/.tor/data
EOF
fi
mkdir -p "$HOME/.tor/data"
echo "Installed. Run: ./autoip.sh start"
