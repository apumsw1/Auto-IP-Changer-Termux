# Auto-IP-Changer-Termux

A Termux utility that checks your public IP through Tor and requests a new Tor exit circuit on a schedule.

> **Important:** This rotates the Tor exit IP, not your mobile carrier's or Wi-Fi router's IP. It does not guarantee a different IP on every request. Use only where Tor is legal and permitted.

## Requirements
- Android with [Termux](https://github.com/termux/termux-app) installed from a trusted source
- Internet access

## Install

```bash
git clone https://github.com/apumsw1/Auto-IP-Changer-Termux.git
cd Auto-IP-Changer-Termux
chmod +x install.sh autoip.sh
./install.sh
```

## Usage

```bash
./autoip.sh start       # start Tor in the background
./autoip.sh ip          # show current Tor exit IP
./autoip.sh rotate      # request a new Tor circuit, then show IP
./autoip.sh loop 5      # rotate/check every 5 minutes (Ctrl+C to stop)
./autoip.sh stop        # stop Tor
```

The script uses Tor's SOCKS proxy at `127.0.0.1:9050` and control port at `127.0.0.1:9051`.

## Notes
- Tor may reuse an exit IP; `NEWNYM` requests a fresh circuit but does not promise a unique address.
- Apps that do not use the Tor SOCKS proxy will continue using their normal network connection.
- This does not change your device's local LAN IP or your carrier-assigned public IP.
- Do not use this to evade bans, rate limits, or access controls.
